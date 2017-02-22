require File.expand_path('../../../spec_helper', __FILE__)

describe OtrunkExample::OtmlCategoriesController do

  def mock_otml_category(stubs={})
    unless stubs.empty?
      stubs.each do |key, value|
        allow(@mock_otml_category).to receive(key).and_return(value)
      end
    end
    @mock_otml_category
  end
  
  before(:each) do
    generate_default_settings_and_jnlps_with_mocks
    generate_otrunk_example_with_mocks
    logout_user
  end
  
  describe "GET index" do

    it "exposes all otrunk_example_otml_categories as @otrunk_example_otml_categories" do
      expect(OtrunkExample::OtmlCategory).to receive(:all).and_return([mock_otml_category])
      get :index
      expect(assigns[:otrunk_example_otml_categories]).to eq([mock_otml_category])
    end

    describe "with mime type of xml" do
  
      it "renders all otrunk_example_otml_categories as xml" do
        expect(OtrunkExample::OtmlCategory).to receive(:all).and_return(otml_categories = double("Array of OtrunkExample::OtmlCategories"))
        expect(otml_categories).to receive(:to_xml).and_return("generated XML")
        get :index, :format => 'xml'
        expect(response.body).to eq("generated XML")
      end
    
    end

  end

  describe "GET show" do

    it "exposes the requested otml_category as @otml_category" do
      expect(OtrunkExample::OtmlCategory).to receive(:find).with("37").and_return(mock_otml_category)
      get :show, :id => "37"
      expect(assigns[:otml_category]).to equal(mock_otml_category)
    end
    
    describe "with mime type of xml" do

      it "renders the requested otml_category as xml" do
        expect(OtrunkExample::OtmlCategory).to receive(:find).with("37").and_return(mock_otml_category)
        expect(mock_otml_category).to receive(:to_xml).and_return("generated XML")
        get :show, :id => "37", :format => 'xml'
        expect(response.body).to eq("generated XML")
      end

    end
    
  end

  describe "GET new" do
  
    it "exposes a new otml_category as @otml_category" do
      expect(OtrunkExample::OtmlCategory).to receive(:new).and_return(mock_otml_category)
      get :new
      expect(assigns[:otml_category]).to equal(mock_otml_category)
    end

  end

  describe "GET edit" do
  
    it "exposes the requested otml_category as @otml_category" do
      expect(OtrunkExample::OtmlCategory).to receive(:find).with("37").and_return(mock_otml_category)
      get :edit, :id => "37"
      expect(assigns[:otml_category]).to equal(mock_otml_category)
    end

  end

  describe "POST create" do

    describe "with valid params" do
      
      it "exposes a newly created otml_category as @otml_category" do
        expect(OtrunkExample::OtmlCategory).to receive(:new).with({'these' => 'params'}).and_return(mock_otml_category(:save => true))
        post :create, :otml_category => {:these => 'params'}
        expect(assigns(:otml_category)).to equal(mock_otml_category)
      end

      it "redirects to the created otml_category" do
        allow(OtrunkExample::OtmlCategory).to receive(:new).and_return(mock_otml_category(:save => true))
        post :create, :otml_category => {}
        expect(response).to redirect_to(otrunk_example_otml_category_url(mock_otml_category))
      end
      
    end
    
    describe "with invalid params" do

      it "exposes a newly created but unsaved otml_category as @otml_category" do
        allow(OtrunkExample::OtmlCategory).to receive(:new).with({'these' => 'params'}).and_return(mock_otml_category(:save => false))
        post :create, :otml_category => {:these => 'params'}
        expect(assigns(:otml_category)).to equal(mock_otml_category)
      end

      it "re-renders the 'new' template" do
        allow(OtrunkExample::OtmlCategory).to receive(:new).and_return(mock_otml_category(:save => false))
        post :create, :otml_category => {}
        expect(response).to render_template('new')
      end
      
    end
    
  end

  describe "PUT udpate" do

    describe "with valid params" do

      it "updates the requested otml_category" do
        expect(OtrunkExample::OtmlCategory).to receive(:find).with("37").and_return(mock_otml_category)
        expect(mock_otml_category).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otml_category => {:these => 'params'}
      end

      it "exposes the requested otml_category as @otml_category" do
        allow(OtrunkExample::OtmlCategory).to receive(:find).and_return(mock_otml_category(:update_attributes => true))
        put :update, :id => "1"
        expect(assigns(:otml_category)).to equal(mock_otml_category)
      end

      it "redirects to the otml_category" do
        allow(OtrunkExample::OtmlCategory).to receive(:find).and_return(mock_otml_category(:update_attributes => true))
        put :update, :id => "1"
        expect(response).to redirect_to(otrunk_example_otml_category_url(mock_otml_category))
      end

    end
    
    describe "with invalid params" do

      it "updates the requested otml_category" do
        expect(OtrunkExample::OtmlCategory).to receive(:find).with("37").and_return(mock_otml_category)
        expect(mock_otml_category).to receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :otml_category => {:these => 'params'}
      end

      it "exposes the otml_category as @otml_category" do
        allow(OtrunkExample::OtmlCategory).to receive(:find).and_return(mock_otml_category(:update_attributes => false))
        put :update, :id => "1"
        expect(assigns(:otml_category)).to equal(mock_otml_category)
      end

      it "re-renders the 'edit' template" do
        allow(OtrunkExample::OtmlCategory).to receive(:find).and_return(mock_otml_category(:update_attributes => false))
        put :update, :id => "1"
        expect(response).to render_template('edit')
      end

    end

  end

  describe "DELETE destroy" do

    it "destroys the requested otml_category" do
      expect(OtrunkExample::OtmlCategory).to receive(:find).with("37").and_return(mock_otml_category)
      expect(mock_otml_category).to receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "redirects to the otrunk_example_otml_categories list" do
      allow(OtrunkExample::OtmlCategory).to receive(:find).and_return(mock_otml_category(:destroy => true))
      delete :destroy, :id => "1"
      expect(response).to redirect_to(otrunk_example_otml_categories_url)
    end

  end

end
