require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe 'spec_helper methods' do

  it '.spec_tmp_dir' do
    expected = '/home/jeff/projects/ams/tools/ruby/ams_layout/tmp/spec'
    expect(spec_tmp_dir.to_s).to eq expected
  end

  it '.spec_data_dir' do
    expected = '/home/jeff/projects/ams/tools/ruby/ams_layout/spec/data'
    expect(spec_data_dir.to_s).to eq expected
  end

  it '.clean_target_dir' do
    expected = '/home/jeff/projects/ams/tools/ruby/ams_layout/tmp/spec/target'
    expect(clean_target_dir('target').to_s).to eq expected
  end

  it '.copy_from_spec_data' do
    target_file = spec_tmp_dir + 'target.yml'
    copy_from_spec_data 'layout-small.yml', 'target.yml'

    expect(File.exist?(target_file)).to eq true
  end
end
