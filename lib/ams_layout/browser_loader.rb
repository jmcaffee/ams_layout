##############################################################################
# File::    browser_loader.rb
# Purpose:: Create and initialize a browser with Watir
# 
# Author::    Jeff McAffee 06/21/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'watir-webdriver'
require 'ktutils/os'


###
# To start/stop Chrome auto-update, see http://blog.doofix.com/how-to-stop-google-chrome-from-automatic-update/
#
# Regedit instructions (in case URL breaks):
#
# Set value HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Update\UpdateDefault to 0 to turn off auto-update.
# Set to 1 to turn on auto-update, or delete the value (UpdateDefault).
#

###
# Chromedriver updates can be downloaded from http://chromedriver.storage.googleapis.com/index.html
#

class BrowserLoader
  def self.init_browser timeout = 60
    if ENV["BROWSER"] == "ie"
      browser = Watir::Browser.new :ie
    elsif ENV["BROWSER"] == "ff" || ENV["BROWSER"] == "firefox"
      browser = Watir::Browser.new :firefox
    else
      # Specify chrome browser capabilities.
      caps = Selenium::WebDriver::Remote::Capabilities.chrome
      caps['chromeOptions'] = {'binary' => chromium_exe }
      #caps['chromeOptions'] = {'binary' => '/opt/bin/test/chrome-27.0.1453.94.exe' }
      # See http://peter.sh/experiments/chromium-command-line-switches/ for a list of available switches.
      # See https://sites.google.com/a/chromium.org/chromedriver/capabilities for details on setting ChromeDriver caps.

      # NOTE: The only way I've found to stop the EULA from being displayed is to
      # use the user-data-dir switch and point to a dir where chrome can put the
      # data indicating it (EULA) has already been accepted.

      # ignore-certificate-errors:  Ignores certificate-related errors.
      # disable-popup-blocking:     Disable pop-up blocking.
      # disable-translate:          Allows disabling of translate from the command line to assist with automated browser testing
      # no-first-run:               Skip First Run tasks, whether or not it's actually the First Run.
      # log-level:                  Sets the minimum log level. Valid values are from 0 to 3: INFO = 0, WARNING = 1, LOG_ERROR = 2, LOG_FATAL = 3.
      # test-type:                  As of v35, chrome displays a message bar stating
      #                               "You are using an unsupported command-line flag: --ignore-certifcate-errors. Stability and security will suffer."
      #                               --test-type is supposed to disable the display of the error.
      switches = %w[--ignore-certificate-errors --disable-popup-blocking --disable-translate --no-first-run --log-level=3 --test-type]
      switches << "--user-data-dir=#{user_data_dir}"

      # Create a client so we can adjust the timeout period.
      client = Selenium::WebDriver::Remote::Http::Default.new

      # Set the browser timeout. Default is 60 seconds.
      client.timeout = timeout

      # switches and caps modify chrome (or chromium) browser,
      # service_args modifys chromedriver.
      browser = Watir::Browser.new :chrome,
        :switches => switches,
        :http_client => client,
        :service_log_path => user_data_dir + '/chromedriver.out',
        :desired_capabilities => caps
    end

    browser
  end

  def self.user_data_path= path
    @user_data_path = path
  end

  def self.user_data_dir
    # Store chrome profile at chrome-data.
    #user_data_dir = File.absolute_path(File.join(__FILE__, '../../../chrome-data'))
    user_data_dir = File.absolute_path(@user_data_path)

    fail "Chromium user-data directory does not exist at #{user_data_dir}" unless File.exist?(user_data_dir)

    user_data_dir
  end

  def self.chromium_exe
    if Ktutils::OS.windows?
      # Downloaded from http://chromium.woolyss.com/
      # Package: Chromium Package (32-bit)
      # Version: 37.0.2011.0 (272392)
      chromium_exe = File.absolute_path(File.join(__FILE__, '../../bin/chrome-win32/chrome.exe'))
    else
      chromium_exe = `which chromium-browser`.chomp
    end
  end
end # BrowserLoader

