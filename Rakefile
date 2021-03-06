require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rake/clean'

require 'browser_loader'

RSpec::Core::RakeTask.new(:spec)

##############################################################################

task :default => :spec

##############################################################################

desc "start a console"
task :console do
  require 'rubygems'
  require 'bundler/setup'
  require 'pry'
  ARGV.clear

  test_pwd = ENV['AMS_TEST_USER_PWD']
  if test_pwd.nil?
    puts "Set AMS_TEST_USER_PWD to the 'test' user's password in an environment variable"
  end

  def console_help
    puts <<CONSOLE_HELP
 AmsLayout Console
-------------------

  Helper Methods:

    client                   - returns the AmsLayout::client object
    login username, password - login to portal
    get_layout               - log in and return field layout
    write_layout filename    - write a layout file to disk in YAML format
    write_bundle output_dir  - write layout, layout class and delegate class
                               files to the directory specified.
    write_layout_class filename, layout_file    - create Layout class
    write_delegate_class filename, layout_file  - create Delegate class


CONSOLE_HELP
  end

  def client
    @client ||= AmsLayout::Client.new
    @client
  end

  def login username, password
    client.login username, password
  end

  def logout
    client.logout
  end

  def get_layout
    client.login 'test', test_pwd
    client.get_field_data
  end

  def write_layout filename, write_alias_example = false
    client.login 'test', test_pwd
    client.write_layout filename, write_alias_example
  end

  def write_bundle output_dir
    output_dir = Pathname(output_dir)

    layout_file = output_dir + 'layout.yml'
    layout_class = output_dir + 'loan_entry_fields.rb'
    layout_delegate = output_dir + 'delegate_loan_entry_fields.rb'

    write_alias_examples = true

    write_layout layout_file, write_alias_examples
    client.write_layout_class layout_class, layout_file
    client.write_delegate_class layout_delegate, layout_file
    client.quit
  end

  def write_layout_class filename, layout_file
    client.write_layout_class filename, layout_file
  end

  def write_delegate_class filename, layout_file
    client.write_delegate_class filename, layout_file
  end

  #def add_credentials env, username, pwd
  #  AdminModule.configure do |config|
  #    config.credentials[env.to_sym] = [username, pwd]
  #  end
  #end

  #def activate_env env, username, pwd
  #  add_credentials env, username, pwd
  #  client.environment = env.to_sym
  #end

  require_relative 'lib/ams_layout'

  console_help
  Pry.start
end

##############################################################################

desc 'Start chrome with data dir'
task :start_chrome do
  BrowserLoader.init_browser
end

