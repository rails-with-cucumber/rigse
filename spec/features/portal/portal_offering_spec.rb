require File.expand_path('../../../spec_helper', __FILE__)

feature "Portal::Offering" do
  before(:each) do
    generate_default_settings_and_jnlps_with_factories
    @learner = Factory(:full_portal_learner)
    @user = @learner.student.user
    @user.save!
    @user.confirm!
    
    
    # log in as this learner
    visit "/"
    
    within("div.header-login-box") do
      fill_in("Username", :with => @user.login)
      fill_in("Password", :with => 'password')
      click_button("Log In")
    end
  end

  scenario "returns a valid jnlp file" do
    visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
    xml = Nokogiri::XML(page.driver.response.body)
    jnlp_elements = xml.xpath("/jnlp")
    expect(jnlp_elements).not_to be_empty
    main_class = xml.xpath("/jnlp/application-desc/@main-class")
    expect(main_class.text).to eq('org.concord.LaunchJnlp')
  end

  feature "the dynamic jnlp file" do
    scenario "should not be cached" do
      visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)

      headers = page.driver.response.headers
      expect(headers).to have_key 'Pragma'
      # note: there could be multiple pragmas, I'm not sure how that will be returned and wether this will correclty match scenario
      expect(headers['Pragma']).to match "no-cache"
      expect(headers).to have_key 'Cache-Control'
      expect(headers['Cache-Control']).to match "max-age=0"
      expect(headers['Cache-Control']).to match "no-cache"
      expect(headers['Cache-Control']).to match "no-store"
    end

    feature "whose jnlp argument" do
      scenario "points to a config file with a jnlp_session" do
        visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
        jnlp_xml = Nokogiri::XML(page.driver.response.body)
        jnlp_elements = jnlp_xml.xpath("/jnlp")
        expect(jnlp_elements).not_to be_empty
        argument = jnlp_xml.xpath("/jnlp/application-desc/argument")[0]
        expect(argument.text).to match 'config'
        expect(argument.text).to match 'jnlp_session'
      end

      scenario "logs in the student" do
        visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
        jnlp_xml = Nokogiri::XML(page.driver.response.body)
        argument = jnlp_xml.xpath("/jnlp/application-desc/argument/text()")[0]

        page.reset!
        # make sure that worked by checking we are not logged in
        visit "/"
        expect(page).to have_no_content "Welcome"

        # load in the config file
        visit argument
        visit "/"
        expect(page).to have_content "Welcome #{@user.name}"
      end

      scenario "returns a valid config that sets the correct session" do
        visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
        jnlp_xml = Nokogiri::XML(page.driver.response.body)
        config_url = jnlp_xml.xpath("/jnlp/application-desc/argument/text()")[0]
        page.reset!
        visit config_url
        config_xml = Nokogiri::XML(page.driver.response.body)
        cookie_service_node = config_xml.xpath("/java/object[@class='net.sf.sail.emf.launch.HttpCookieServiceImpl']")
        session_cookie_string = cookie_service_node.xpath("void/object/void/string/text()")[1].to_s
        config_session_id = session_cookie_string[/\=([^;]*);/, 1]
        header_session_string = page.driver.response.headers["Set-Cookie"]
        header_session_id = header_session_string[/#{Rails.application.config.session_options[:key]}\=([^;]*);/, 1]
        expect(header_session_id).to eq(config_session_id)
      end

      scenario "should not be cached" do
        visit portal_offering_path(:id => @learner.offering.id, :format => :jnlp)
        jnlp_xml = Nokogiri::XML(page.driver.response.body)
        config_url = jnlp_xml.xpath("/jnlp/application-desc/argument/text()")[0]
        visit config_url
        headers = page.driver.response.headers
        expect(headers).to have_key 'Pragma'
        # note: there could be multiple pragmas, I'm not sure how that will be returned and wether this will correclty match it
        expect(headers['Pragma']).to match "no-cache"
        expect(headers).to have_key 'Cache-Control'
        expect(headers['Cache-Control']).to match "max-age=0"
        expect(headers['Cache-Control']).to match "no-cache"
        expect(headers['Cache-Control']).to match "no-store"
      end
    end
  end
end
