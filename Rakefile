require "bundler/gem_tasks"
require "rspec/core/rake_task"

require_relative 'lib/ams_layout/browser_loader'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "start a console"
task :console do
  require 'rubygems'
  require 'bundler/setup'
  require 'pry'
  ARGV.clear

  #AdminModule.configure do |config|
  #  config.credentials = { :dev => ['admin', '***REMOVED***'] }
  #end

  def console_help
    puts <<CONSOLE_HELP
 AmsLayout Console
-------------------

  Helper Methods:

    cli                      - returns the AmsLayout::CLI object
    login username, password - login to portal
    get_layout               - log in and return field layout
    write_layout filename    - write a layout file to disk in YAML format
    write_bundle output_dir  - write layout, layout class and delegate class
                               files to the directory specified.
    write_layout_class filename, layout_file    - create Layout class
    write_delegate_class filename, layout_file  - create Delegate class

    
CONSOLE_HELP
  end

  def cli
    @cli ||= AmsLayout::CLI.new
    @cli
  end

  def login username, password
    cli.login username, password
  end

  def logout
    cli.logout
  end

  def get_layout
    cli.login 'test', '***REMOVED***'
    cli.get_field_data
  end

  def write_layout filename, write_alias_example = false
    cli.login 'test', '***REMOVED***'
    cli.write_layout filename, write_alias_example
  end

  def write_bundle output_dir
    output_dir = Pathname(output_dir)

    layout_file = output_dir + 'layout.yml'
    layout_class = output_dir + 'loan_entry_fields.rb'
    layout_delegate = output_dir + 'delegate_loan_entry_fields.rb'

    write_alias_examples = true

    write_layout layout_file, write_alias_examples
    cli.write_layout_class layout_class, layout_file
    cli.write_delegate_class layout_delegate, layout_file
    cli.quit
  end

  def write_layout_class filename, layout_file
    cli.write_layout_class filename, layout_file
  end

  def write_delegate_class filename, layout_file
    cli.write_delegate_class filename, layout_file
  end

  #def add_credentials env, username, pwd
  #  AdminModule.configure do |config|
  #    config.credentials[env.to_sym] = [username, pwd]
  #  end
  #end

  #def activate_env env, username, pwd
  #  add_credentials env, username, pwd
  #  cli.environment = env.to_sym
  #end

  require_relative 'lib/ams_layout'

  console_help
  Pry.start
end

desc 'Start chrome with data dir'
task :start_chrome do
  BrowserLoader.init_browser
end

