# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jetty-rails}
  s.version = "0.9.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fabio Kung"]
  s.date = %q{2009-07-09}
  s.description = %q{jetty server for rails applications}
  s.email = ["fabio.kung@gmail.com"]
  s.executables = ["jetty_merb", "jetty_rails"]
  s.extra_rdoc_files = ["History.txt", "Licenses.txt", "Manifest.txt", "PostInstall.txt", "README.txt", "TODO.txt"]
  s.files = ["History.txt", "Licenses.txt", "Manifest.txt", "PostInstall.txt", "README.txt", "Rakefile", "TODO.txt", "bin/jetty_merb", "bin/jetty_rails", "config/hoe.rb", "config/requirements.rb", "jetty-libs/core-3.1.1.jar", "jetty-libs/jetty-6.1.14.jar", "jetty-libs/jetty-plus-6.1.14.jar", "jetty-libs/jetty-util-6.1.14.jar", "jetty-libs/jsp-2.1.jar", "jetty-libs/jsp-api-2.1.jar", "jetty-libs/servlet-api-2.5-6.1.14.jar", "lib/jetty_rails.rb", "lib/jetty_rails/adapters/abstract_adapter.rb", "lib/jetty_rails/adapters/merb_adapter.rb", "lib/jetty_rails/adapters/rails_adapter.rb", "lib/jetty_rails/adapters/rails_jms_adapter.rb", "lib/jetty_rails/config/command_line_reader.rb", "lib/jetty_rails/config/rdoc_fix.rb", "lib/jetty_rails/handler/delegate_on_errors_handler.rb", "lib/jetty_rails/handler/public_directory_handler.rb", "lib/jetty_rails/handler/web_app_handler.rb", "lib/jetty_rails/jars.rb", "lib/jetty_rails/runner.rb", "lib/jetty_rails/server.rb", "lib/jetty_rails/version.rb", "lib/jetty_rails/warbler_reader.rb", "lib/jruby-rack-0.9.4.jar", "script/console", "script/destroy", "script/generate", "script/txt2html", "setup.rb", "spec/config.yml", "spec/jetty_merb_spec.rb", "spec/jetty_rails/config_file_spec.rb", "spec/jetty_rails/handler/delegate_on_errors_handler_spec.rb", "spec/jetty_rails/runner_spec.rb", "spec/jetty_rails_sample_1.yml", "spec/jetty_rails_sample_2.yml", "spec/jetty_rails_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/deployment.rake", "tasks/environment.rake", "tasks/rspec.rake", "tasks/website.rake"]
  s.has_rdoc = true
  s.homepage = %q{http://jetty-rails.rubyforge.org}
  s.post_install_message = %q{
For more information on jetty-rails, see http://jetty-rails.rubyforge.org
}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{jetty-rails}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{jetty server for rails applications}
  s.test_files = ["spec/jetty_merb_spec.rb", "spec/jetty_rails/config_file_spec.rb", "spec/jetty_rails/handler/delegate_on_errors_handler_spec.rb", "spec/jetty_rails/runner_spec.rb", "spec/jetty_rails_spec.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 1.3.1"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<activesupport>, [">= 1.3.1"])
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 1.3.1"])
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
 
