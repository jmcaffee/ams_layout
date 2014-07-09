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

def mock_client(field_data = {})
  mock_client = object_double(AmsLayout::Client.new)

  allow(mock_client).to receive(:login).with(anything, anything).and_return(nil)
  allow(mock_client).to receive(:logout).and_return(nil)
  allow(mock_client).to receive(:quit).and_return(nil)
  allow(mock_client).to receive(:get_field_data).and_return(field_data)
  allow(mock_client).to receive(:write_layout).with(anything, anything).and_return(true)
  allow(mock_client).to receive(:write_layout_class).with(anything, anything).and_return(true)
  allow(mock_client).to receive(:write_delegate_class).with(anything, anything).and_return(true)

  mock_client
end

def run_with_args(args, client, exitcode = false)
    AmsLayout::Runner.new(args, client, exitcode).execute!
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

