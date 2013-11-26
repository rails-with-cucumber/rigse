require File.expand_path('../../spec_helper', __FILE__)

describe Activity do
  let (:valid_attributes) { {
    :name => "test activity",
    :description => "new decription"
  } }
  let (:activity) { FactoryGirl.create(:activity, valid_attributes) }

  it "should create a new instance given valid attributes" do
    activity.valid?
  end

  it 'should respond to #material_type' do
    activity.material_type.should == 'Activity'
  end

  it "should be destroy'able" do
    activity.destroy
  end

  it 'has_many for all BASE_EMBEDDABLES' do
    BASE_EMBEDDABLES.length.should be > 0
    BASE_EMBEDDABLES.each do |e|
      activity.respond_to?(e[/::(\w+)$/, 1].underscore.pluralize).should be(true)
    end
  end

  describe "should be publishable" do
    it "should not be public by default" do
      activity.published?.should be(false)
    end
    it "should be public if published" do
      activity.publish!
      activity.public?.should be(true)
    end
    
    it "should not be public if unpublished " do
      activity.publish!
      activity.public?.should be(true)
      activity.un_publish!
      activity.public?.should_not be(true)
    end
  end

  describe "search_list (searching for activity)" do
    # Preserving these "let" blocks temporarily in case we need them to set up a structure to test elsewhere - pjm 2013/10/08
    let (:bio) { Factory.create( :rigse_domain, { :name => "biology" } ) }
    let (:seven) { "7" }
    let (:eight) { "8" }

    let (:bio_ks) { Factory.create( :rigse_knowledge_statement, { :domain => bio } ) }
    let (:bio_at) { Factory.create( :rigse_assessment_target, { :knowledge_statement => bio_ks } ) }

    let (:physics) { Factory.create( :rigse_domain, { :name => "physics" } ) }
    let (:physics_ks) { Factory.create( :rigse_knowledge_statement, { :domain => physics } ) }
    let (:physics_at) { Factory.create( :rigse_assessment_target, { :knowledge_statement => physics_ks }) }

    let (:physics_gse_grade7) { Factory.create( :rigse_grade_span_expectation, { :assessment_target => physics_at, :grade_span => seven } ) }
    let (:physics_gse_grade8) { Factory.create( :rigse_grade_span_expectation, { :assessment_target => physics_at, :grade_span => eight } ) }

    let (:bio_gse_grade7)     { Factory.create( :rigse_grade_span_expectation, { :assessment_target => bio_at, :grade_span => seven } ) }
    let (:bio_gse_grade8)     { Factory.create( :rigse_grade_span_expectation, { :assessment_target => bio_at, :grade_span => eight } ) }

    let (:invs) do
      [
        {
          :name                   => "grade 7 physics",
          :grade_span_expectation => physics_gse_grade7
        },
        {
          :name                   => "grade 8 physics",
          :grade_span_expectation => physics_gse_grade8
        },
        {
          :name                   => "grade 7 bio",
          :grade_span_expectation => bio_gse_grade7
        },
        {
          :name                   => "grade 8 bio",
          :grade_span_expectation => bio_gse_grade8
        },
      ]
    end

    let (:published) do
      pub = []
      invs.each do |inv|
        investigation = Factory.create(:investigation, inv)
        investigation.name << " (published) "
        investigation.publish!
        investigation.save
        pub << investigation.reload
      end
      pub
    end

    let (:drafts) do
      dra = []
      published.each do |inv|
        published_activity = Factory.create(:activity, :name => "activity for #{inv.name}" ,:investigation_id => inv.id)
        draft = Factory.create(:investigation, :name => inv.name, :grade_span_expectation => inv.grade_span_expectation)
        draft.name << " (draft) "
        draft.save
        dra << draft.reload
        drafts_activity = Factory.create(:activity, :name => "activity for #{draft.name}" ,:investigation_id => draft.id)
      end
      dra
    end

    let (:public_non_gse)          { Factory.create(:investigation, :name => "published non-gse investigation", :publication_status => 'Published') }
    let (:public_non_gse_activity) { Factory.create(:activity, :name => "activity for #{public_non_gse.name}" ,:investigation_id => public_non_gse.id) }
    let (:draft_non_gse)           { Factory.create(:investigation, :name => "draft non-gse investigation") } 
    let (:draft_non_gse_activity)  { Factory.create(:activity, :name => "activity for #{draft_non_gse.name}" ,:investigation_id => draft_non_gse.id) }

    #creating probe activities
    let (:investigation)            { Investigation.find_by_name_and_publication_status('grade 7 physics', 'published') }
    let (:probe_activity_published) { Factory.create(:activity, :name => 'probe_activity(published)', :publication_status => 'Published') }

    let (:section)      { Factory.create(:section, :activity_id => probe_activity_published.id) }
    let (:page)         { Factory.create(:page, :section_id => section.id) }
    let (:probe_type)   { Factory.create(:probe_type) }
    let (:embeddable_data_collectors) { Factory.create(:data_collector, :probe_type => probe_type) }
    let (:page_element) { Factory.create(:page_element, :page => page, :embeddable => embeddable_data_collectors) }
  end

  describe "#is_template" do
    let (:investigation_with_template)    { mock_model(Investigation, :is_template =>true)}
    let (:investigation_without_template) { mock_model(Investigation, :is_template =>false)}
    let (:investigation) { nil }
    let (:is_template)   { false }
    subject do
      s = Factory.create(:activity, :is_template => is_template)
      s.stub!(:investigation => investigation)
      s.is_template
    end

    describe "when the attribute is_template is true" do
      let(:is_template) { true }
      it { should be_true}
    end
    describe "when the attribute is_template is false" do
      let(:is_template) { false }
      it { should be_false}

      describe "when the activity has an investigation" do
        describe "that is a template" do
          let(:investigation) { investigation_with_template }
          it { should be_true }
        end
        describe "that is not a template" do
          let(:investigation) { investigation_without_template }
          it { should be_false }
        end
      end
    end
  end
end
