module JettyRails
  module Adapters
    
    # This adapter extends the standard Rails adapter with
    # an additional listener for JMS queues
    class RailsJmsAdapter < RailsAdapter
      
      # Defaults to using OpenMQ, expects jars in lib_dir/jms_dir at startup
      @@defaults = {
        :jms_dir                  => "jms",
        :connection_factory_class => "com.sun.messaging.ConnectionFactory",
        :queue_class              => "com.sun.messaging.Queue",
        :queue_name               => "rails_queue"
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
        factory.connection_factory_class = config[:connection_factory_class]
        factory.queue_class              = config[:queue_class]
        factory.queue_name               = config[:queue_name]
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
        factory_class.send :cattr_accessor, :connection_factory_class, 
                                            :queue_class, 
                                            :queue_name
        
        # Implement Rack::JMS::QueueManagerFactory Interface
        factory_class.send :include, Rack::JMS::QueueManagerFactory
        factory_class.module_eval(<<-EOS)
          
          def newQueueManager
            manager_class = Class.new Rack::JMS::DefaultQueueManager
            
            manager_class.send :field_accessor, :context, 
                                                :connectionFactory
            
            manager_class.send :attr_accessor, :connection_factory_class, 
                                               :queue_class, 
                                               :queue_name
            
            # Overrides JNDI parts of DefaultQueueManager
            manager_class.module_eval do
              
              # Overrides in order to initialize connection factory w/o JNDI
              def init(context)
                self.context = context
                unless self.connectionFactory
                  import self.connection_factory_class
                  factory = eval(self.connection_factory_class).new
                  self.connectionFactory = factory
                end
              end
              
              # Overrides in order to perform lookup of queue w/o JNDI
              def lookup(name)
                if name == self.queue_name
                  @jndiless_queue ||=
                    eval(self.queue_class).new(self.queue_name)
                else
                  super(name)
                end
              end
              
            end
            
            returning manager_class.new do |m|
              m.connection_factory_class = self.class.connection_factory_class
              m.queue_class              = self.class.queue_class
              m.queue_name               = self.class.queue_name
            end
          end
        EOS
        
        factory_class
      end
      
    end
    
  end
end