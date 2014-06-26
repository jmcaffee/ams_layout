require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

describe AmsLayout::DelegateWriter do
  let(:test_target_dir) {
    test_target_dir = clean_target_dir 'delegate_writer'
  }

  let(:writer) { AmsLayout::DelegateWriter.new }

  it '#class_name' do
    expect( writer.class_name ).to eq 'DelegateLoanEntryFields'
  end

  it '#delegated_class_name' do
    expect( writer.delegated_class_name ).to eq 'LoanEntryFields'
  end

  it '#source_file_name' do
    expect( writer.source_file_name ).to eq 'delegate_loan_entry_fields.rb'
  end

  it '#write' do
    # test_target_dir DELETEs and RECREATEs itself when called.
    target_dir = test_target_dir
    target_file = target_dir + 'delegate_loan_entry_fields.rb'
    layout_file = copy_from_spec_data 'layout-small.yml', 'writer/layout.yml'

    File.open(target_file, 'w') do |f|
      writer.write f, load_yml(layout_file)
    end

    expect(target_file.exist?).to eq true
    expect(assert_file_contains(target_file,'class DelegateLoanEntryFields < DelegateClass(LoanEntryFields)'))
  end

  it '#write_aliases' do
    # test_target_dir DELETEs and RECREATEs itself when called.
    target_dir = test_target_dir
    target_file = target_dir.join 'delegate_loan_entry_fields.rb'

    layout_file = copy_from_spec_data 'layout-small.yml', 'writer/layout.yml'
    alias_file = copy_from_spec_data 'layout-small.yml.aliases', 'writer/layout.yml.aliases'

    writer.aliases = load_yml(alias_file)

    File.open(target_file, 'w') do |f|
      writer.write f, load_yml(layout_file)
    end

    expect(target_file.exist?).to eq true
    expect(assert_file_contains(target_file,'text_field(:alias1_borrower_name'))
  end

  context '#aliases=' do

    it 'fails when non-hash provided' do
      expect{ writer.aliases = 'Not a Hash' }.to raise_exception
    end

    it 'accepts hash' do
      alias_data = {'Borrower Name' => ['Borrower FName', 'Borrower LName']}

      expect{ writer.aliases = alias_data }.to_not raise_exception
    end
  end
end

