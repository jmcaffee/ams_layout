require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe AmsLayout::Writer do
  let(:test_target_dir) {
    test_target_dir = clean_target_dir 'writer'
  }

  let(:writer) { AmsLayout::Writer.new }

  it '#class_name' do
    expect( writer.class_name ).to eq 'LoanEntryFields'
  end

  it '#source_file_name' do
    expect( writer.source_file_name ).to eq 'loan_entry_fields.rb'
  end

  it '#write' do
    # test_target_dir DELETEs and RECREATEs itself when called.
    target_dir = test_target_dir
    target_file = target_dir + 'loan_entry_fields.rb'
    layout_file = copy_from_spec_data 'layout-small.yml', 'writer/layout.yml'

    File.open(target_file, 'w') do |f|
      writer.write f, load_yml(layout_file)
    end

    expect(target_file.exist?).to eq true
    expect(assert_file_contains(target_file,'class LoanEntryFields'))
    expect(assert_file_contains(target_file,'text_field(:borrower_name'))
  end

  it '#write_aliases' do
    # test_target_dir DELETEs and RECREATEs itself when called.
    target_dir = test_target_dir
    target_file = target_dir.join 'loan_entry_fields.rb'

    layout_file = copy_from_spec_data 'layout-small.yml', 'writer/layout.yml'
    alias_file = copy_from_spec_data 'layout-small.yml.aliases', 'writer/layout.yml.aliases'

    writer.aliases = load_yml(alias_file)

    File.open(target_file, 'w') do |f|
      writer.write f, load_yml(layout_file)
    end

    expect(target_file.exist?).to eq true
    expect(assert_file_contains(target_file,'text_field(:alias1_borrower_name'))
  end

  context "#class_name" do
    it 'defaults to LoanEntryFields' do
      expect( writer.class_name ).to eq 'LoanEntryFields'
    end
  end

  context "#source_file_name" do
    it 'defaults to loan_entry_fields.rb' do
      expect( writer.source_file_name ).to eq 'loan_entry_fields.rb'
    end
  end
end

