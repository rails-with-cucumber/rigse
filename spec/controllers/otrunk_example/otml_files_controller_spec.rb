require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../spec_controller_helper')

describe OtrunkExample::OtmlFilesController do

  def mock_otml_file(stubs={})
    @mock_otml_file ||= mock_model(OtrunkExample::OtmlFile, stubs)
  end
  
  describe "GET index" do

    it "exposes all otrunk_example_otml_files as @otrunk_example_otml_files" do
      pending "Broken example"
      OtrunkExample::OtmlFile.should_receive(:find).with(:all).and_return([mock_otml_file])
      get :index
      assigns[:otrunk_example_otml_files].should == [mock_otml_file]
    end

    describe "with mime type of xml" do
  
      it "renders all otrunk_example_otml_files as xml" do
        pending "Broken example"
        OtrunkExample::OtmlFile.should_receive(:find).with(:all).and_return(otml_files = mock("Array of OtrunkExample::OtmlFiles"))
        otml_files.should_receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        response.body.should == "generated XML"
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested otml_file as @otml_file" do
      pending "Broken example"
      OtrunkExample::OtmlFile.should_receive(:find).with("37").and_return(mock_otml_file)
      get :show, :id => "37"
      assigns[:otml_file].should equal(mock_otml_file)
    end
    
    describe "with mime type of xml" do

      it "renders the requested otml_file as xml" do
        pending "Broken example"
        OtrunkExample::OtmlFile.should_receive(:find).with("37").and_return(mock_otml_file)
        mock_otml_file.should_receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        response.body.should == "generated XML"
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new otml_file as @otml_file" do
      pending "Broken example"
      OtrunkExample::OtmlFile.should_receive(:new).and_return(mock_otml_file)
      get :new
      assigns[:otml_file].should equal(mock_otml_file)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested otml_file as @otml_file" do
      pending "Broken example"
      OtrunkExample::OtmlFile.should_receive(:find).with("37").and_return(mock_otml_file)
      get :edit, :id => "37"
      assigns[:otml_file].should equal(mock_otml_file)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created otml_file as @otml_file" do
        pending "Broken example"
        OtrunkExample::OtmlFile.should_receive(:new).with({'these' => 'params'}).and_return(mock_otml_file(:save => true))
        post :create, :otml_file => {:these => 'params'}
        assigns(:otml_file).should equal(mock_otml_file)
      end

      it "redirects to the created otml_file" do
        pending "Broken example"
        OtrunkExample::OtmlFile.stub!(:new).and_return(mock_otml_file(:save => true))
        post :create, :otml_file => {}
        response.should redirect_to(otrunk_example_otml_file_url(mock_otml_file))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved otml_file as @otml_file" do
        pending "Broken example"
        OtrunkExample::OtmlFile.stub!(:new).with({'these' => 'params'}).and_return(mock_otml_file(:save => false))
        post :create, :otml_file => {:these => 'params'}
        assigns(:otml_file).should equal(mock_otml_file)
      end

      it "re-renders the 'new' template" do
        pending "Broken example"
        OtrunkExample::OtmlFile.stub!(:new).and_return(mock_otml_file(:save => false))
        post :create, :otml_file => {}
        response.should render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested otml_file" do
        pending "Broken example"
        OtrunkExample::OtmlFile.should_receive(:find).with("37").and_return(mock_otml_file)
        mock_otml_file.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otml_file => {:these => 'params'}
      end

      it "exposes the requested otml_file as @otml_file" do
        pending "Broken example"
        OtrunkExample::OtmlFile.stub!(:find).and_return(mock_otml_file(:update_attributes => true))
        put :update, :id => "1"
        assigns(:otml_file).should equal(mock_otml_file)
      end

      it "redirects to the otml_file" do
        pending "Broken example"
        OtrunkExample::OtmlFile.stub!(:find).and_return(mock_otml_file(:update_attributes => true))
        put :update, :id => "1"
        response.should redirect_to(otrunk_example_otml_file_url(mock_otml_file))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested otml_file" do
        pending "Broken example"
        OtrunkExample::OtmlFile.should_receive(:find).with("37").and_return(mock_otml_file)
        mock_otml_file.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otml_file => {:these => 'params'}
      end

      it "exposes the otml_file as @otml_file" do
        pending "Broken example"
        OtrunkExample::OtmlFile.stub!(:find).and_return(mock_otml_file(:update_attributes => false))
        put :update, :id => "1"
        assigns(:otml_file).should equal(mock_otml_file)
      end

      it "re-renders the 'edit' template" do
        pending "Broken example"
        OtrunkExample::OtmlFile.stub!(:find).and_return(mock_otml_file(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested otml_file" do
      pending "Broken example"
      OtrunkExample::OtmlFile.should_receive(:find).with("37").and_return(mock_otml_file)
      mock_otml_file.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the otrunk_example_otml_files list" do
      pending "Broken example"
      OtrunkExample::OtmlFile.stub!(:find).and_return(mock_otml_file(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(otrunk_example_otml_files_url)
    end

  end

end
