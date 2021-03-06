class Portal::GradeLevelsController < ApplicationController
  include RestrictedPortalController
  # PUNDIT_CHECK_FILTERS
  before_filter :admin_only
  public
  
  # GET /portal_grade_levels
  # GET /portal_grade_levels.xml
  def index
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::GradeLevel
    # PUNDIT_REVIEW_SCOPE
    # PUNDIT_CHECK_SCOPE (did not find instance)
    # @grade_levels = policy_scope(Portal::GradeLevel)
    @portal_grade_levels = Portal::GradeLevel.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @portal_grade_levels }
    end
  end

  # GET /portal_grade_levels/1
  # GET /portal_grade_levels/1.xml
  def show
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @grade_level
    @portal_grade_level = Portal::GradeLevel.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @portal_grade_level }
    end
  end

  # GET /portal_grade_levels/new
  # GET /portal_grade_levels/new.xml
  def new
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::GradeLevel
    @portal_grade_level = Portal::GradeLevel.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @portal_grade_level }
    end
  end

  # GET /portal_grade_levels/1/edit
  def edit
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @grade_level
    @portal_grade_level = Portal::GradeLevel.find(params[:id])
  end

  # POST /portal_grade_levels
  # POST /portal_grade_levels.xml
  def create
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE
    # authorize Portal::GradeLevel
    @portal_grade_level = Portal::GradeLevel.new(params[:portal_grade_level])

    respond_to do |format|
      if @portal_grade_level.save
        flash[:notice] = 'Portal::GradeLevel was successfully created.'
        format.html { redirect_to(@portal_grade_level) }
        format.xml  { render :xml => @portal_grade_level, :status => :created, :location => @portal_grade_level }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @portal_grade_level.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /portal_grade_levels/1
  # PUT /portal_grade_levels/1.xml
  def update
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @grade_level
    @portal_grade_level = Portal::GradeLevel.find(params[:id])

    respond_to do |format|
      if @portal_grade_level.update_attributes(params[:portal_grade_level])
        flash[:notice] = 'Portal::GradeLevel was successfully updated.'
        format.html { redirect_to(@portal_grade_level) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @portal_grade_level.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /portal_grade_levels/1
  # DELETE /portal_grade_levels/1.xml
  def destroy
    # PUNDIT_REVIEW_AUTHORIZE
    # PUNDIT_CHECK_AUTHORIZE (did not find instance)
    # authorize @grade_level
    @portal_grade_level = Portal::GradeLevel.find(params[:id])
    @portal_grade_level.destroy

    respond_to do |format|
      format.html { redirect_to(portal_grade_levels_url) }
      format.xml  { head :ok }
    end
  end
end
