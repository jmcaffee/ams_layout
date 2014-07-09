##############################################################################
# File::    cli.rb
# Purpose:: Command Line Interface
# 
# Author::    Jeff McAffee 06/21/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'thor'
require 'ams_layout/cli/config'
require 'ams_layout/cli/generate'

module AmsLayout
  class CLI < Thor

    def self.start(*)
      super
    rescue Exception => e
      raise e
    end

    desc "config [COMMAND]", "modify configuration file"
    subcommand "config", AmsLayout::Config

    desc "generate [COMMAND]", "generate one or more files"
    subcommand "generate", AmsLayout::Generate
  end # CLI
end # AmsLayout
