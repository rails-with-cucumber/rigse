class ImportUsers < Struct.new(:import_id)
  def perform
    import = Import.find(import_id)
    content_hash = JSON.parse(import.upload_data, :symbolize_names => true)
    total_users_count = content_hash[:users].size
    batch_size = 500
    total_batches = (total_users_count/batch_size.to_f).ceil
    start_index = 0
    end_index = batch_size - 1
    importing_portal = ImportingPortal.find(:first, :conditions => {:portal_url => content_hash[:portal_name]})
    importing_portal = importing_portal || ImportingPortal.create({:portal_url => content_hash[:portal_name]})
    import.update_attribute(:total_imports, total_users_count)
    
    0.upto(total_batches-1){|batch_index|
      start_index = batch_index * batch_size
      end_index = (batch_index == total_batches - 1)? (total_users_count - 1) : (start_index + batch_size - 1)
      ActiveRecord::Base.transaction do
        start_index.upto(end_index){|index|
          user = content_hash[:users][index]
          new_user = User.find_by_email(user[:email])
          unless new_user
            new_user = User.find_by_login(user[:login])
            duplicate_user = nil
            if new_user
              new_index = ImportDuplicateUser.find_all_by_login(user[:login]).count + 1
              user[:login] = "#{user[:login]}-#{new_index}"
              duplicate_user = ImportDuplicateUser.create({
                :login => user[:login],
                :email => user[:email],
                :duplicate_by => ImportDuplicateUser::DUPLICATE_BY_LOGIN_AND_EMAIL,
                :data => user,
                :import_id => import.id
              })
            end
            new_user = User.create({
              :email => user[:email],
              :login => user[:login],
              :last_name => user[:last_name],
              :first_name => user[:first_name],
              :password => "password", #default password
              :password_confirmation => "password",
              :require_password_reset => true
            }){|u| u.skip_notifications = true}
            new_user.confirm!
            user[:roles].each do |role|
              new_user.add_role(role)
            end
            new_user.imported_user = ImportedUser.create({
              :user_url => user[:user_page_url],
              :importing_portal_id => importing_portal.id
            })
            if user[:teacher]
              if user[:school]
                if user[:school][:url]
                  user_school_map = ImportUserSchoolMapping.find(:first, :conditions => {:import_school_url => user[:school][:url]})
                  if user_school_map
                    school = Portal::School.find(:first, :conditions => {:id => user_school_map.school_id})
                  end
                end
              end
              portal_teacher = Portal::Teacher.new 
              portal_teacher.user = new_user
              portal_teacher.schools << school if school
              user[:cohorts].each do |cohort|
                portal_teacher.cohort_list.add(cohort)
              end
              portal_teacher.save!
            end
            if duplicate_user
              duplicate_user.user_id = new_user.id
              duplicate_user.save!
            end
          else
            duplicate_by = new_user.login == user[:login] ? ImportDuplicateUser::DUPLICATE_BY_LOGIN_AND_EMAIL : ImportDuplicateUser::DUPLICATE_BY_EMAIL
            ImportDuplicateUser.create({
              :login => user[:login], 
              :email => user[:email], 
              :duplicate_by => duplicate_by, 
              :data => user.to_json,
              :import_id => import.id
            })
          end
          import.update_attribute(:progress, (index + 1))
        }
      end
    }
    import.update_attribute(:job_finished_at, Time.current)
  end

  def error(job, exception)
    job.destroy
    import = Import.find(import_id)
    import.update_attribute(:progress, -1)
  end
end