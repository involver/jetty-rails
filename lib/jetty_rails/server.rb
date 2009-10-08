module JettyRails
  class Server
    attr_reader :config
    attr_reader :app_contexts
    attr_reader :server
  
    @@defaults = {
      :adapter => :rails, 
      :environment => 'development',
      :context_path => '/',
      :lib_dir => 'lib',
      :classes_dir => 'classes',
      :web_xml => 'config/web.xml',
      :port => 8080,
      :jruby_min_runtimes => 1,
      :jruby_max_runtimes => 5,
      :thread_pool_max => 20,
      :thread_pool_min => 1,
      :acceptor_size => 5
    }
  
    def initialize(config = {})
      @config = config.symbolize_keys!.reverse_merge!(@@defaults)
    
      @server = Jetty::Server.new
      # setup the thread pool for the server
      thread_pool = Jetty::Thread::QueuedThreadPool.new
      thread_pool.set_max_threads(config[:thread_pool_max])
      thread_pool.set_min_threads(config[:thread_pool_min])
      @server.set_thread_pool(thread_pool)
    
      connector = Jetty::SelectChannelConnector.new
      connector.set_acceptors(config[:acceptor_size])
      connector.port = config[:port]
      if config[:stats_on]
        connector.stats_on = true
      end
      @server.add_connector(connector)

      if config[:apps].nil?
        add_app(config)
      else
        config[:apps].each do |app_config|
          app_config.reverse_merge!(config)
          app_config.delete(:apps)
          add_app(app_config)
        end
      end
    end
    
    def add_app(config) 
      raise 'Base dir to be run must be provided' unless config[:base]
      config[:context_path].extend ContextPath
      
      @server.add_handler(JettyRails::Handler::PublicDirectoryHandler.new(config))
      web_app_handler = JettyRails::Handler::WebAppHandler.new(config)
      (@app_contexts ||= []) << web_app_handler
      @server.add_handler(web_app_handler)
    end
  
    def start
      @server.start
      @server.join
    end
  
  
    private
    def read_warble_config
      require 'warbler'
      WarblerReader.new(config)
    end
  
    module ContextPath
      def root?
        self == '/'
      end
    end
  end
end
