class ActivitiesController < ApplicationController
  # unfortunately theme support doesn't correctly handle automatically finding layouts with the
  # same name as the controller, so we need to explicitly specify it here
  layout 'activities'

  toggle_controller_for :activities
  # GET /pages
  # GET /pages.xml
  prawnto :prawn=>{
    :page_layout=>:landscape,
  }
  before_filter :setup_object, :except => [:index,:browse]
  before_filter :render_scope, :only => [:show,:compare]
  # editing / modifying / deleting require editable-ness
  before_filter :can_edit, :except => [:index,:search,:browse  ,:show,:print,:create,:new,:duplicate,:export,:export_json,:compare]
  before_filter :can_create, :only => [:new, :create,:duplicate]

  include RestrictedController
  before_filter :manager_or_researcher, :only => [:compare]

  in_place_edit_for :activity, :name
  in_place_edit_for :activity, :description

  cache_sweeper :runnable_sweeper, :only => [:create, :update, :destroy]

  protected

  def can_create
    if (current_user.anonymous?)
      flash[:error] = "Anonymous users can not create activities"
      redirect_back_or activities_path
    end
  end

  def render_scope
    @render_scope = @activity
  end

  def can_edit
    if defined? @activity
      unless @activity.changeable?(current_user)
        error_message = "you (#{current_user.login}) can not #{action_name.humanize} #{@activity.name}"
        flash[:error] = error_message
        if request.xhr?
          render :text => "<div class='flash_error'>#{error_message}</div>"
        else
          redirect_back_or activities_path
        end
      end
    end
  end


  def setup_object
    if params[:id]
      if params[:id].length == 36
        @activity = Activity.find(:first, :conditions => ['uuid=?',params[:id]])
      else
        @activity = Activity.find(params[:id])
      end
    elsif params[:activity]
      @activity = Activity.new(params[:activity])
    else
      @activity = Activity.new
    end
    format = request.parameters[:format]
    unless format == 'otml' || format == 'jnlp'
      if @activity
        @page_title = @activity.name
        @investigation = @activity.investigation
      end
    end
  end

  public

  def index
    @lightweight_only = (params[:lightweight_only] ? true : false)
    # all the logic here is currently handled through the activities/_runnable_list which hands it off to
    # to tag_defaults#list_bins
  end

  def search
    @include_drafts = params[:include_drafts]
    @name = params[:name]
    @grade_levels = params[:grade_levels] || []
    @subject_areas = params[:subject_areas] || []
    @sensors = params[:sensors] || []
    pagenation = params[:page]
    search_list_params = {
      :name => @name,
      :include_drafts => @include_drafts,
      :paginate => true,
      :page => pagenation
    }
    search_list_params[:grade_levels] = @grade_levels if @grade_levels && @grade_levels.size > 0
    search_list_params[:subject_areas] = @subject_areas if @subject_areas && @subject_areas.size > 0
    search_list_params[:sensors] = @sensors if @sensors && @sensors.size > 0
    @activities = Activity.search_list(search_list_params)
    if params[:mine_only]
      @activities = @activities.reject { |i| i.user.id != current_user.id }
    end

    @filter_params = {:include_drafts => @include_drafts, :name => @name}

  end

  def browse
    # @activities = Activity.find(:all)
    subjects = Activity.tag_counts_on(:subject_areas).map { |tc| tc.name }
    grade_levels = Activity.tag_counts_on(:grade_levels).map { |tc| tc.name }
    @search_results = {}
    @key_strings = []
    @units = []
    @selection = params[:selection]
    grade_levels.reject{|level| level =~ /probe|math/i}.uniq.sort.each do |grade_level|
      subjects.uniq.sort.each do |subject|
        key_string = "#{grade_level} : #{subject}"
        unless @search_results[key_string]
          @search_results[key_string] = {}
        end
        @activities = Activity.published.tagged_with(grade_level, :on=>:grade_levels).tagged_with(subject, :on=> :subject_areas)
        if @activities.size > 0
          @key_strings << key_string
        end
        @activities.sort!{ |a,b| a.name <=> b.name}
        @activities.each do |activity|
          activity.unit_list.sort.each do |unit|
            @units << unit  
            unless @search_results[key_string][unit]
              @search_results[key_string][unit] = []
            end
            @search_results[key_string][unit] << activity
          end
        end
      end
    end
    @key_strings.sort!
    @selection ||= @key_strings.first
    @units.sort!
    @key_strings.sort!
  end
 
  def template_edit
    @teacher_mode = params[:teacher_mode] || false
    @inside_template_edit = true
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @teacher_mode = params[:teacher_mode] || @activity.teacher_only
    respond_to do |format|
      format.html {
        if params['print']
          render :print, :layout => "layouts/print"
        end
      }
      format.run_html   { render :show, :layout => "layouts/run" }
      format.jnlp   {
        render :partial => 'shared/installer', :locals => { :runnable => @activity, :teacher_mode => @teacher_mode }
      }
      format.config { render :partial => 'shared/show', :locals => { :runnable => @activity, :teacher_mode => @teacher_mode, :session_id => (params[:session] || request.env["rack.session.options"][:id]) } }
      format.dynamic_otml {
        learner = (params[:learner_id] ? Portal::Learner.find(params[:learner_id]) : nil)
        if learner && learner.bundle_logger.in_progress_bundle
          launch_event = Dataservice::LaunchProcessEvent.create(
            :event_type => Dataservice::LaunchProcessEvent::TYPES[:activity_otml_requested],
            :event_details => "Activity content loaded. Activity should now be running...",
            :bundle_content => learner.bundle_logger.in_progress_bundle
          )
        end
        render :partial => 'shared/show', :locals => {:runnable => @activity, :teacher_mode => @teacher_mode}
      }
      format.otml { render :layout => 'layouts/activity' } # activity.otml.haml
      format.xml  { render :xml => @activity }
      format.pdf {render :layout => false }
    end
  end

  # GET /pages/new
  # GET /pages/new.xml
  def new
    @activity = Activity.new
    @activity.user = current_user
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity }
    end
  end

  # GET /pages/1/edit
  def edit
    @activity = Activity.find(params[:id])
    if request.xhr?
      render :partial => 'remote_form', :locals => { :activity => @activity }
    end
  end

  # POST /pages
  # POST /pages.xml
  def create
    @activity = Activity.new(params[:activity])
    @activity.user = current_user
    if params[:activity_template] && (! params[:activity_template].empty?) && @activity.valid?
      # create the new activity from the template
      template = Activity.find(params[:activity_template].to_i)
      @activity = template.copy(current_user)
      @activity.update_attributes(params[:activity])
      @activity.is_template = false
    end

    if params[:update_cohorts]
      # set the cohort tags
      @activity.cohort_list = (params[:cohorts] || [])
    end

    respond_to do |format|
      if @activity.save
        format.js  # render the js file
        flash[:notice] = 'Activity was successfully created.'
        format.html { redirect_to(@activity) }
        format.xml  { render :xml => @activity, :status => :created, :location => @activity }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    cancel = params[:commit] == "Cancel"
    @activity = Activity.find(params[:id])
    if params[:update_cohorts] && !cancel
      # set the cohort tags
      @activity.cohort_list = (params[:cohorts] || [])
      @activity.save
    end

    if request.xhr?
      if cancel || @activity.update_attributes(params[:activity])
        render :partial => 'shared/activity_header', :locals => { :activity => @activity }
      else
        render :xml => @activity.errors, :status => :unprocessable_entity
      end
    else
      respond_to do |format|
        if @activity.update_attributes(params[:activity])
          flash[:notice] = 'Activity was successfully updated.'
          format.html { redirect_to(@activity) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
        end
      end
    end
  end


  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @activity = Activity.find(params[:id])
    @activity.destroy
    @redirect = params[:redirect]
    respond_to do |format|
      format.html { redirect_back_or(activities_url) }
      format.js
      format.xml  { head :ok }
    end
  end


  ##
  ##
  ##
  def add_section
    @section = Section.create
    @section.activity = @activity
    @section.user = current_user
    @section.save
    redirect_to @section
  end

  ##
  ##
  ##
  def sort_sections
    paramlistname = params[:list_name].nil? ? 'activity_sections_list' : params[:list_name]
    @activity = Activity.find(params[:id], :include => :sections)
    @activity.sections.each do |section|
      section.position = params[paramlistname].index(section.id.to_s) + 1
      section.save
    end
    render :nothing => true
  end

  ##
  ##
  ##
  def delete_section
    @section= Section.find(params['section_id'])
    @section.destroy
  end

  ##
  ##
  ##
  def duplicate
    @original = Activity.find(params['id'])
    if @original
      @activity = @original.copy(current_user)
      @activity.save
      flash[:notice] ="Copied #{@original.name}"
      redirect_to url_for(@activity)
    end
  end

  #
  # Construct a link suitable for a 'paste' action in this controller.
  #
  def paste_link
    render :partial => 'shared/paste_link', :locals =>{:types => ['section'],:params => params}
  end

  #
  # In an Activities controller, we only accept section clipboard data,
  #
  def paste
    if @activity.changeable?(current_user)
      @original = clipboard_object(params)
      if (@original)
        @component = @original.clone :use_dictionary => true, :never_clone => [:uuid, :updated_at,:created_at], :include => {:pages => {:page_elements => :embeddable}}
        if (@component)
          # @component.original = @original
          @container = params[:container] || 'activity_sections_list'
          @component.name = "copy of #{@component.name}"
          @component.deep_set_user current_user
          @component.activity = @activity
          @component.save
        end
      end
    end
    render :update do |page|
      page.insert_html :bottom, @container, render(:partial => 'section_list_item', :locals => {:section => @component})
      page.sortable :activity_sections_list, :handle=> 'sort-handle', :dropOnEmpty => true, :url=> {:action => 'sort_sections', :params => {:activity_id => @activity.id }}
      page[dom_id_for(@component, :item)].scrollTo()
      page.visual_effect :highlight, dom_id_for(@component, :item)
    end
  end

  def export
    respond_to do |format|
      format.xml  {
        send_data @activity.deep_xml, :type => :xml, :filename=>"#{@activity.name}.xml"
      }
    end
  end

  def export_as_lara_activity
    if logged_in? && current_user.has_role?("admin")
      activity_json = export_json
      send_data activity_json.to_json, :type => :json, :disposition => "attachment", :filename => "#{@activity.name}_version_1.json"
    else
      flash[:error] = "You're not authorized to do this"
      redirect_to(:back)
    end
  end

  def export_all_activity_urls
    base_path = "#{request.protocol}#{request.host_with_port}/activities/"
    if logged_in? && current_user.has_role?("admin")
      data = []
      #add activites
      exportables = Activity.find(:all, :conditions => {:publication_status => ["published","private","archived"]})
      exportables.each do |exportable|
        data << {
          :activity_id => exportable.id,
          :activity_name => exportable.name, 
          :activity_url => "#{base_path}#{exportable.id}"
        }
      end
      # all tests
      pages = Page.find(:all, :conditions => {:publication_status => ["published","private"]})
      pages.each do |page|
        exportable = page.activity
        if exportable
          data << {
            :activity_id => exportable.id, 
            :activity_name => exportable.name, 
            :activity_url => "#{base_path}#{exportable.id}",
            :page_id => page.id
          }
        end
      end
      filename = "activity_urls.json"
      send_data data.to_json,
        :filename => filename,
        :type => "application/json",
        :x_sendfile => true
    else
      flash[:alert] = "You're not authorized to do this"
      redirect_to(:back)
    end
  end

  def export_json
    activity_json = @activity.export_as_lara_activity(params)
    activity_json[:layout] = 1
    respond_to do |format|
      format.json  { render :json => activity_json }
    end
    activity_json
  end

  def compare
    @other_activity = Activity.find(params[:other_id])
    left, @order = ITSI::Comparison.activity_hash_with_ordering(@activity)
    right = ITSI::Comparison.activity_hash(@other_activity)
    @comparer = Diff::Comparison::Comparer.new(left, right)
    @score = @comparer.score(Diff::Comparison::Rubric.new, {:html_left => true, :html_right => true})
    @differences = @comparer.differences

    @extra_data = []
    # @extra_data.push({:key => '', :value => '', :other_value => ''})
    @extra_data.push({:key => '', :value => @template.link_to('Show', polymorphic_path(@activity)), :other_value => @template.link_to('Show', polymorphic_path(@other_activity)) })
    @extra_data.push({:key => 'ID', :value => @activity.id, :other_value => @other_activity.id})
    @extra_data.push({:key => 'Created', :value => @activity.created_at, :other_value => @other_activity.created_at})
    @extra_data.push({:key => 'Last Modified', :value => @activity.last_modified, :other_value => @other_activity.last_modified})
    @extra_data.push({:key => 'Author', :value => "#{@activity.user.name_and_login} [#{@activity.user.id}]", :other_value => "#{@other_activity.user.name_and_login} [#{@other_activity.user.id}]"})

    render :layout => 'layouts/compare'
  end

end
