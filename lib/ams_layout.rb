##############################################################################
# File::    ams_layout.rb
# Purpose:: Main AmsLayout include
# 
# Author::    Jeff McAffee 06/21/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'rubygems'
require 'bundler/setup'

module AmsLayout
  CONFIG_FILE_NAME = '.ams_layout'

  class << self
    attr_accessor :configuration
    attr_accessor :client
  end

  ##
  # Setup ams_layout configuration
  #
  # Attempts to find and load a configuration file the first time
  # it's requested. If a config file cannot be found on disk, a
  # default configuration object is created.
  #
  # If a block is provided, the configuration object is yielded to the block
  # after the configuration is loaded/created.
  #

  def self.configure
    if self.configuration.nil?
      unless self.load_configuration
        self.configuration = Configuration.new
      end
    end
    yield(configuration) if block_given?
  end

  ##
  # Walk up the directory tree from current working dir (pwd) till a file
  # named .ams_layout is found.
  #
  # Returns file path if found, nil if not.
  #

  def self.find_config_path
    path = Pathname(Pathname.pwd).ascend{|d| h=d+CONFIG_FILE_NAME; break h if h.file?}
  end

  ##
  # Write configuration to disk
  #
  # Writes to current working dir (pwd) if path is nil
  #
  # Returns path of emitted file
  #

  def self.save_configuration(path = nil)
    # If no path provided, see if we can find one in the dir tree.
    if path.nil?
      path = find_config_path
    end

    # Still no path? Use the current working dir.
    if path.nil?
      path = Pathname.pwd + CONFIG_FILE_NAME
    end

    path = Pathname(path).expand_path
    File.write(path, YAML.dump(configuration))

    path
  end

  ##
  # Load the configuration from disk
  #
  # Returns true if config file found and loaded, false otherwise.
  #

  def self.load_configuration(path = nil)
    # If no path provided, see if we can find one in the dir tree.
    if path.nil?
      path = find_config_path
    end

    return false if path.nil?
    return false unless path.exist?

    File.open(path, 'r') do |f|
      self.configuration = YAML.load(f)
      puts "configuration loaded from #{path}" if $debug
    end

    true
  end


  class Configuration
    attr_accessor :default_environment
    attr_accessor :credentials
    attr_accessor :base_urls
    attr_accessor :aliases
    attr_accessor :page_urls

    # Default generated class names
    attr_accessor :layout_class_name
    attr_accessor :delegate_class_name

    # Browser timeout in seconds. Default: 360 (6 mins).
    attr_accessor :browser_timeout

    def initialize
      reset
    end

    def reset
      @default_environment = :dev

      @credentials = { dev: [ ENV['HSBC_DEV_USER'], ENV['HSBC_DEV_PASSWORD'] ],
                      dev2: [ ENV['HSBC_DEV2_USER'], ENV['HSBC_DEV2_PASSWORD'] ],
                       sit: [ ENV['HSBC_SIT_USER'], ENV['HSBC_SIT_PASSWORD'] ],
                       uat: [ ENV['HSBC_UAT_USER'], ENV['HSBC_UAT_PASSWORD'] ] }

      @base_urls   = { dev: "http://207.38.119.211/fap2Dev/Portal",
                      dev2: "http://207.38.119.211/fap2Dev2/Portal",
                       sit: "http://207.38.119.211/fap2SIT/Portal",
                       uat: "http://207.38.119.211/fap2UAT/Portal" }

      @aliases      = {}

      @page_urls   = { 'PrequalDetail'           => "/SubmitLoan/PrequalDetail.aspx",
                    }

      @layout_class_name = 'LoanEntryFields'
      @delegate_class_name = 'DelegateLoanEntryFields'

      @browser_timeout = 360
    end

    def base_url
      @base_urls[@default_environment]
    end

    def url page_class
      suffix = @page_urls[page_class.to_s.split('::').last]
      raise "Unkown page [#{page_class.to_s}]" if suffix.nil?
      base_url + suffix
    end
  end # Configuration

  def self.create_layout filename
    browser = BrowserLoader.init_browser

    login_page = LoginPage.new

    parser = Parser.new
    parser.parse html
    File.write(filename, YAML.dump(parser.layout))
  end

  class Runner
    def initialize(argv, client = AmsLayout::Client.new, exit_code = true)
      @argv = argv
      AmsLayout.client = client
      @exit_code = exit_code
    end

    def execute!
      exit_code = begin

        # Run the thor app
        AmsLayout::CLI.start(@argv)

        # Thor::Base#start does not have a return value,
        # assume success if no exception is thrown.
        0
      rescue StandardError => e
        b = e.backtrace
        b.unshift("#{b.shift}: #{e.message} (#{e.class})")
        puts(b.map { |s| "\tfrom #{s}"}.join("\n"))
        1
      end

      # Return the exit code
      exit(exit_code) if @exit_code
    end
  end # Runner
end # AmsLayout

# Call configure to force creation of the configuration object.
AmsLayout.configure

require "ams_layout/version"
require "ams_layout/browser_loader"
require 'ams_layout/client'
require "ams_layout/parser"
require "ams_layout/writer"
require "ams_layout/delegate_writer"
require "ams_layout/cli"

