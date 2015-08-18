require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe AmsLayout::Client do
  let(:target_dir) {
    target_dir = clean_target_dir 'client'
  }

  let(:test_pwd) {
    test_pwd = ENV['AMS_TEST_USER_PWD']
    if test_pwd.nil?
      fail "Set AMS_TEST_USER_PWD to the 'test' user's password in an environment variable"
    end
  }

  let(:layout_yml) {
    #FileUtils.cp spec_data_dir + 'layout-small.yml', target_dir
    copy_from_spec_data 'layout-small.yml', target_dir + 'layout.yml'
    target_dir + 'layout.yml'
  }

  it '#login' do
    expect{ client.login('test', test_pwd) }.not_to raise_exception
  end

  it '#logout' do
    expect{ client.logout }.not_to raise_exception
  end

  it '#get_field_data' do
    client.login('test', test_pwd)

    expect{ client.get_field_data }.not_to raise_exception
  end

  it '#write_layout' do
    with_target_dir('client/layout') do |dir|
      client.login('test', test_pwd)

      target_file = Pathname(dir).join 'layout.yml'

      expect{ client.write_layout(dir) }.not_to raise_exception
      expect(target_file.exist?).to eq true
    end
  end

  it '#write_aliases' do
    with_target_dir('client/layout/aliases') do |dir|
      dir = Pathname(dir)
      copy_from_spec_data 'layout-small.yml', dir + 'layout.yml'
      target_file = dir + 'layout.yml.aliases.example'

      expect{ client.write_alias_example(dir) }.not_to raise_exception
      expect(target_file.exist?).to eq true
    end
  end

  it '#write_layout_class' do
    with_target_dir('client/layout/class') do |dir|
      dir = Pathname(dir)
      copy_from_spec_data 'layout-small.yml', dir + 'layout.yml'
      copy_from_spec_data 'layout-small.yml.aliases', dir + 'layout.yml.aliases'
      target_file = dir + 'loan_entry_fields.rb'

      expect{ client.write_layout_class(dir, dir) }.not_to raise_exception
      expect(target_file.exist?).to eq true
    end
  end

  it '#write_delegate_class' do
    with_target_dir('client/layout/delegate') do |dir|
      dir = Pathname(dir)
      copy_from_spec_data 'layout-small.yml', dir + 'layout.yml'
      copy_from_spec_data 'layout-small.yml.aliases', dir + 'layout.yml.aliases'
      target_file = dir + 'delegate_loan_entry_fields.rb'

      expect{ client.write_delegate_class(dir, dir) }.not_to raise_exception
      expect(target_file.exist?).to eq true
    end
  end

  context "#layout_class_name" do
    it 'defaults to LoanEntryFields' do
      expect( client.layout_class_name ).to eq 'LoanEntryFields'
    end
  end

  context "#delegate_class_name" do
    it 'defaults to DelegateLoanEntryFields' do
      expect( client.delegate_class_name ).to eq 'DelegateLoanEntryFields'
    end
  end
end
