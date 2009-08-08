# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'rack/utils'

# /dataservice/bundle_loggers/7/bundle_contents.bundle

class BundleContent
  
  POST_BODY = 'rack.input'.freeze
  
  def self.call(env)
    if bundle_logger_id = env["PATH_INFO"][/\/dataservice\/bundle_loggers\/(\d+)\/bundle_contents\.bundle/, 1]
      if bundle_logger = Dataservice::BundleLogger.find(bundle_logger_id)
        if bundle_content = bundle_logger.bundle_contents.create(:body => env[POST_BODY].read)
          digest = Digest::MD5.hexdigest(bundle_content.body)
        end
      end
    end
    if bundle_content
      [201, 
        { 'Content-Type' => 'text/xml', 
          'Last-Modified' => bundle_content.created_at.httpdate, 
          'Content-Length' => '0',
          'Content-MD5' => digest },
        []
      ]
    else
      [404, { 'Content-Type' => 'text/html' }, ['Not Found']]
    end
  ensure
    # If we accessed ActiveRecord then release the connections back to the pool. 
    # see: http://blog.codefront.net/2009/06/15/activerecord-rails-metal-too-many-connections/
    ActiveRecord::Base.clear_active_connections! if bundle_logger_id
  end
end
