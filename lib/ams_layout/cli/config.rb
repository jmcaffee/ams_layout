##############################################################################
# File::    config.rb
# Purpose:: Config command
# 
# Author::    Jeff McAffee 2014-07-08
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AmsLayout

  class Config < Thor

    class Add < Thor

      desc "env <envname> <url>", "add a environment url"
      def env(envname, url)
        with_loaded_config do
          unless AmsLayout.configuration.base_urls.key? envname.to_sym
            AmsLayout.configuration.base_urls[envname.to_sym] = url
          else
            say "environment '#{envname}' already exists", :red
          end
        end
      end

      desc "credentials <envname> <username> <pass>", "add login credentials for an environment"
      def credentials(envname, username, pass)
        with_loaded_config do
          if AmsLayout.configuration.base_urls.key? envname.to_sym
            unless AmsLayout.configuration.credentials.key? envname.to_sym
              AmsLayout.configuration.credentials[envname.to_sym] = [username, pass]
            else
              say "credentials already exist for environment '#{envname}'"
            end
          else
            say "environment '#{envname}' doesn't exist", :red
            say "create environment before adding credentials", :red
          end
        end
      end

    private

      def with_loaded_config &block
        fail "expecting block" unless block_given?

        unless AmsLayout.load_configuration
          say "Configuration file not found!", :red
          say "Have you tried 'config init' first?"
          return
        end

        yield

        AmsLayout.save_configuration
      end
    end

    desc "add [CATEGORY]", "add a configuration value"
    subcommand "add", Add


    class Show < Thor

      desc "envs", "display configured environments"
      def envs
        with_loaded_config do
          say "Environments:"

          output = []
          AmsLayout.configuration.base_urls.each do |env, url|
            output << [env, url]
          end
          print_table output, indent: 8
        end
      end

      desc "credentials <envname>", "display configured credentials for an environment"
      long_desc <<-LD
        Display configured credentials for an environment.

        If an environment name is not provided, credentials for all
        environments will be displayed.
      LD
      def credentials(envname=nil)
        with_loaded_config do
          say "credentials:"

          output = []
          AmsLayout.configuration.credentials.each do |env, cred|
            if envname.nil? || env == envname.to_sym
              output << [env, cred.first, cred.last]
            end
          end
          print_table output, indent: 8
        end
      end

    private

      def with_loaded_config &block
        fail "expecting block" unless block_given?

        unless AmsLayout.load_configuration
          say "Configuration file not found!", :red
          say "Have you tried 'config init' first?"
          return
        end

        yield
      end
    end

    desc "show [CATEGORY]", "display configuration values for [CATEGORY]"
    subcommand "show", Show


    class Del < Thor

      desc "env <envname>", "delete an environment configuration"
      def env(envname)
        with_loaded_config do
          if AmsLayout.configuration.base_urls.key?(envname.to_sym)
            AmsLayout.configuration.base_urls.delete(envname.to_sym)
          end
        end

        credentials(envname)
      end

      desc "credentials <envname>", "delete credentials for an environment"
      def credentials(envname)
        with_loaded_config do
          if AmsLayout.configuration.credentials.key?(envname.to_sym)
            AmsLayout.configuration.credentials.delete(envname.to_sym)
          end
        end
      end

    private

      def with_loaded_config &block
        fail "expecting block" unless block_given?

        unless AmsLayout.load_configuration
          say "Configuration file not found!", :red
          say "Have you tried 'config init' first?"
          return
        end

        yield

        AmsLayout.save_configuration
      end
    end

    desc "del [CATEGORY]", "delete a configuration value for [CATEGORY]"
    subcommand "del", Del


    desc "init <filedir>", "initialize a configuration file"
    long_desc <<-LD
      Create a configuration file.

      If <filedir> is provided, config file will be written to the
      given directory.

      If <filedir> is not given, the configuration file will be
      written to the current working directory.
    LD
    option :quiet, :type => :boolean, :default => false, :aliases => :q
    def init(filedir = nil)
      if filedir.nil?
        filedir = Pathname.pwd + AmsLayout::CONFIG_FILE_NAME
      else
        filedir = Pathname(filedir) + AmsLayout::CONFIG_FILE_NAME unless filedir.to_s.end_with?("/#{AmsLayout::CONFIG_FILE_NAME}")
      end

      outpath = AmsLayout.save_configuration filedir
      say("configuration written to #{outpath.to_s}", :green) unless options[:quiet]
    end


    desc "timeout <seconds>", "show or set the browser timeout period"
    long_desc <<-LD
      Show or set the browser timeout period.
      Default value is 360.

      If <seconds> is not provided, display the current setting.

      <seconds> must be an integer value.
    LD
    def timeout(seconds=nil)
      if seconds.nil?
        with_loaded_config do
          say "browser timeout: #{AmsLayout.configuration.browser_timeout}"
        end
      else
        with_loaded_config(true) do
          AmsLayout.configuration.browser_timeout = Integer(seconds)
        end
      end
    rescue ArgumentError => e
      say 'argument error: seconds must be an integer'
    end


    desc "defenv <envname>", "show or set the default environment"
    long_desc <<-LD
      Show or set the default environment.

      If <envname> is not provided, display the current setting.

      <envname> must be an existing environment.
    LD
    def defenv(envname=nil)
      if envname.nil?
        with_loaded_config do
          say "default environment: #{AmsLayout.configuration.default_environment}"
        end
        return
      end

      with_loaded_config(true) do
        if AmsLayout.configuration.base_urls.key? envname.to_sym
          AmsLayout.configuration.default_environment = envname.to_sym
        else
          say "argument error: environment '#{envname}' has not been configured"
        end
      end
    end

  private

    def with_loaded_config save = false
      fail "expecting block" unless block_given?

      unless AmsLayout.load_configuration
        say "Configuration file not found!", :red
        say "Have you tried 'config init' first?"
        return
      end

      yield

      AmsLayout.save_configuration if save
    end
  end # Config
end # AmsLayout
