##############################################################################
# File::    prequal_detail.rb
# Purpose:: Loan Entry (flow) for AMS Portal
#
# Author::    Jeff McAffee 2014-06-21
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'page-object'

module AmsLayout
  module Pages

class PrequalDetail
  include PageObject

  page_url(::AmsLayout.configuration.base_url + '/SubmitLoan/PrequalDetail.aspx')

  def html
    @browser.html
  end
end
  end # Pages
end # AmsLayout

