require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ExternalUser do
  before(:each) do
    @valid_attributes = {
      :external_user_domain_id => 1,
    }
  end

  it "should create a new instance given valid attributes" do
    pending "Broken example"
    ExternalUser.create!(@valid_attributes)
  end
end
