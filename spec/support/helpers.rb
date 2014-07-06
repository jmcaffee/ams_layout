##############################################################################
# File::    helpers.rb
# Purpose:: Spec helper methods
# 
# Author::    Jeff McAffee 07/05/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

def client
  $client ||= AmsLayout::Client.new
end

def load_yml filename
  YAML::load_file(filename)
end

def capture_output
  fake_stdout = StringIO.new
  actual_stdout = $stdout
  $stdout = fake_stdout
  yield
  fake_stdout.rewind
  fake_stdout.read
ensure
  $stdout = actual_stdout
end

