require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AssessmentTargetsController do

  def mock_assessment_target(stubs={})
    @mock_assessment_target ||= mock_model(AssessmentTarget, stubs)
  end

  before(:each) do
    #mock_project #FIXME: mock_project is undefined!
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @assessment_targets" do
      pending "Broken example"
      AssessmentTarget.should_receive(:find).with(:all, hash_including(will_paginate_params)).and_return([mock_assessment_target])
      get :index
      assigns[:assessment_targets].should == [mock_assessment_target]
    end

    describe "with mime type of xml" do
  
      it "should render all assessment_targets as xml" do
        pending "Broken example"
        request.env["HTTP_ACCEPT"] = "application/xml"
        AssessmentTarget.should_receive(:find).with(:all).and_return(assessment_targets = mock("Array of AssessmentTargets"))
        assessment_targets.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested assessment_target as @assessment_target" do
      pending "Broken example"
      AssessmentTarget.should_receive(:find).with("37").and_return(mock_assessment_target)
      get :show, :id => "37"
      assigns[:assessment_target].should equal(mock_assessment_target)
    end
    
    describe "with mime type of xml" do

      it "should render the requested assessment_target as xml" do
        pending "Broken example"
        request.env["HTTP_ACCEPT"] = "application/xml"
        AssessmentTarget.should_receive(:find).with("37").and_return(mock_assessment_target)
        mock_assessment_target.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new assessment_target as @assessment_target" do
      pending "Broken example"
      AssessmentTarget.should_receive(:new).and_return(mock_assessment_target)
      get :new
      assigns[:assessment_target].should equal(mock_assessment_target)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested assessment_target as @assessment_target" do
      pending "Broken example"
      AssessmentTarget.should_receive(:find).with("37").and_return(mock_assessment_target)
      get :edit, :id => "37"
      assigns[:assessment_target].should equal(mock_assessment_target)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created assessment_target as @assessment_target" do
        pending "Broken example"
        AssessmentTarget.should_receive(:new).with({'these' => 'params'}).and_return(mock_assessment_target(:save => true))
        post :create, :assessment_target => {:these => 'params'}
        assigns(:assessment_target).should equal(mock_assessment_target)
      end

      it "should redirect to the created assessment_target" do
        pending "Broken example"
        AssessmentTarget.stub!(:new).and_return(mock_assessment_target(:save => true))
        post :create, :assessment_target => {}
        response.should redirect_to(assessment_target_url(mock_assessment_target))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved assessment_target as @assessment_target" do
        pending "Broken example"
        AssessmentTarget.stub!(:new).with({'these' => 'params'}).and_return(mock_assessment_target(:save => false))
        post :create, :assessment_target => {:these => 'params'}
        assigns(:assessment_target).should equal(mock_assessment_target)
      end

      it "should re-render the 'new' template" do
        pending "Broken example"
        AssessmentTarget.stub!(:new).and_return(mock_assessment_target(:save => false))
        post :create, :assessment_target => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested assessment_target" do
        pending "Broken example"
        AssessmentTarget.should_receive(:find).with("37").and_return(mock_assessment_target)
        mock_assessment_target.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :assessment_target => {:these => 'params'}
      end

      it "should expose the requested assessment_target as @assessment_target" do
        pending "Broken example"
        AssessmentTarget.stub!(:find).and_return(mock_assessment_target(:update_attributes => true))
        put :update, :id => "1"
        assigns(:assessment_target).should equal(mock_assessment_target)
      end

      it "should redirect to the assessment_target" do
        pending "Broken example"
        AssessmentTarget.stub!(:find).and_return(mock_assessment_target(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(assessment_target_url(mock_assessment_target))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested assessment_target" do
        pending "Broken example"
        AssessmentTarget.should_receive(:find).with("37").and_return(mock_assessment_target)
        mock_assessment_target.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :assessment_target => {:these => 'params'}
      end

      it "should expose the assessment_target as @assessment_target" do
        pending "Broken example"
        AssessmentTarget.stub!(:find).and_return(mock_assessment_target(:update_attributes => false))
        put :update, :id => "1"
        assigns(:assessment_target).should equal(mock_assessment_target)
      end

      it "should re-render the 'edit' template" do
        pending "Broken example"
        AssessmentTarget.stub!(:find).and_return(mock_assessment_target(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested assessment_target" do
      pending "Broken example"
      AssessmentTarget.should_receive(:find).with("37").and_return(mock_assessment_target)
      mock_assessment_target.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the assessment_targets list" do
      pending "Broken example"
      AssessmentTarget.stub!(:find).and_return(mock_assessment_target(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(assessment_targets_url)
    end

  end

end
