##############################################################################
# File::    pages.rb
# Purpose:: Require all Page classes
#
# Author::    Jeff McAffee 2014-06-21
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'browser_loader'
require 'ams_layout/pages/login_page'
require 'ams_layout/pages/prequal_detail'

module AmsLayout
  module Pages
    class BrowserInst
      @@browser = nil

      ##
      # Return a configured browser object. If a browser has already been created,
      # this returns the existing browser.
      #
      # An +at_exit+ proc is created to close the browser when the program exits.

      def self.browser
        if ! open_browser?
          BrowserLoader::Factory.browser_timeout = AmsLayout.configuration.browser_timeout
          @@browser = BrowserLoader::Factory.build

          at_exit do
            unless ! open_browser?
              # Make sure every webdriver window is closed.
              @@browser.windows.each { |w| w.close rescue nil }
              @@browser.close rescue nil
            end
          end
        end

        @@browser
      end

      def self.open_browser?
        return (! @@browser.nil? && @@browser.exist? )
      end
    end

    ##
    # Return a configured browser object. If a browser has already been created,
    # this returns the existing browser.
    #
    # An +at_exit+ proc is created to close the browser when the program exits.

    def browser
      BrowserInst.browser
    end
  end # Pages
end # AmsLayout
