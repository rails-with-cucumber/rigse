module ApplicationHelper
  include Clipboard
  include Pundit

  def current_settings
    @_settings ||= Admin::Settings.default_settings
  end

  def top_level_container_name
    APP_CONFIG[:top_level_container_name] || "investigation"
  end

  #
  # dom_for_id generates a dom id value for any object that returns an integer when sent an "id" message
  #
  # This helper is normally used with ActiveRecord objects.
  #
  #   @model = Model.find(3)
  #   dom_id_for(@model)                        # => "model_3"
  #   dom_id_for(@model, :item)                 # => "item_model_3"
  #   dom_id_for(@model, :item, :textarea)      # => "item_textarea_model_3"
  #
  #   @scoped_model = OuterScope::InnerScope::Model.find(3)
  #   dom_id_for(@scoped_model)                 # => "outer_scope__inner_scope__model_3"

  def dom_id_for(component, *optional_prefixes)
    optional_prefixes.flatten!
    optional_prefixes.compact! unless optional_prefixes.empty?
    prefix = ''
    optional_prefixes.each { |p| prefix << "#{p.to_s}_" }
    class_name = component.class.name.underscore.clipboardify
    if component.is_a?(ActiveRecord::Base)
      id = component.id || Time.now.to_i
    else
      # this will be a temporary id, so it seems unlikely that these type of ids
      # should be really be generated, however there are some parts of the code
      # calling dom_id_for and passing a form object for example
      id = component.object_id
    end
    id_string = id.to_s
    "#{prefix}#{class_name}_#{id_string}"
  end

  def dom_class_for(component)
    component.class.name.underscore
  end

  def short_name(name)
    name.strip.downcase.gsub(/\W+/, '_')
  end

  def git_repo_info
    # For some strange reason running repo.head during tests sometimes generates this
    # error running the first time: Errno::ECHILD Exception: No child processes
    #
    # The operation seems to work fine the second time ... ?
    # Here's an example from the debugger:
    #
    #   (rdb:1) repo.head
    #   Errno::ECHILD Exception: No child processes
    #   (rdb:1) repo.head
    #   #<Grit::Head "emb-test">
    #
    repo = Grit::Repo.new(".")
    head = nil
    begin
      head = repo.head
    rescue Errno::ECHILD
      begin
        head = repo.head
      rescue Errno::ECHILD
      end
    end
    if head
      branch = head.name
      last_commit = repo.commits(branch).first
      {
        :branch => branch,
        :last_commit => repo.commits(branch).first,
        :short_message => truncate(last_commit.message, :length => 54),
        :href => "http://github.com/concord-consortium/rigse/commit/#{last_commit.id}",
        :short_id => truncate(last_commit.id, :length => 16),
        :name => last_commit.author.name,
        :date => last_commit.authored_date.strftime('%a %b %d %H:%M:%S')
      }
    else
      {}
    end
  end

  def display_repo_info
    if repo = Grit::Repo.new(".")
      branch = repo.head.name
      last_commit = repo.commits(branch).first
      message = last_commit.message
      content_tag('ul', :class => 'tiny menu_h') do
        list = ''
        list << content_tag('li') { branch }
        list << content_tag('li') { "<a title='href='http://github.com/concord-consortium/rigse/commit/#{last_commit.id}'>#{truncate(last_commit.id, :length => 16)}</a>" }
        list << content_tag('li') { last_commit.author.name }
        list << content_tag('li') { last_commit.authored_date.strftime('%a %b %d %H:%M:%S') }
        list << content_tag('li') { truncate(message, :length => 70) }
      end
    end
  end

  def short_format_gse_summary(gse)
    gse.print_summary_data("<div><strong>%s</strong><ul>%s</ul></div>","<li>%s</li>")
  end

  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title_tag(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end

  # Outputs the corresponding flash message if any are set
  def flash_messages
    messages = []
    %w(notice warning error).each do |msg|
      messages << content_tag(:div, html_escape(flash[msg.to_sym]), :id => "flash-#{msg}") unless flash[msg.to_sym].blank?
    end
    messages
  end

  def labeled_check_box(form, field, name=field.to_s.humanize)
    form.label(field, name) + "\n" + form.check_box(field)
  end

  # http://davidwparker.com/2008/11/12/simple-non-model-checkbox-in-rails/
  def check_box_tag_new(name, value = "1", options = {})
    html_options = { "type" => "checkbox", "name" => name, "id" => name, "value" => value }.update(options.stringify_keys)
    unless html_options["check"].nil?
      html_options["checked"] = "checked" if html_options["check"].to_i == 1
    end
    tag :input, html_options
  end

  def pdf_footer(message)
    pdf.footer [pdf.margin_box.left, pdf.margin_box.bottom + 25] do
      pdf.stroke_horizontal_rule
      pdf.pad(10) do
        pdf.text message, :size => 16
      end
    end
  end

  def render_top_level_container_list_partial(locals)
    container = top_level_container_name.pluralize
    container_sym = top_level_container_name.pluralize.to_sym
    container_class = top_level_container_name.classify.constantize
    hide_print = locals.delete(:hide_print) || false
    if container_class.respond_to?(:search_list)
      render :partial => "#{container}/runnable_list", :locals => { container_sym => container_class.search_list(locals), :hide_print => hide_print }
    else
      render :partial => "#{container}/runnable_list", :locals => { container_sym => container_class.all, :hide_print => hide_print }
    end
  end

  def top_level_container_name_as_class_string
    container = top_level_container_name.pluralize
    container_sym = top_level_container_name.pluralize.to_sym
    container_class = top_level_container_name.classify
  end

  def render_partial_for(component,_opts={})
    ## if we're rendering otml, only render if the thing we're rendering hasn't
    ## already been rendered before.
    if self.formats.include?('otml') || self.formats.include?(:otml)
      if already_rendered?(component)
        return ""
      else
        mark_rendered(component)
      end
    end
    class_name = component.class.name.underscore
    demodulized_class_name = component.class.name.delete_module.underscore_module

    opts = {
      :teacher_mode => false,
      :substitute    => nil,
      :partial      => 'show',
      :locals       => {}
    }
    opts.merge!(_opts)
    teacher_mode = opts[:teacher_mode]
    substitute = opts[:substitute]
    partial = "#{class_name.pluralize}/#{opts[:partial]}"
    locals = opts[:locals]
    locals[demodulized_class_name.to_sym] = substitute ? substitute : component
    locals[:teacher_mode] = teacher_mode
    render :partial => partial, :locals => locals
  end

  def render_show_partial_for(component, _opts = {})
    opts = {:teacher_mode => false, :substitute => nil}.merge(_opts)
    render_partial_for(component, opts)
  end

  def render_edit_partial_for(component,opts={})
    render_partial_for(component, {:partial => "remote_form"}.merge!(opts))
  end

  def wrap_edit_link_around_content(component, options={})
    url      = options[:url]      || edit_url_for(component)
    update   = options[:update]   || dom_id_for(component, :item)
    method   = options[:method]   || :get
    complete = options[:complete] || nil
    success  = options[:success]  || nil
    js_function = remote_function(:url => url, :update => update, :method => method, :complete => complete, :success => success)
    dom_id = dom_id_for(component, :edit_link)

    capture_haml do
      if component.changeable?(current_visitor)
        haml_tag :div, :id=> dom_id, :class => 'editable_block', :onDblClick=> js_function  do
          if block_given?
            yield
          end
        end
      else
        if block_given?
          yield
        end
      end
    end
  end

  def edit_button_for(component, options={}, scope=false)
    url      = options[:url]      || edit_url_for(component, scope)
    update   = options[:update]   || dom_id_for(component, :item)
    method   = options[:method]   || :get
    complete = options[:complete] || nil
    success  = options[:success]  || nil
    title    = options[:title]    || "edit #{component.class.display_name.downcase}"
    remote_link_button "edit.png",  :url => url, :title => title, :update => update, :method => method, :complete => complete, :success => success
  end

  def edit_url_for(component, scope=false)
    if scope
      { :controller => component.class.name.pluralize.underscore,
        :action => :edit,
        :id  => component.id,
        :scope_type => scope.class,
        :scope_id =>scope.id}
    else
      { :controller => component.class.name.pluralize.underscore,
        :action => :edit,
        :id  => component.id,
        :container_type => @container_type,
        :container_id => @container_id }
    end
  end

  def edit_menu_for(component, form, options={:omit_cancel => true}, scope=false)
    component = (component.respond_to? :embeddable) ? component.embeddable : component
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_tag(:h3,{:class => 'menu'}) do
            haml_concat title_for_component(component, :id_prefix => 'edit')
          end
        end
        haml_tag :div, :class => 'action_menu_header_right' do
          haml_tag :ul, {:class => 'menu'} do
            #if (component.changeable?(current_visitor))
            haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Save") }
            haml_tag(:li, {:class => 'menu'}) { haml_concat form.submit("Cancel") } unless options[:omit_cancel]
            #end
          end
        end
      end
    end
  end

  def accordion_for(model, title, dom_prefix='', options={})
    show_hide_text = options[:show_hide_text]
    capture_haml do
      haml_tag :div, :id => dom_id_for(model, dom_prefix), :class => 'accordion_container' do
        haml_tag :div, :class => 'accordion_name' do
          haml_concat title
        end

        if show_hide_text
          haml_tag :div, :id => dom_id_for(model, "#{dom_prefix}_toggle"), :class => 'accordion_toggle_closed accordion_toggle' do
            haml_tag :span, :class => "accordion_show_hide_text" do
              haml_concat show_hide_text
            end
          end
        else
          haml_tag :div, :id => dom_id_for(model, "#{dom_prefix}_toggle"), :class => 'accordion_toggle_closed accordion_toggle'
        end

        unless options[:usage_count].blank?
          haml_tag :div, :class => 'accordion_count' do
            haml_concat options[:usage_count]
          end
        end

        haml_tag :div, :class => 'empty_break'
        haml_tag :div, :id => dom_id_for(model, "#{dom_prefix}_content"), :class => 'accordion_content', :style=>'display: none;' do
          if block_given?
            yield
          end
        end

      end
    end
  end

  def sort_dropdown(selected,keep = [])
    selected ||= Search::Alphabetical
    default_options = [ [Search::Oldest, "Oldest"], [Search::Newest, "Newest"], [Search::Alphabetical, "Alphabetical"], [Search::Popularity, "Popularity"] ]
    sort_options = (keep.size > 0 ? default_options.select{|o| keep.include?(o[0]) } : default_options)
    select nil, :sort_order, sort_options, {:selected => selected, :include_blank => false }
  end

  def otrunk_edit_button_for(component, options={})
    controller = component.class.name.pluralize.underscore
    id = component.id
    link_to image_tag("edit_otrunk.png"), { :controller => controller, :action => 'edit', :format => 'jnlp', :id => id }, :class => 'rollover' , :title => "edit #{component.class.display_name.downcase} using OTrunk"
  end

  def otml_url_for(component,options={})
    url = url_for(
      :controller => component.class.name.pluralize.underscore,
      :action => :show,
      :format => :otml,
      :id  => component.id,
      :only_path => false,
      :teacher_mode => options[:teacher_mode] )
    URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
  end

  def edit_otml_url_for(component)
    url = url_for(
      :controller => component.class.name.pluralize.underscore,
      :action => :edit,
      :format => :otml,
      :id  => component.id,
      :only_path => false )
    URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
  end

  def update_otml_url_for(component, escape=true)
    url = url_for(
      :controller => component.class.name.pluralize.underscore,
      :action => :update,
      :format => :otml,
      :id  => component.id,
      :only_path => false )
    if escape
      URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
    else
      url
    end
  end

  def learner_report_link_for(learner, action='report', link_text='Report ', title=nil)
    return "" unless learner.reportable?

    reportable_display_name = learner.class.display_name.downcase
    action_string = action.gsub('_', ' ')
    name = learner.name

    url = polymorphic_url(learner, :action => action)
    if title.nil?
      title = "Display a #{action_string} for the #{reportable_display_name}: '#{name}' in a new browser window."
    end
    link_to(link_text, url, :target => '_blank', :title => title)
  end

  def report_link_for(reportable, link_text='Report ', title=nil)
    return "" if reportable.respond_to?('reportable?') && !reportable.reportable?
    url = report_portal_offering_path(reportable.id)
    link_to link_text, url, :target => '_blank', :title => title
  end

  def alternate_report_link_for(offering)
    return nil unless runnable = offering.runnable
    return nil unless runnable.respond_to?(:external_report)
    return nil unless report = runnable.external_report
    url = portal_external_report_path(offering.id, report.id)
    link_to report.launch_text, url, :target => '_blank', :title => report.name
  end

  def activation_toggle_link_for(activatable, action='activate', link_text='Activate', title=nil)
    activatable_display_name = activatable.class.display_name.downcase
    action_string = action.gsub('_', ' ')
    url = polymorphic_url(activatable, :action => action)
    if title.nil?
      title = "#{action_string} the #{activatable_display_name}: '#{activatable.name}'."
    end
    link_to(link_text, url, :title => title)
  end

  def edit_link_for(component, params={})
    component_display_name = component.class.display_name.downcase
    name = component.name
    link_text = params.delete(:link_text) || "edit "
    url = polymorphic_url(component, :action => :edit, :params => params)
    link_button("edit.png", url) +
    link_to(link_text, url,
        :title => "edit the #{component_display_name}: '#{name}'")
  end

  def duplicate_link_for(component, params={})
    component_display_name = component.class.display_name.downcase
    text = params[:text] || 'duplicate'
    name = component.name
    #url = duplicate_investigation_url(component)
    url = polymorphic_url(component, :action => :duplicate, :params => params)
    link_button("itsi_copy.png", url,
      :title => "copy the #{component_display_name}: '#{name}'") +
    link_to(text, url)
  end


  def print_link_for(component, params={})
    component_display_name = component.class.display_name.downcase
    name = component.name
    link_text = params.delete(:link_text) || "print #{component_display_name}"
    if params[:teacher_mode]
      link_text = "#{link_text} (with notes) "
    end
    params.merge!({:print => true})
    url = polymorphic_url(component,:params => params)
    link_button("print.png", url, :title => "print the #{component_display_name}: '#{name}'") +
    link_to(link_text,url, :target => '_blank')
  end

  def otml_link_for(component, params={})
    link_to('otml',
      :controller => component.class.name.pluralize.underscore,
      :action => :show,
      :format => :otml,
      :id  => component.id,
      :params => params)
  end

  def delete_button_for(model, options={})
    if policy(model).destroy?
      # find the page_element for the embeddable
      embeddable = (model.respond_to? :embeddable) ? model.embeddable : model
      controller = "#{model.class.name.pluralize.underscore}"
      if defined? model.parent

        # allow specification of options[:redirect] = false to skip
        if options[:redirect].nil?
          options[:redirect]= url_for model.parent
        end
      end
      if options[:redirect]
        url = url_for(:controller => controller, :id => model.id, :action => :destroy, :redirect=>options[:redirect])
      else
        url = url_for(:controller => controller, :id => model.id, :action => :destroy)
      end
      remote_link_button "delete.png", :method => :delete, :confirm => "Delete  #{embeddable.class.display_name.downcase} named #{embeddable.name}?", :url => url, :title => "delete #{embeddable.class.display_name.downcase}"
    end
  end

  def link_to_container(container, options={})
    link_to name_for_component(container, options), container, :class => 'container_link'
  end

  def title_for_component(component, options={})
    title = name_for_component(component, options)
    id = dom_id_for(component, options[:id_prefix], :title)
    if ::Rails.env == "development" || current_visitor.has_role?('admin')
      "<span id=#{id} class='component_title'>#{title}</span><span class='dev_note'> #{link_to(component.id, component)}</span>"
    else
      "<span id=#{id} class='component_title'>#{title}</span>"
    end
  end

  def name_for_component(component, options={})
    if options[:display_name]
      return options[:display_name]
    end
    name = ''
    unless options[:hide_component_name]
      if component.class.respond_to? :display_name
        name << component.class.display_name
      else
        name << component.class.name.humanize
      end
      if component.respond_to? :display_type
        name = "#{component.display_type} #{name}"
      end
      name << ': '
    end
    default_name = ''
    if component.class.respond_to?(:default_value)
      default_name = component.class.default_value('name')
    end
    name << case
      when component.id.nil? then "(new)"
      when component.name == default_name then ''
      when component.name then component.name
      else ''
    end
  end

  def name_for_gse(gse)
    capture_haml do
      haml_tag(:ul, :class => 'menu_h') do
        haml_tag(:li) { haml_concat(link_to('GSE: ' + h(gse.gse_key),  grade_span_expectation_path(gse))) }
        haml_tag(:li) { haml_concat('Grade span: ' + h(gse.grade_span)) }
        haml_tag(:li) { haml_concat('Assessment target: ' + h(gse.assessment_target.number)) }
      end
    end
  end

  def open_response_learner_stat(learner)
    reportUtil = Report::Util.factory(learner.offering)
    answered = reportUtil.saveables(:answered => true, :learner => learner, :type => Embeddable::OpenResponse).size
    total = reportUtil.embeddables(:type => Embeddable::OpenRespose).size
    " Open Response: #{answered}/#{total} "
  end

  def multiple_choice_learner_stat(learner)
    reportUtil = Report::Util.factory(learner.offering)
    answered = reportUtil.saveables(:answered => true, :learner => learner, :type => Embeddable::MultipleChoice).size
    correct = reportUtil.saveables(:answered => true, :correct => true, :learner => learner, :type => Embeddable::MultipleChoice).size
    total = reportUtil.embeddables(:type => Embeddable::MultipleChoice).size
    " Multiple Choice: #{answered}/#{correct}/#{total} "
  end

  def sessions_learner_stat(learner)
    sessions = learner.bundle_logger.bundle_contents.count
    if sessions > 0
      pluralize(learner.bundle_logger.bundle_contents.count, 'session')
    else
      ''
    end
  end

  def learner_specific_stats(learner)
    reportUtil = Report::Util.factory(learner.offering)
    or_answered = reportUtil.saveables(:answered => true, :learner => learner, :type => Embeddable::OpenResponse).size
    or_total = reportUtil.embeddables(:type => Embeddable::OpenResponse).size
    mc_answered = reportUtil.saveables(:answered => true, :learner => learner, :type => Embeddable::MultipleChoice).size
    mc_correct = reportUtil.saveables(:answered => true, :correct => true, :learner => learner, :type => Embeddable::MultipleChoice).size
    mc_total = reportUtil.embeddables(:type => Embeddable::MultipleChoice).size
    "sessions: #{learner.bundle_logger.bundle_contents.count}, open response: #{or_answered}/#{or_total}, multiple choice:  #{mc_answered}/#{mc_correct}/#{mc_total}"
  end

  def report_details_for_learner(learner, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true, :type => :open_responses, :correctable => false }
    options.update(opts)
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(learner, options)
          haml_concat learner_specific_stats(learner)
        end
      end
    end
  end

  def report_correct_count_for_learner(learner, opts = {} )
    options = {:type => Embeddable::MultipleChoice}
    options.update(opts)
    reportUtil = Report::Util.factory(learner.offering)
    mc_correct = reportUtil.saveables(:answered => true, :correct => true, :learner => learner, :type => options[:type]).size
  end

  def percent(count,max,precision = 1)
    return 0 if max < 1
    raw = (count/max.to_f)*100
    result = (raw*(10**precision)).round/(10**precision).to_f
  end

  def percent_str(count, max, precision = 1)
    return "" if max < 1
    number_to_percentage(percent(count,max,precision), :precision => precision)
  end

  def menu_for_learner(learner, opts = {})
    options = { :omit_delete => true, :omit_edit => true, :hide_component_name => true }
    options.update(opts)
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_activity_options' do
          if learner.offering.runnable.run_format == :jnlp
            haml_concat link_to('Run', run_url_for(learner))
            haml_concat " | "
            if current_visitor.has_role?("admin")
              haml_concat learner_report_link_for(learner, 'bundle_report', 'Bundles ')
              haml_concat " | "
            end
          end
          haml_concat learner_report_link_for(learner, 'report', 'Report')
        end
        haml_tag :div, :class => 'action_menu_activity_title' do
          haml_concat title_for_component(learner, options)
          haml_tag :span, :class => 'tiny' do
            haml_concat sessions_learner_stat(learner)
          end
        end
      end
    end
  end

  def lara_report_link(offering)
    if offering.runnable.kind_of?(ExternalActivity)
      url      = offering.runnable.url
      uri      = URI.parse(url)
      learners = offering.learner_ids.join(",")
      students = offering.learners.map { |l| "#{l.id}:#{l.user.login}" }.join(",")
      students = URI.escape(students)
      learners = URI.escape(learners)
      report_url = "#{uri.scheme}://#{uri.host}:#{uri.port}/runs/details?learners=#{learners}&students=#{students}"
      haml_concat " | "
      haml_concat link_to("LARA Run report", report_url, {:target => "_blank"} )
    end
  end

  def menu_for_offering(offering, opts = {})
    options = {
      :omit_delete => true,
      :omit_edit => true,
      :hide_component_name => true,
      :print_link =>dropdown_link_for(:text => "Print", :id=> dom_id_for(offering.runnable,"print_rollover"), :content_id=> dom_id_for(offering.runnable,"print_dropdown"),:title => "print this #{top_level_container_name}")
    }
    options.update(opts)
    capture_haml do
      haml_tag :div, :class => 'action_menu_activity' do
        haml_tag :div, :class => 'action_menu_activity_options' do
          haml_concat options[:print_link]
          haml_concat " | "
          haml_concat dropdown_link_for(:text => "Run", :id=> dom_id_for(offering.runnable,"run_rollover"), :content_id=> dom_id_for(offering.runnable,"run_dropdown"),:title =>"run this #{top_level_container_name}")
          report_link = report_link_for(offering, 'Report', 'Report')
          if !report_link.blank?
            haml_concat " | #{report_link}"
          end
          lara_report_link(offering)
          haml_concat " | "

          if offering.active?
            haml_concat activation_toggle_link_for(offering, 'deactivate', 'Deactivate')
          else
            haml_concat activation_toggle_link_for(offering, 'activate', 'Activate')
          end

        end
        haml_tag :div, :class => 'action_menu_activity_title' do
          haml_concat title_for_component(offering, options)
          # haml_concat "Active students: #{offering.learners.length}"
        end
      end
    end
  end

  def menu_for_school(school, options = { :omit_delete => true, :omit_edit => true, :hide_componenent_name => true })
    capture_haml do
      haml_tag :div, :class => 'action_menu' do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(school, options)
          haml_concat "active classes: #{school.clazzes.active.length}"
        end
      end
    end
  end

  def show_menu_for(component, options={})
    is_page_element = (component.respond_to? :embeddable)
    deletable_element = component
    if is_page_element
      component = component.embeddable
    end
    view_class = for_teacher_only?(component) ? "teacher_only action_menu" : "action_menu"
    capture_haml do
      haml_tag :div, :class => view_class do
        haml_tag :div, :class => 'action_menu_header_left' do
          haml_concat title_for_component(component, options)
        end
        haml_tag :div, :class => 'action_menu_header_right' do
          if (component.changeable?(current_visitor))
            haml_concat edit_button_for(component, options)  unless options[:omit_edit]
            haml_concat delete_button_for(deletable_element) unless options[:omit_delete]
          end
        end
      end
    end
  end

  def toggle_link_title(future_state, current_state)
    "<span class='toggle'><span class='current_state'>#{current_state}</span><span class='future_state'>#{future_state}</span></span>"
  end

  def toggle_all(label='all', id_prefix='details_')
    link_to_function("show/hide #{label}", "$$('div[id^=#{id_prefix}]').each(function(d) { Effect.toggle(d,'blind', {duration:0.25}) });")
  end

  def toggle_more(component, details_id=nil, label="show/hide")
    toggle_id = dom_id_for(component,:show_hide)
    details_id ||= dom_id_for(component, :details)

    link_to_function(label, nil, :id => toggle_id, :class=>"small") do |page|
      page.visual_effect(:toggle_blind, details_id,:duration => 0.25)
      # page.replace_html(toggle_id,page.html(toggle_id) == more ? less : more)
    end
  end

  def dropdown_link_for(options ={})
    defaults = {
      :url        => "#",
      :text       => 'add content',
      :content_id => 'dropdown',
      :id         => 'add_content',
      :onmouseover => "dropdown_for('#{options[:id]||'dropdown'}','#{options[:content_id]||'add_content'}')"
    }
    options = defaults.merge(options)
    link_to(options[:text], options[:url], options.except(:text, :url))
  end

  def dropdown_button(image,options={})
    name = options[:name] || image.gsub(/\..*/,'') # remove extension of filename
    if options[:name_postfix]
      postfix = options[:name_postfix]
      content_id = "#{name}_#{postfix}_menu"
      id = "button_#{name}_#{postfix}_menu"
    else
      content_id = "#{name}_menu"
      id = "button_#{name}_menu"
    end
    defaults = {
      :name       =>  name,
      :text       =>  image_tag(image,:title => options[:title] || name),
      :class      => 'rollover',
      :content_id => content_id,
      :id         => id
    }
    options = defaults.merge(options)
    dropdown_link_for options
  end

  def link_button(image,url,options={})
    defaults = {
      :class      => 'rollover'
    }
    options = defaults.merge(options)
    link_to image_tag(image, :alt=>options[:title]) , url, options
  end

  def remote_link_button(image,options={})
    defaults = {
      :html       => {
        :class => options[:class] || 'rollover',
        :id    => options[:id],
        :title => options[:title] || 'no note here'
        },
      :title => options[:title] || 'no note here'
    }
    options = defaults.merge(options)
    link_to_remote image_tag(image, :alt=>options[:title],:title=>options[:title]),options
  end

  def function_link_button(image,javascript,options={})
    javascript ||= "alert('Hello world!'); return false;"
    defaults = {
      :class      => 'rollover'
    }
    options = defaults.merge(options)
    link_to_function(image_tag(image, :alt=>options[:title]), javascript, options)
  end

  def tab_for(component, options={})
    if(options[:active])
      "<li id=#{dom_id_for(component, :tab)} class='tab active'>#{link_to component.name, component, :class => 'active'}</li>"
    else
      "<li id=#{dom_id_for(component, :tab)} class='tab'>#{link_to component.name, component}</li>"
    end
  end

  def generate_javascript_datastore(data_collector)
    #
    # data: [ [1,2.5], [2,3.7], [2.5,6.78] ]
    #
    js = ''
    if data_collector.data_store_values
      if data_collector.data_store_values.length > 0
        js << "var default_data_#{data_collector.id} = #{data_collector.data_store_values.in_groups_of(2).inspect};\n"
      else
        js << "var default_data_#{data_collector.id} = [];\n"
      end
    else
      js << "var default_data_#{data_collector.id} = [];\n"
    end
    js
  end

  # expects styles to contain space seperated list of style classes.
  def style_for_teachers(component,style_classes=[])
    if (for_teacher_only?(component))
      style_classes << 'teacher_only' # funny, just adding a style text
    end
    return style_classes
  end


  def style_for_item(component,style_classes=[])
    style_classes << 'item' << 'selectable' << 'item_selectable'
    if (component.respond_to? 'changeable?') && (component.changeable?(current_visitor))
      style_classes << 'movable'
    end
    style_classes = style_for_teachers(component,style_classes)
    return style_classes.join(" ")
  end

  def simple_div_helper_that_yields
    capture_haml do
      haml_tag :div, :class => 'simple_div' do
        if block_given?
          haml_concat yield
        end
      end
    end
  end

  def already_rendered?(thing)
    return @render_scope_additional_objects && @render_scope_additional_objects.include?(thing)
  end

  def mark_rendered(thing)
    @render_scope_additional_objects ||= []
    @render_scope_additional_objects << thing
  end

  def in_render_scope?(thing)
    return true if thing == nil
    if already_rendered?(thing)
      return true
    end

    if @render_scope
      if @render_scope.respond_to?("page_elements")
        embeddables = @render_scope.page_elements.collect{|pe| pe.embeddable}.uniq
        if embeddables.include?(thing)
          return true
        end
      end
    end
    return false
  end

  def render_scoped_reference(thing)
    return "" if thing == nil
    if in_render_scope?(thing)
      capture_haml do
        haml_tag :object, :refid => ot_refid_for(thing)
      end
    else
      render_show_partial_for(thing)
    end
  end

  #
  # is a component viewable only by teacher?
  # cascading logic.
  # TODO: generic container-based method-forwarding mechanism
  #
  def for_teacher_only?(thing)
    if (thing.respond_to?("teacher_only?") && thing.teacher_only?)
      return true;
    end
    if thing.respond_to? :parent
      while thing = thing.parent
        if thing.respond_to? :teacher_only?
          if thing.teacher_only?
            return true
          end
        end
      end
    end
    return false
  end

  def render_project_info
    unless @rendered_project_info
      render :partial => "home/project_info"
      @rendered_project_info = true
    end
  end

  def add_top_menu_item(link)
    @top_menu_items ||= []
    @top_menu_items << link
  end

  def htmlize_teacher_note_body(teacher_note)
    if teacher_note.body
      teacher_note.body.gsub(/\n/,"<br/>")
    else
      "<br/>"
    end
  end

  def runnable_list(options)
    Investigation.search_list(options)
  end

  def students_in_class(all_students)
    all_students.compact.uniq.sort{|a,b| (a.user ? [a.first_name, a.last_name] : ["",""]) <=> (b.user ? [b.first_name, b.last_name] : ["",""])}
  end

#            Welcome
#            = "#{current_visitor.name}."
#            - unless current_visitor.anonymous?
#              = link_to 'Preferences', preferences_user_path(current_visitor)
#              \/
#              = link_to 'Logout', logout_path
#            - else
#              = link_to 'Login', login_path
#              \/
#              = link_to 'Sign Up', pick_signup_path
#            - if @original_user.has_role?('admin', 'manager')
#              \/
#              = link_to 'Switch', switch_user_path(current_visitor)
  def login_line(options = {})
    opts = {
      :welcome  => "Welcome",
      :login => "Login",
      :signup => "Sign up",
      :logout => "Logout",
      :prefs => "Preferences",
      :guest => false,
      :name_method => "name"
    }
    opts.merge!(options)
    message = ""
    if current_visitor.anonymous?
      if opts[:guest]
        message += "#{opts[:welcome]} #{opts[:guest]} &nbsp;"
      end
      message += link_to opts[:login], login_path
      message += " / "
      message += link_to opts[:signup], 'javascript:Portal.openSignupModal();'
    else
      message += "#{opts[:welcome]} #{current_visitor.send(opts[:name_method])} &nbsp;"
      message += link_to opts[:prefs],  preferences_user_path(current_visitor)
      message += " / "
      message += link_to opts[:logout], logout_path
      if @original_user.has_role?('admin','manager')
        message += " "
        message += link_to 'Switch', switch_user_path(current_visitor)
      end
    end
    message
  end

  def settings_for(key)
    Admin::Settings.settings_for(key)
  end

  # this appears to not be used in master right now
  def current_user_can_author
    return true if current_visitor.has_role? "author"
    if settings_for(:teachers_can_author)
      return true unless current_visitor.portal_teacher.nil?
    end
    # TODO add aditional can-author conditions
    return false
  end

  # Rails 3.0 way of switching the format for a block of code
  # see: http://stackoverflow.com/questions/339130/how-do-i-render-a-partial-of-a-different-format-in-rails
  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end

  def google_analytics_config
    if ENV['GOOGLE_ANALYTICS_ACCOUNT']
      javascript_tag <<CONFIG
var _gaq = _gaq || [];
_gaq.push(['_setAccount', '#{ENV['GOOGLE_ANALYTICS_ACCOUNT']}']);
_gaq.push(['_trackPageview']);

(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();
CONFIG
   end
  end

  # This fixes an error in polymorphic_url brought on because the Admin::Settings model name is plural.
  def admin_settings_index_path(*args)
    admin_settings_path
  end

  def class_link_for_user
    if current_visitor.portal_teacher
      if current_visitor.has_active_classes?
        recent_activity_path
      else
        getting_started_path
      end
    elsif current_visitor.portal_student
      my_classes_path
    else
      root_path
    end
  end

  def current_user_home_path
    if current_user.nil?
      # anonymous home is the '/'
      root_path
    elsif current_user.portal_student
      my_classes_path
    elsif APP_CONFIG[:recent_activity_on_login] &&
          current_user.portal_teacher &&
          current_user.has_active_classes?
      # Teachers with active classes are redirected to the "Recent Activity" page
      recent_activity_path
    else
      # this is a generic logged in user (not teacher or student)
      # or it is teacher without active classes
      getting_started_path
    end
  end

end
