require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/external_user_domains/new.html.erb" do
  include ExternalUserDomainsHelper

  before(:each) do
    assigns[:external_user_domain] = stub_model(ExternalUserDomain,
      :new_record? => true,
      :name => "value for name",
      :description => "value for description",
      :server_url => "value for server_url",
      :uuid => "value for uuid"
    )
  end

  it "renders new external_user_domain form" do
    pending "Broken example"
    render

    response.should have_tag("form[action=?][method=post]", external_user_domains_path) do
      with_tag("input#external_user_domain_name[name=?]", "external_user_domain[name]")
      with_tag("textarea#external_user_domain_description[name=?]", "external_user_domain[description]")
      with_tag("input#external_user_domain_server_url[name=?]", "external_user_domain[server_url]")
      with_tag("input#external_user_domain_uuid[name=?]", "external_user_domain[uuid]")
    end
  end
end
