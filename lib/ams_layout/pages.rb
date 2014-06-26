##############################################################################
# File::    pages.rb
# Purpose:: Require all Page classes
#
# Author::    Jeff McAffee 2014-06-21
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'ams_layout/browser_loader'
require 'ams_layout/pages/login_page'
require 'ams_layout/pages/prequal_detail'

module AmsLayout
  module Pages

    ##
    # Return a configured browser object. If a browser has already been created,
    # this returns the existing browser.
    #
    # An +at_exit+ proc is created to close the browser when the program exits.

    def browser
      if @browser.nil?
        @browser = BrowserLoader.init_browser AmsLayout.configuration.browser_timeout

        at_exit do
          @browser.close unless @browser.nil?
        end
      end

      @browser
    end
  end # Pages
end # AmsLayout
