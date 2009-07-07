module JnlpHelper
  
  def jnlp_adaptor
    @jnlp_adaptor || @jnlp_adaptor = JnlpAdaptor.new
  end
  
  def render_jnlp(runnable)
    # FIXME can't figure out why otml_url_for, doesn't work here
    # otml_url_for(runnable)
    url = polymorphic_url(runnable, :format =>  :otml, :teacher_mode => params[:teacher_mode])
    url = URI.escape(url, /[#{URI::REGEXP::PATTERN::RESERVED}\s]/)
    
    render( :layout => false, 
      :partial => "shared/jnlp", 
      :locals => { :teacher_mode => params[:teacher_mode], 
                   :runnable_object => runnable, 
        :escaped_otml_url => url
         } 
      )
  end
  
  def resource_jars
    jnlp_adaptor.resource_jars
  end

  def linux_native_jars
    jnlp_adaptor.linux_native_jars
  end

  def macos_native_jars
    jnlp_adaptor.macos_native_jars
  end
  
  def windows_native_jars
    jnlp_adaptor.windows_native_jars
  end

  def system_properties(options={})
    if options[:authoring]
      additional_properties = [
        ['otrunk.view.author', 'true'],
        ['otrunk.view.mode', 'authoring'],
        ['otrunk.remote_save_data', 'true'],
        ['otrunk.rest_enabled', 'true'],
        ['otrunk.remote_url', update_otml_url_for(options[:runnable_object], false)]
      ]
    else
      additional_properties = [
        ['otrunk.view.mode', 'student'],
        ['otrunk.view.no_user', 'true' ],
      ]
    end
    jnlp_adaptor.system_properties + additional_properties
  end
  
  def jnlp_resources(xml, options = {})
    jnlp = jnlp_adaptor.jnlp
    xml.resources {
      xml.j2se :version => jnlp.j2se_version, 'max-heap-size' => "#{jnlp.max_heap_size}m", 'initial-heap-size' => "#{jnlp.initial_heap_size}m"
      resource_jars.each do |resource|
        if resource[2]
          xml.jar :href => resource[0], :main => true, :version => resource[1]
        else
          xml.jar :href => resource[0], :version => resource[1]
        end
      end
      system_properties(options).each do |property|
        xml.property(:name => property[0], :value => property[1])
      end
    }
  end

  def jnlp_resources_linux(xml)
    xml.resources(:os => "Linux") { 
      linux_native_jars.each do |resource|
        xml.nativelib :href => resource[0], :version => resource[1]
      end
    }
  end

  def jnlp_resources_macosx(xml)
    xml.resources(:os => "Mac OS X") { 
      macos_native_jars.each do |resource|
        xml.nativelib :href => resource[0], :version => resource[1]
      end
    }
  end

  def jnlp_resources_windows(xml)
    xml.resources(:os => "Windows") { 
      windows_native_jars.each do |resource|
        xml.nativelib :href => resource[0], :version => resource[1]
      end
    }
  end

end