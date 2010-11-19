module JettyRails
  module Adapters
    
    # This adapter extends the standard Rails adapter with
    # an additional listener for JMS queues
    class RailsJmsAdapter < RailsAdapter
      
      # Defaults to expecting ActiveMQ jars in lib_dir/jms_dir at startup
      @@defaults = {
        :jms_dir    => "jms",
        :queue_name => "rails_queue",
        :broker_address => 'failover:(nio://localhost:61616)?timeout=15000'
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
        factory.queue_name     = config[:queue_name]
        factory.broker_address = config[:broker_address]
        factory.username       = config[:username]
        factory.password       = config[:password]
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
        factory_class.send :cattr_accessor, :queue_name, :broker_address, :username, :password
        
        # Implement Rack::JMS::QueueManagerFactory Interface
        factory_class.send :include, Rack::JMS::QueueManagerFactory
        factory_class.module_eval(<<-EOS)
          
          def newQueueManager
            manager_class = Class.new Rack::JMS::DefaultQueueManager
            
            manager_class.send :field_accessor, :context, 
                                                :connectionFactory
            
            manager_class.send :attr_accessor, :queue_name, :broker_address, :username, :password

            # Overrides JNDI parts of DefaultQueueManager
            manager_class.module_eval do

              # Overrides in order to initialize connection factory w/o JNDI
              def init(context)
                self.context = context
                unless self.connectionFactory
                  factory = org.apache.activemq.ActiveMQConnectionFactory.new(self.broker_address)
                  factory.setUserName(self.username) if self.username
                  factory.setPassword(self.password) if self.password
                  self.connectionFactory = factory
                end
              end
              
              # Overrides in order to perform lookup of queue w/o JNDI
              def lookup(name)
                if name == self.queue_name
                  @jndiless_queue ||= org.apache.activemq.command.ActiveMQQueue.new(self.queue_name)
                else
                  super(name)
                end
              end
              
            end
            
            returning manager_class.new do |m|
              m.queue_name = self.class.queue_name
              m.broker_address    = self.class.broker_address
              m.username    = self.class.username
              m.password    = self.class.password
            end
          end
        EOS
        
        factory_class
      end
      
    end
    
  end
end