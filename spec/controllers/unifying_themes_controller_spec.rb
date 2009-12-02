require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UnifyingThemesController do

  def mock_unifying_theme(stubs={})
    @mock_unifying_theme ||= mock_model(UnifyingTheme, stubs)
  end
  
  before(:each) do
    #mock_project #FIXME: mock_project undefined!
    Admin::Project.should_receive(:default_project).and_return(@mock_project)
  end
  
  describe "responding to GET index" do

    it "should expose an array of all the @unifying_themes" do
      pending "Broken example"
      UnifyingTheme.should_receive(:find).with(:all).and_return([mock_unifying_theme])
      get :index
      assigns[:unifying_themes].should == [mock_unifying_theme]
    end

    describe "with mime type of xml" do
  
      it "should render all unifying_themes as xml" do
        pending "Broken example"
        request.env["HTTP_ACCEPT"] = "application/xml"
        UnifyingTheme.should_receive(:find).with(:all).and_return(unifying_themes = mock("Array of UnifyingThemes"))
        unifying_themes.should_receive(:to_xml).and_return("generated XML")
        get :index
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "responding to GET show" do

    it "should expose the requested unifying_theme as @unifying_theme" do
      pending "Broken example"
      UnifyingTheme.should_receive(:find).with("37").and_return(mock_unifying_theme)
      get :show, :id => "37"
      assigns[:unifying_theme].should equal(mock_unifying_theme)
    end
    
    describe "with mime type of xml" do

      it "should render the requested unifying_theme as xml" do
        pending "Broken example"
        request.env["HTTP_ACCEPT"] = "application/xml"
        UnifyingTheme.should_receive(:find).with("37").and_return(mock_unifying_theme)
        mock_unifying_theme.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37"
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "responding to GET new" do
  
    it "should expose a new unifying_theme as @unifying_theme" do
      pending "Broken example"
      UnifyingTheme.should_receive(:new).and_return(mock_unifying_theme)
      get :new
      assigns[:unifying_theme].should equal(mock_unifying_theme)
    end

  end

  describe "responding to GET edit" do
  
    it "should expose the requested unifying_theme as @unifying_theme" do
      pending "Broken example"
      UnifyingTheme.should_receive(:find).with("37").and_return(mock_unifying_theme)
      get :edit, :id => "37"
      assigns[:unifying_theme].should equal(mock_unifying_theme)
    end

  end

  describe "responding to POST create" do

    describe "with valid params" do
      
      it "should expose a newly created unifying_theme as @unifying_theme" do
        pending "Broken example"
        UnifyingTheme.should_receive(:new).with({'these' => 'params'}).and_return(mock_unifying_theme(:save => true))
        post :create, :unifying_theme => {:these => 'params'}
        assigns(:unifying_theme).should equal(mock_unifying_theme)
      end

      it "should redirect to the created unifying_theme" do
        pending "Broken example"
        UnifyingTheme.stub!(:new).and_return(mock_unifying_theme(:save => true))
        post :create, :unifying_theme => {}
        response.should redirect_to(unifying_theme_url(mock_unifying_theme))
      end
      
    end
    
    describe "with invalid params" do

      it "should expose a newly created but unsaved unifying_theme as @unifying_theme" do
        pending "Broken example"
        UnifyingTheme.stub!(:new).with({'these' => 'params'}).and_return(mock_unifying_theme(:save => false))
        post :create, :unifying_theme => {:these => 'params'}
        assigns(:unifying_theme).should equal(mock_unifying_theme)
      end

      it "should re-render the 'new' template" do
        pending "Broken example"
        UnifyingTheme.stub!(:new).and_return(mock_unifying_theme(:save => false))
        post :create, :unifying_theme => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do

    describe "with valid params" do

      it "should update the requested unifying_theme" do
        pending "Broken example"
        UnifyingTheme.should_receive(:find).with("37").and_return(mock_unifying_theme)
        mock_unifying_theme.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :unifying_theme => {:these => 'params'}
      end

      it "should expose the requested unifying_theme as @unifying_theme" do
        pending "Broken example"
        UnifyingTheme.stub!(:find).and_return(mock_unifying_theme(:update_attributes => true))
        put :update, :id => "1"
        assigns(:unifying_theme).should equal(mock_unifying_theme)
      end

      it "should redirect to the unifying_theme" do
        pending "Broken example"
        UnifyingTheme.stub!(:find).and_return(mock_unifying_theme(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(unifying_theme_url(mock_unifying_theme))
      end

    end
    
    describe "with invalid params" do

      it "should update the requested unifying_theme" do
        pending "Broken example"
        UnifyingTheme.should_receive(:find).with("37").and_return(mock_unifying_theme)
        mock_unifying_theme.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :unifying_theme => {:these => 'params'}
      end

      it "should expose the unifying_theme as @unifying_theme" do
        pending "Broken example"
        UnifyingTheme.stub!(:find).and_return(mock_unifying_theme(:update_attributes => false))
        put :update, :id => "1"
        assigns(:unifying_theme).should equal(mock_unifying_theme)
      end

      it "should re-render the 'edit' template" do
        pending "Broken example"
        UnifyingTheme.stub!(:find).and_return(mock_unifying_theme(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested unifying_theme" do
      pending "Broken example"
      UnifyingTheme.should_receive(:find).with("37").and_return(mock_unifying_theme)
      mock_unifying_theme.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the unifying_themes list" do
      pending "Broken example"
      UnifyingTheme.stub!(:find).and_return(mock_unifying_theme(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(unifying_themes_url)
    end

  end

end
