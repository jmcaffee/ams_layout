require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe AmsLayout::Client do
  let(:target_dir) {
    target_dir = clean_target_dir 'client'
  }

  let(:layout_yml) {
    #FileUtils.cp spec_data_dir + 'layout-small.yml', target_dir
    copy_from_spec_data 'layout-small.yml', target_dir + 'layout.yml'
    target_dir + 'layout.yml'
  }

  it '#login' do
    expect{ client.login('test', '***REMOVED***') }.not_to raise_exception
  end

  it '#logout' do
    expect{ client.logout }.not_to raise_exception
  end

  it '#get_field_data' do
    client.login('test', '***REMOVED***')

    expect{ client.get_field_data }.not_to raise_exception
  end

  it '#write_layout' do
    client.login('test', '***REMOVED***')

    target_file = target_dir.join 'write-layout.yml'

    expect{ client.write_layout(target_file) }.not_to raise_exception
    expect(target_file.exist?).to eq true
  end

  it '#write_aliases' do
    target_file = target_dir.join 'layout.yml.aliases.example'

    expect{ client.write_alias_example(layout_yml) }.not_to raise_exception
    expect(target_file.exist?).to eq true
  end

  it '#write_layout_class' do
    layout_file = copy_from_spec_data 'layout-small.yml', 'layout1.yml'
    copy_from_spec_data 'layout-small.yml.aliases', 'layout1.yml.aliases'

    target_file = target_dir.join 'loan_entry_fields.rb'

    expect{ client.write_layout_class(target_file, layout_file) }.not_to raise_exception
    expect(target_file.exist?).to eq true
  end
end
