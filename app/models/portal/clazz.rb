class Portal::Clazz < ActiveRecord::Base
  set_table_name :portal_clazzes

  acts_as_replicatable

  belongs_to :course, :class_name => "Portal::Course", :foreign_key => "course_id"
  belongs_to :semester, :class_name => "Portal::Semester", :foreign_key => "semester_id"
  # belongs_to :teacher, :class_name => "Portal::Teacher", :foreign_key => "teacher_id"

  has_many :offerings, :dependent => :destroy, :class_name => "Portal::Offering", :foreign_key => "clazz_id"
  has_many :active_offerings, :class_name => "Portal::Offering", :foreign_key => 'clazz_id', :conditions => { :active => true }

  has_many :student_clazzes, :class_name => "Portal::StudentClazz", :foreign_key => "clazz_id"
  has_many :students, :through => :student_clazzes, :class_name => "Portal::Student"

  has_many :teacher_clazzes, :dependent => :destroy, :class_name => "Portal::TeacherClazz", :foreign_key => "clazz_id"
  has_many :teachers, :through => :teacher_clazzes, :class_name => "Portal::Teacher"

  has_many :grade_levels, :dependent => :destroy, :as => :has_grade_levels, :class_name => "Portal::GradeLevel"
  has_many :grades, :through => :grade_levels, :class_name => "Portal::Grade"
  
  before_validation :class_word_lowercase
  validates_presence_of :class_word
  validates_uniqueness_of :class_word

  include Changeable

  # String constants for error messages -- Cantina-CMH 6/2/10
  ERROR_UNAUTHORIZED = "You are not allowed to modify this class."
  ERROR_REMOVE_TEACHER_LAST_TEACHER = "You cannot remove the last teacher from this class."
  #ERROR_REMOVE_TEACHER_CURRENT_USER = "You cannot remove yourself from this class."

  # JavaScript confirm messages -- Cantina-CMH 6/9/10
  def self.WARNING_REMOVE_TEACHER_CURRENT_USER(clazz_name)
    "This action will remove YOU from the class: #{clazz_name}.\n\nIf you remove yourself, you will lose all access to this class. Are you sure you want to do this?"
  end
  def self.CONFIRM_REMOVE_TEACHER(teacher_name, clazz_name)
    "This action will remove the teacher: '#{teacher_name}' from the class: #{clazz_name}. \nAre you sure you want to do this?"
  end

  self.extend SearchableModel

  @@searchable_attributes = %w{name description}

  class <<self
    def default_class
      find_or_create_default_class
    end

    def find_or_create_default_class
      clazz = find :first, :conditions => ['default_class = ?', true || 1]
      if clazz.blank?
        clazz = Portal::Clazz.create :name => "Default Class", :default_class => true, :class_word => "default"
      end
      clazz
    end

    def searchable_attributes
      @@searchable_attributes
    end


    def has_offering
      Portal::Offering.find(:all, :select => 'distinct clazz_id', :include => :clazz).collect {|p| p.clazz}
    end
  end

  def self.find_or_create_by_course_and_section_and_start_date(portal_course,section,start_date)
    raise "argument portal_course was null or empty" unless portal_course && portal_course.id

    if start_date.class != DateTime
      Rails.logger.warn("Found non-dateTime object in find_or_create_by_course_and_section_and_start_date")
      start_date = start_date.to_datetime
    end
    found = nil
    clazzes = portal_course.clazzes.select { |clazz| clazz.section == section && clazz.start_time == start_date }
    if clazzes.size > 0
      found = clazzes[0]
      if clazzes.size > 1
        Rails.logger.error("too many clazzes with the same section and start date for #{portal_course.name} (#{clazzes.size})")
      end
    else
      params = {
        :section => section,
        :start_time => start_date,
        :class_word => random_class_word(portal_course),
        :name => portal_course.name
      }
      found = Portal::Clazz.create(params)
      found.save!
      portal_course.clazzes << found
    end
    found
  end

  def self.random_class_word(course)
    string = (0..5).map{ ('a'..'z').to_a[rand(26)] }.join
    "#{course.id}_#{string}"
  end

  def title
    semester_name = semester ? semester.name : 'unknown'
    "Class: #{name}, Semester: #{semester_name}"
  end

  # for the accordion display
  def children
    # return students
    return offerings
  end

  def user
    if self.teacher
      return self.teacher.user
    end
    nil
  end

  # this is for changeable?
  # changeable_mod for multiple teachers
  # alias _changeable? changeable?
  def is_user?(_user)
    teacher = _user.class == User ? _user.portal_teacher : _user
    teachers.include? teacher
  end
  alias is_teacher? is_user?

  def is_student?(_user)
    students.include? _user.portal_student
  end

  # def changeable?(_user)
  #   return true if virtual? && is_user?(_user)
  #   if _user.has_role?('manager','admin','district_admin')
  #     return true
  #   end
  #   return false
  # end
  #
  #
  def parent
    return teacher
  end

  #
  # [:district, :virtual?, :real?].each {|method| delegate method, :to=> :course }

  def district
    if course
      return course.district
    end
    return nil
  end

  def virtual?
    if course
      return course.virtual?
    end
    return true
  end

  def real?
    return (! virtual?)
  end

  def school
    if course
      return course.school
    end
    return nil
  end

  def school_id
    if course
      return course.school_id
    end
    return nil
  end

  # HACK: to support transitioning to multiple teachers.
  def teacher
    self.teachers.first
  end

  # HACK: to support transitioning to multiple teachers.
  def teacher=(_teacher)
    add_teacher(_teacher)
  end

  def has_teacher?(_teacher)
    self.teachers.detect { |t| t.id == _teacher.id }
  end

  def add_teacher(_teacher)
    unless self.has_teacher?(_teacher)
      self.teachers << _teacher
    end
  end

  # This method is used to check whether a user is allowed to remove a specific teacher from this class
  # @attempting_user : User object initiating the request
  # @target_teacher  : Portal::Teacher object to be deleted
  # return values:
  #   nil    : User is allowed to remove this teacher
  #   String : reason why user is not allowed to remove this teacher
  def reason_user_cannot_remove_teacher_from_class(attempting_user, target_teacher)
    # Possible reasons for illegality:
    # - user is not allowed to edit this class at all
    # - user is trying to remove the last teacher from this class
    # - user is trying to remove themselves from this class

    return ERROR_UNAUTHORIZED if attempting_user.nil? || !changeable?(attempting_user)
    return ERROR_REMOVE_TEACHER_LAST_TEACHER if teachers.size == 1
    #return ERROR_REMOVE_TEACHER_CURRENT_USER if target_teacher.user == attempting_user

    nil
  end

  def refresh_saveable_response_objects
    self.offerings.each { |o| o.refresh_saveable_response_objects }
  end
  
  def class_word_lowercase
    self.class_word.downcase! if self.class_word
  end

  def offerings_by_unit
    self.offerings.select{ |o| o.active }.group_by do |offering|
      if offering.runnable.respond_to?(:units) && offering.runnable.units.size > 0
        offering.runnable.units.first.name
      else
        "(not part of a unit)" #TODO: constantize/localize
      end
    end
  end
end
