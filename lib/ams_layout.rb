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
  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end

  class Configuration
    attr_accessor :default_environment
    attr_accessor :credentials
    attr_accessor :base_urls
    attr_accessor :aliases
    attr_accessor :page_urls

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
end

# Call configure to force creation of the configuration object.
AmsLayout.configure

require "ams_layout/version"
require "ams_layout/browser_loader"
require 'ams_layout/client'
require "ams_layout/parser"
require "ams_layout/writer"
require "ams_layout/delegate_writer"

