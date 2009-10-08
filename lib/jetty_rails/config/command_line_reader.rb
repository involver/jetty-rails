require 'getoptlong'
require 'jetty_rails/config/rdoc_fix'


class CommandLineReader

  def default_config()
    @@config ||= {
      :rails => { 
        :base => Dir.pwd,
        :port => 3000,
        :config_file => "#{File.join(Dir.pwd, 'config', 'jetty_rails.yml')}",
        :adapter => :rails,
        :environment => "development"
      },
      :merb => {
        :base => Dir.pwd,
        :port => 4000,
        :config_file => "#{File.join(Dir.pwd, 'config', 'jetty_merb.yml')}",
        :adapter => :merb
      }
    }
  end

  def read(default_adapter = :rails)
    config = default_config[default_adapter]
    
    opts = GetoptLong.new(
      [ '--version', '-v', GetoptLong::NO_ARGUMENT ],
      [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
      [ '--context-path', '-u', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--port', '-p', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--environment', '-e', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--lib', '--jars', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--classes', GetoptLong::REQUIRED_ARGUMENT ],
      [ '--config', '-c', GetoptLong::OPTIONAL_ARGUMENT ]
    )
    
    opts.each do |opt, arg|
      case opt
        when '--version'
          require 'jetty_rails/version'
          puts "JettyRails version #{JettyRails::VERSION::STRING} - http://jetty-rails.rubyforge.org"
          exit(0)
        when '--help'
          RDoc::usage
        when '--context-path'
          config[:context_path] = arg
        when '--port'
          config[:port] = arg.to_i
        when '--environment'
          config[:environment] = arg
        when '--classes'
          config[:classes_dir] = arg
        when '--lib'
          config[:lib_dir] = arg
    	  when '--config'
    	    config[:config_file] = arg if !arg.nil? && arg != ""
      end
    end

    config[:base] = ARGV.shift unless ARGV.empty?
    
    if File.exists?(config[:config_file])
      config_file = YAML.load_file(config[:config_file])
      config.merge!(config_file[config[:environment]] || config_file) # check for env scope
      puts "Loaded #{config[:config_file]}"
    end
    
    config
  end  
  
end


