module JettyRails
  module Adapters
    
    # This adapter extends the standard Rails adapter with
    # an additional listener for JMS queues
    class RailsJmsAdapter < RailsAdapter
      
      # Defaults to expecting OpenMQ jars in lib_dir/jms_dir at startup
      @@defaults = {
        :jms_dir    => "jms",
        :queue_name => "rails_queue",
        :mq_host    => "localhost",
        :mq_port    => 7676
      }
      
      def initialize(config)
        super @@defaults.merge(config)
        require_jms_jars()
      end
      
      def event_listeners
        super << Rack::JMS::QueueContextListener.new(queue_manager_factory())
      end
      
      def queue_manager_factory
        factory = jndiless_default_queue_manager_factory_class()
        factory.queue_name = config[:queue_name]
        factory.mq_host    = config[:mq_host]
        factory.mq_port    = config[:mq_port]
        factory.new
      end
      
      protected
      
      def jms_jars_path
        File.join(config[:base], config[:lib_dir], config[:jms_dir])
      end
      
      def require_jms_jars
        Dir["#{self.jms_jars_path}/*.jar"].each {|jar| require jar }
      end
      
      # JRuby Rack's DefaultQueueManager uses JNDI for discovery
      # JNDI is overkill for embedded servers like Jetty Rails
      # 
      # This method returns a custom Rack::JMS::QueueManagerFactory
      # which produces a JNDI-less Rack::JMS::DefaultQueueManager
      def jndiless_default_queue_manager_factory_class
        factory_class = Class.new
        factory_class.send :cattr_accessor, :queue_name, :mq_host, :mq_port
        
        # Implement Rack::JMS::QueueManagerFactory Interface
        factory_class.send :include, Rack::JMS::QueueManagerFactory
        factory_class.module_eval(<<-EOS)
          
          def newQueueManager
            manager_class = Class.new Rack::JMS::DefaultQueueManager
            
            manager_class.send :field_accessor, :context, 
                                                :connectionFactory
            
            manager_class.send :attr_accessor, :queue_name, :mq_host, :mq_port
            
            # Overrides JNDI parts of DefaultQueueManager
            manager_class.module_eval do
              
              # Overrides in order to initialize connection factory w/o JNDI
              def init(context)
                self.context = context
                unless self.connectionFactory
                  import "com.sun.messaging.ConnectionFactory"
                  factory = com.sun.messaging.ConnectionFactory.new
                  config  = com.sun.messaging.ConnectionConfiguration
                  factory.setProperty(config.imqAddressList, "mq://" + self.mq_host + ":" + self.mq_port.to_s)
                  self.connectionFactory = factory
                end
              end
              
              # Overrides in order to perform lookup of queue w/o JNDI
              def lookup(name)
                if name == self.queue_name
                  @jndiless_queue ||= com.sun.messaging.Queue.new(self.queue_name)
                else
                  super(name)
                end
              end
              
            end
            
            returning manager_class.new do |m|
              m.queue_name = self.class.queue_name
              m.mq_host    = self.class.mq_host
              m.mq_port    = self.class.mq_port
            end
          end
        EOS
        
        factory_class
      end
      
    end
    
  end
end