require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

require 'ams_layout/cli'

describe 'ams_layout generate' do

  let(:cli) { AmsLayout::CLI }

  context "help commands" do
    it "displays generate help info" do
      output = capture_output do
        cli.start %w(generate help)
      end

      expect( output ).to include "generate help [COMMAND]"
      expect( output ).to include "generate layout [PATH]"
      expect( output ).to include "generate cls <opts> [PATH] [LAYOUT_PATH]"
      expect( output ).to include "generate delegate <opts> [PATH] [LAYOUT_PATH]"
      expect( output ).to include "generate all <opts> [PATH]"
    end
  end

  context "generate" do

    let(:client) { mock_client }

    context "layout" do

      it "calls the client object" do
        expect(client)
          .to receive(:login)
          #.with(anything, anything)

        expect(client)
          .to receive(:write_layout)
          .with('test/path', anything)

        expect(client)
          .to receive(:logout)

        AmsLayout::Runner.new(%w(generate layout test/path), client, false).execute!
      end
    end

    context "cls" do

      it "calls the client object" do
        expect(client)
          .to receive(:write_layout_class)
          .with('path/to/class', 'path/to/layout')

        AmsLayout::Runner.new(%w(generate cls path/to/class path/to/layout), client, false).execute!
      end

      context "with ClassName option" do

        it "sets the class name" do
          expect(client)
            .to receive(:layout_class_name=)
            .with('TestClass')

          expect(client)
            .to receive(:write_layout_class)
            .with('path/to/class', 'path/to/layout')

          AmsLayout::Runner.new(%w(generate cls --name=TestClass path/to/class path/to/layout), client, false).execute!
        end
      end
    end

    context "delegate" do

      it "calls the client object" do
        expect(client)
          .to receive(:write_delegate_class)
          .with('path/to/class', 'path/to/layout')

        AmsLayout::Runner.new(%w(generate delegate path/to/class path/to/layout), client, false).execute!
      end

      context "with DelegateClassName option" do

        it "sets the class name" do
          expect(client)
            .to receive(:delegate_class_name=)
            .with('TestClass')

          expect(client)
            .to receive(:write_delegate_class)
            .with('path/to/class', 'path/to/layout')

          AmsLayout::Runner.new(%w(generate delegate --delegate=TestClass path/to/class path/to/layout), client, false).execute!
        end
      end
    end

    context "all" do

      it "calls the client object" do
        expect(client)
          .to receive(:login)

        expect(client)
          .to receive(:write_layout)
          .with('path/to/files', anything)

        expect(client)
          .to receive(:logout)

        expect(client)
          .to receive(:write_layout_class)
          .with('path/to/files', 'path/to/files')

        expect(client)
          .to receive(:write_delegate_class)
          .with('path/to/files', 'path/to/files')

        AmsLayout::Runner.new(%w(generate all path/to/files), client, false).execute!
      end

      context "with ClassName option" do

        it "sets the class name" do
          expect(client)
            .to receive(:layout_class_name=)
            .with('TestClass')

          AmsLayout::Runner.new(%w(generate all --name=TestClass path/to/files), client, false).execute!
        end
      end

      context "with DelegateClassName option" do

        it "sets the class name" do
          expect(client)
            .to receive(:delegate_class_name=)
            .with('TestClass')

          AmsLayout::Runner.new(%w(generate all --delegate=TestClass path/to/files), client, false).execute!
        end
      end

      context "with both options" do

        it "sets both class names" do
          expect(client)
            .to receive(:layout_class_name=)
            .with('TestClass')

          expect(client)
            .to receive(:delegate_class_name=)
            .with('DelTestClass')

          AmsLayout::Runner.new(%w(generate all --name=TestClass --delegate=DelTestClass path/to/files), client, false).execute!
        end
      end
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
