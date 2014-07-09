##############################################################################
# File::    client.rb
# Purpose:: AmsLayout Client object
# 
# Author::    Jeff McAffee 06/21/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'ams_layout/pages'
require 'ams_layout/core_ext'

module AmsLayout
  class Client
    include AmsLayout::Pages

    attr_writer :layout_class_name
    attr_writer :delegate_class_name

    def initialize
      # Make sure the configuration has been initialized.
      AmsLayout.configure
    end

    def layout_class_name
      @layout_class_name ||= AmsLayout.configuration.layout_class_name
    end

    def delegate_class_name
      @delegate_class_name ||= AmsLayout.configuration.delegate_class_name
    end

    ##
    # Set the current environment

    def environment=(env)
      raise "Unknown environment [#{env}]" unless AmsLayout.configuration.credentials.key?(env)
      @env = env
      AmsLayout.configure do |config|
        config.default_environment = env
      end
    end

    ##
    # Return the current environment

    def environment
      @env ||= AmsLayout.configuration.default_environment
      @env
    end

    ##
    # Return the credentials for the current environment

    def credentials
      return AmsLayout.configuration.credentials[environment]
    end

    ##
    # Return the base url for the current environment

    def base_url
      return AmsLayout.configuration.base_urls[environment]
    end

    ##
    # Login to the Admin Module
    #
    # If we're already logged in, do nothing unless the +force+ flag is true.
    #
    # +force+ force a re-login if we've already logged in

    def login(username, password, options = {})
      force = options.fetch(:force) { false }

      logout
      login_page(force).login_as username, password
    end

    def logout
      login_page.logout
      @login_page = nil
    end

    ##
    # Close the browser

    def quit
      unless @browser.nil?
        logout
        @browser.close
        @browser = nil
      end
    end

    ##
    # Retrieve field data from Loan Entry (Prequal) screen

    def get_field_data
      prequal = PrequalDetail.new(browser, true)
      parser = Parser.new
      parser.parse prequal.html
      parser.layout
    end

    def write_layout path, write_alias_example = false
      layout = get_field_data
      File.write layout_path(path), YAML.dump(layout)

      write_alias_example layout_path(path) if write_alias_example
    end

    def write_alias_example layout_file_path
      layout = YAML::load_file(layout_path(layout_file_path))
      aliases = {}

      layout.each do |section_label, fields|
        fields.each do |fld|
          label = fld[:label]
          aliases[label] = [
            "Alias1 #{label}",
            "Alias2 #{label}"
          ]
        end # fields
      end # layout

      File.write "#{layout_path(layout_file_path)}.aliases.example", YAML.dump(aliases)
    end

    def write_layout_class path, layout_file_path
      assert_file_exists layout_path(layout_file_path)

      layout = YAML::load_file(layout_path(layout_file_path))
      aliases = YAML::load_file("#{layout_path(layout_file_path)}.aliases") if File.exist?("#{layout_path(layout_file_path)}.aliases")
      writer = Writer.new
      writer.class_name = layout_class_name
      writer.aliases = aliases unless aliases.nil?

      File.open(layout_class_path(path), 'w') do |f|
        writer.write f, layout
      end
    end

    def write_delegate_class path, layout_file_path
      assert_file_exists layout_path(layout_file_path)

      layout = YAML::load_file(layout_path(layout_file_path))
      aliases = YAML::load_file("#{layout_path(layout_file_path)}.aliases") if File.exist?("#{layout_path(layout_file_path)}.aliases")
      writer = DelegateWriter.new
      writer.class_name = delegate_class_name
      writer.aliases = aliases unless aliases.nil?

      File.open(delegate_class_path(path), 'w') do |f|
        writer.write f, layout
      end
    end

  private

    def layout_path path
      path = Pathname(path)
      filename = 'layout.yml'
      path = path + filename
    end

    def layout_class_path path
      path = Pathname(path)
      filename = layout_class_name.snakecase + '.rb'
      path = path + filename
    end

    def delegate_class_path path
      path = Pathname(path)
      filename = delegate_class_name.snakecase + '.rb'
      path = path + filename
    end

    def login_page force = false
      if force || @login_page.nil?
        @login_page = LoginPage.new(browser, true)
      end

      @login_page
    end

    def assert_file_exists filename
      fail "#{filename} does not exist" unless File.exist?(filename)
    end
  end # Client
end # AmsLayout
