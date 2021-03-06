##############################################################################
# File::    generate.rb
# Purpose:: Generate command
# 
# Author::    Jeff McAffee 06/21/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'thor'
require 'ams_layout/client'

module AmsLayout
  class Generate < Thor

    desc "layout [PATH]", "write layout data to a file"
    long_desc <<-LD
      Generate layout data file.

      File will be named layout.yml and placed in the directory (PATH)
      you specify.

      Directory must already exist or an error will be thrown.
    LD
    option :env, :banner => "dev", :aliases => :e
    def layout(path)
      env = AmsLayout.configuration.default_environment
      env = options[:env] if options[:env]
      user, pass = credentials env

      client.login(user, pass)
      client.write_layout path, false
      client.logout
    end

    desc "cls <opts> [PATH] [LAYOUT_PATH]", "write layout class to a file"
    long_desc <<-LD
      Generate layout class.

      Options:

        -n ClassName specify name of layout class (default: LoanEntryFields)

      Arguments:

      [PATH] Path to directory where layout class will be created.

      [LAYOUT_PATH] Path to directory containing layout data (layout.yml)

      Directories must already exist or an error will be thrown.
    LD
    option :name, :banner => "ClassName", :aliases => :n
    def cls(path, layout_path)
      if options[:name]
        client.layout_class_name = options[:name]
      end

      client.write_layout_class path, layout_path
    end

    desc "delegate <opts> [PATH] [LAYOUT_PATH]", "write delegate class to a file"
    long_desc <<-LD
      Generate delegate class.

      Options:

        -d ClassName specify name of delegate class (default: DelegateLoanEntryFields)

      Arguments:

      [PATH] Path to directory where delegate class will be created.

      [LAYOUT_PATH] Path to directory containing layout data (layout.yml)

      Directories must already exist or an error will be thrown.
    LD
    option :delegate, :banner => "DelegateClassName", :aliases => :d
    def delegate(path, layout_path)
      if options[:delegate]
        client.delegate_class_name = options[:delegate]
      end

      client.write_delegate_class path, layout_path
    end

    desc "all <opts> [PATH]", "write layout data, layout class, and delegate class files to a path"
    long_desc <<-LD
      Generate layout data file (layout.yml), layout class, and delegate layout class.

      Options:

        -n ClassName specify name of layout class (default: LoanEntryFields)

        -d ClassName specify name of delegate class (default: DelegateLoanEntryFields)

      Arguments:

      [PATH] Path to directory where files will be created.

      Directory must already exist or an error will be thrown.
    LD
    option :name, :banner => "ClassName", :aliases => :n
    option :delegate, :banner => "DelegateClassName", :aliases => :d
    option :env, :banner => "dev", :aliases => :e
    def all(path)
      env = AmsLayout.configuration.default_environment
      env = options[:env] if options[:env]
      user, pass = credentials env

      # Generate layout file
      client.login(user, pass)
      client.write_layout path, false
      client.logout

      # Generate layout class
      if options[:name]
        client.layout_class_name = options[:name]
      end

      client.write_layout_class path, path

      # Generate delegate class
      if options[:delegate]
        client.delegate_class_name = options[:delegate]
      end

      client.write_delegate_class path, path
    end

  private

    def client
      AmsLayout.client
    end

    def credentials env
      user, pass = AmsLayout.configuration.credentials[env]
      if user.nil? || pass.nil?
        user = ask "username for #{env} environment:"
        pass = ask "password:"
      end
      [user, pass]
    end
  end
end # AmsLayout
