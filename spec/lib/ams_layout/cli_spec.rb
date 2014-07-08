require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

require 'ams_layout/cli'

describe 'ams_layout executable' do

  let(:cli) { AmsLayout::CLI }

  context "help commands" do
    it "displays help info" do
      output = capture_output do
        cli.start %w(help)
      end

      expect( output ).to include "help [COMMAND]"
      expect( output ).to include "generate [COMMAND]"
    end
  end
=begin
  it "returns non-zero exit status when passed unrecognized options" do
    pending
    #ams_layout '--invalid_argument', :exitstatus => true
    ams_layout '--invalid_argument'
    expect(exitstatus).to_not be_zero
  end

  it "returns non-zero exit status when passed unrecognized task" do
    pending
    ams_layout 'unrecognized-task'#, :exitstatus => true
    expect(exitstatus).to_not be_zero
  end
=end
end
