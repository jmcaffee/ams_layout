##############################################################################
# File::    dirs.rb
# Purpose:: Spec directory helper methods
# 
# Author::    Jeff McAffee 07/05/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

def spec_tmp_dir
  here = Pathname.new(__dir__)
  tmp = here + '../../tmp/spec'
  tmp.mkpath
  tmp.realdirpath
end

def spec_data_dir
  here = Pathname.new(__dir__)
  tmp = here + '../data'
  tmp.mkpath
  tmp.realdirpath
end

def clean_target_dir dir
  target_dir = spec_tmp_dir + Pathname(dir)
  target_dir.rmtree if target_dir.exist?
  target_dir.mkpath
  target_dir
end

def with_target_dir dir
  working_dir = clean_target_dir dir
  FileUtils.cd working_dir do
    yield(working_dir)
  end
end

def copy_from_spec_data src_file, dest_file
  src_path = spec_data_dir + src_file
  dest_path = spec_tmp_dir + dest_file
  dest_path.dirname.mkpath
  FileUtils.cp src_path, dest_path
  dest_path
end

