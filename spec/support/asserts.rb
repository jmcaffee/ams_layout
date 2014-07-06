##############################################################################
# File::    asserts.rb
# Purpose:: spec assertion helper methods
#
# Author::    Jeff McAffee 07/05/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

def assert_file_contains filename, str
  result = `grep "#{str}" #{filename}`
  fail "'#{str}' not found in #{filename}" if result.empty?
end
