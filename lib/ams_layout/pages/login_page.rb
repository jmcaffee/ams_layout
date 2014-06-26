##############################################################################
# File::    login_page.rb
# Purpose:: AMS Login page
# 
# Author::    Jeff McAffee 06/22/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'page-object'

module AmsLayout
  module Pages

  class LoginPage
    include PageObject

    page_url( AmsLayout.configuration.base_url )

    text_field(:username, :id => "ctl00_ContentPlaceHolder1_Login1_txtUserName" )
    text_field(:password_mask, :id => "ctl00_ContentPlaceHolder1_Login1_txtPasswordMask" )
    text_field(:password, :id => "ctl00_ContentPlaceHolder1_Login1_txtPassword" )
    button(:login, :id => "ctl00_ContentPlaceHolder1_Login1_btnLogin" )

    # Part of the main menu visible after login
    link(:pipelines, :text => "Pipelines")

    def login_as(username, password)
      self.username = username
      allow_password_entry
      self.password = password
      login

      trys = 0
      # Make sure we wait until the (sometimes) slow login is finished.
      while trys < 10 && !self.text.include?('LOAN PIPELINE')
        trys += 1
        sleep 1
      end
    end

    def logout
      navigate_to page_url_value + '/User/AppLogout.aspx'
    end

    def logged_in?
      !self.username?
    end

    def allow_password_entry
      # We used to have to click on the password mask before the page would let us enter the password itself:
      #
      # # For some unknown reason, we must click on a password mask input before
      # # we can access the password field itself.
      #   password_mask_element.click
      #
      # Now, we have to use javascript to hide the mask and display the password field.
      hide_mask_script = <<EOS
pwdmasks = document.getElementsByClassName('passwordmask');
pwdmasks[0].style.display = 'none';
pwds = document.getElementsByClassName('password');
pwds[0].style.display = 'block';
EOS

      @browser.execute_script(hide_mask_script)
    end
  end # class LoginPage
  end # Pages
end # AmsLayout
