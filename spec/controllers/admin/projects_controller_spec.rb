require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe Admin::ProjectsController do
  let(:project) { Factory.create(:project, landing_page_slug: 'foo-proj', landing_page_content: '<h1>Foo</h1>') }
  let(:valid_attributes) { { name: "Some name" } }

  describe 'when user is an admin' do
    before(:each) do
      login_admin
    end

    describe "GET index" do
      it "assigns all projects as @projects" do
        project
        get :index, {}
        assigns(:projects).to_a.should eq([project])
      end
    end

    describe "GET show" do
      it "assigns the requested project as @project" do
        get :show, {:id => project.to_param}
        assigns(:project).should eq(project)
      end
    end

    describe "GET new" do
      it "assigns a new project as @project" do
        get :new, {}
        assigns(:project).should be_a_new(Admin::Project)
      end
    end

    describe "GET edit" do
      it "assigns the requested project as @project" do
        get :edit, {:id => project.to_param}
        assigns(:project).should eq(project)
      end
    end

    describe "POST create" do
      describe "with valid params" do
        it "creates a new Admin::Project" do
          expect {
            post :create, {:admin_project => valid_attributes}
          }.to change(Admin::Project, :count).by(1)
        end

        it "assigns a newly created project as @project" do
          post :create, {:admin_project => valid_attributes}
          assigns(:project).should be_a(Admin::Project)
          assigns(:project).should be_persisted
        end

        it "redirects to the projects index" do
          post :create, {:admin_project => valid_attributes}
          response.should redirect_to(admin_projects_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved project as @project" do
          # Trigger the behavior that occurs when invalid params are submitted
          Admin::Project.any_instance.stub(:save).and_return(false)
          post :create, {:admin_project => valid_attributes}
          assigns(:project).should be_a(Admin::Project)
          assigns(:project).should_not be_persisted
          assigns(:project).should be_a_new(Admin::Project)
        end

        it "re-renders the 'new' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Admin::Project.any_instance.stub(:save).and_return(false)
          post :create, {:admin_project => valid_attributes}
          response.should render_template(:new)
        end
      end
    end

    describe "PUT update" do
      describe "with valid params" do
        it "updates the requested project" do
          # Assuming there are no other projects in the database, this
          # specifies that the Admin::Project created on the previous line
          # receives the :update_attributes message with whatever params are
          # submitted in the request.
          Admin::Project.any_instance.should_receive(:update_attributes).with({'name' => 'new name'})
          put :update, {:id => project.to_param, :admin_project => {'name' => 'new name'}}
        end

        it "assigns the requested project as @project" do
          put :update, {:id => project.to_param, :admin_project => valid_attributes}
          assigns(:project).should eq(project)
        end

        it "redirects to the project" do
          put :update, {:id => project.to_param, :admin_project => valid_attributes}
          response.should redirect_to(project)
        end
      end

      describe "with invalid params" do
        it "assigns the project as @project" do
          # Trigger the behavior that occurs when invalid params are submitted
          Admin::Project.any_instance.stub(:save).and_return(false)
          put :update, {:id => project.to_param, :admin_project => valid_attributes}
          assigns(:project).should eq(project)
        end

        it "re-renders the 'edit' template" do
          # Trigger the behavior that occurs when invalid params are submitted
          Admin::Project.any_instance.stub(:save).and_return(false)
          put :update, {:id => project.to_param, :admin_project => valid_attributes}
          response.should render_template("edit")
        end
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested project" do
        project
        expect {
          delete :destroy, {:id => project.to_param}
        }.to change(Admin::Project, :count).by(-1)
      end

      it "redirects to the projects list" do
        delete :destroy, {:id => project.to_param}
        response.should redirect_to(admin_projects_url)
      end
    end
  end

  describe "GET landing page" do
    context "there is a project matching the slug" do
      it "renders landing page template" do
        get :landing_page, {:landing_page_slug => project.landing_page_slug}
        expect(response).to render_template("landing_page")
      end
    end

    context "there is no project matching the slug" do
      it "renders 404" do
        get :landing_page, {:landing_page_slug => "some-slug-which-doesnt-exist"}
        expect(response.status).to eq(404)
      end
    end
  end
end