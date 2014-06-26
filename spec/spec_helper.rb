$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ams_layout'

def cli
  $cli ||= AmsLayout::CLI.new
end

def spec_tmp_dir
  here = Pathname.new(__dir__)
  tmp = here + '../tmp/spec'
  tmp.mkpath
  tmp.realdirpath
end

def spec_data_dir
  here = Pathname.new(__dir__)
  tmp = here + 'data'
  tmp.mkpath
  tmp.realdirpath
end

def clean_target_dir dir
  target_dir = spec_tmp_dir + Pathname(dir)
  target_dir.rmtree if target_dir.exist?
  target_dir.mkpath
  target_dir
end

def copy_from_spec_data src_file, dest_file
  src_path = spec_data_dir + src_file
  dest_path = spec_tmp_dir + dest_file
  dest_path.dirname.mkpath
  FileUtils.cp src_path, dest_path
  dest_path
end

def load_yml filename
  YAML::load_file(filename)
end

def assert_file_contains filename, str
  result = `grep "#{str}" #{filename}`
  fail "'#{str}' not found in #{filename}" if result.empty?
end
