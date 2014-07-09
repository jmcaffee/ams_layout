require 'pathname'
require Pathname(__FILE__).ascend{|d| h=d+'spec_helper.rb'; break h if h.file?}

require 'ams_layout'

describe 'config command' do

  before do
    # Reset config to a known state.
    AmsLayout.configuration.reset
    # Delete any config file that may have been created.
    file = Pathname.pwd + AmsLayout::CONFIG_FILE_NAME
    file.delete if file.exist?
  end

  let(:cli) { AmsLayout::CLI }

  it "returns help info" do
    output = capture_output do
      run_with_args(%w(help config), client)
    end

    expect( output ).to include "config help [COMMAND]"
    expect( output ).to include "config add [CATEGORY]"
    expect( output ).to include "config show [CATEGORY]"
    expect( output ).to include "config del [CATEGORY]"
    expect( output ).to include "config timeout <seconds>"
    expect( output ).to include "config defenv <envname>"
  end

  context 'config init' do

    context "no filename/path provided" do
      it "writes a configuration file to the current working directory" do
        with_target_dir('config/init') do |dir|

          output = capture_output do
            run_with_args(%w(config init), client)
          end

          output_file = Pathname(dir) + AmsLayout::CONFIG_FILE_NAME

          expect( output ).to include "configuration written to #{output_file.to_s}"
          expect( output_file.exist? ).to eq true
        end
      end
    end

    context "filename/path provided" do
      it "writes a configuration file to the specified directory" do
        with_target_dir('config/init') do
          final_dir = clean_target_dir('config/init/nested/dir')

          output = capture_output do
            run_with_args(%W(config init #{final_dir.to_s}), client)
          end

          output_file = Pathname(final_dir) + AmsLayout::CONFIG_FILE_NAME

          expect( output_file.exist? ).to eq true
          expect( output ).to include "configuration written to #{output_file.to_s}"
        end
      end
    end
  end

  context 'config timeout' do

    it "displays an error if configuration hasn't been init'd" do
      with_target_dir('config/timeout') do |dir|
        output = capture_output do
          run_with_args(%w(config timeout), client)
        end

        expect( output ).to include "Configuration file not found!"
        expect( output ).to include "Have you tried 'config init' first?"
      end
    end

    it "returns the current timeout when no argument provided" do
      with_target_dir('config/timeout') do |dir|
        run_with_args(%w(config init -q), client)

        output = capture_output do
          run_with_args(%w(config timeout), client)
        end

        expect( output ).to include 'browser timeout: 360'
      end
    end

    it "sets the current timeout when an argument is provided" do
      with_target_dir('config/timeout') do |dir|
        run_with_args(%w(config init -q), client)

        run_with_args(%w(config timeout 180), client)

        expect( AmsLayout.configuration.browser_timeout ).to eq 180
      end
    end

    it "displays an argument error if timeout value is not an integer" do
      with_target_dir('config/timeout') do |dir|
        run_with_args(%w(config init -q), client)

        output = capture_output do
          run_with_args(%w(config timeout blag), client)
        end

        expect( output ).to include 'argument error: seconds must be an integer'
      end
    end
  end

  context 'config defenv' do

    it "displays an error if configuration hasn't been init'd" do
      with_target_dir('config/defenv') do |dir|
        output = capture_output do
          run_with_args(%w(config defenv), client)
        end

        expect( output ).to include "Configuration file not found!"
        expect( output ).to include "Have you tried 'config init' first?"
      end
    end

    it "returns the current default environment when no argument provided" do
      with_target_dir('config/defenv') do |dir|
        run_with_args(%w(config init -q), client)

        run_with_args(%w(config add env test1 http://example.com), client)
        run_with_args(%w(config defenv test1), client)

        output = capture_output do
          run_with_args(%w(config defenv), client)
        end

        expect( output ).to include 'default environment: test1'
      end
    end

    it "sets the current default environment when an argument is provided" do
      with_target_dir('config/defenv') do |dir|
        run_with_args(%w(config init -q), client)

        run_with_args(%w(config add env test2 http://example.com), client)
        run_with_args(%w(config defenv test2), client)

        expect( AmsLayout.configuration.default_environment ).to eq :test2
      end
    end

    it "displays an argument error if environment doesn't exist" do
      with_target_dir('config/defenv') do |dir|
        run_with_args(%w(config init -q), client)

        output = capture_output do
          run_with_args(%w(config defenv nope), client)
        end

        expect( output ).to include "argument error: environment 'nope' has not been configured"
      end
    end
  end

  context 'config add' do

    it "returns help info" do
      output = capture_output do
        run_with_args(%w(config help add), client)
      end

      expect( output ).to include "add help [COMMAND]"
      expect( output ).to include "add env <envname> <url>"
      expect( output ).to include "add credentials <envname> <username> <pass>"
    end

    context "env" do

      it "displays an error if configuration hasn't been init'd" do
        with_target_dir('config/add/env') do |dir|
          output = capture_output do
            run_with_args(%w(config add env test http://example.com), client)
          end

          expect( output ).to include "Configuration file not found!"
          expect( output ).to include "Have you tried 'config init' first?"
        end
      end

      it "adds an environment" do
        with_target_dir('config/add/env') do |dir|
          run_with_args(%w(config init -q), client)

          run_with_args(%w(config add env test http://example.com), client)

          actual = AmsLayout.configuration.base_urls[:test]
          expect( actual ).to eq 'http://example.com'
        end
      end

      it "displays an error if environment already exists" do
        with_target_dir('config/add/env') do |dir|
          run_with_args(%w(config init -q), client)

          run_with_args(%w(config add env test http://example.com), client)

          output = capture_output do
            run_with_args(%w(config add env test http://example.com), client)
          end

          expect( output ).to include "environment 'test' already exists"
        end
      end
    end

    context "credentials" do

      it "displays an error if configuration hasn't been init'd" do
        with_target_dir('config/add/credentials') do |dir|
          output = capture_output do
            run_with_args(%w(config add credentials test testuser testpass), client)
          end

          expect( output ).to include "Configuration file not found!"
          expect( output ).to include "Have you tried 'config init' first?"
        end
      end

      it "adds a set of credentials" do
        with_target_dir('config/add/credentials') do |dir|
          run_with_args(%w(config init -q), client)

          # Add an environment first...
          run_with_args(%w(config add env test http://example.com), client)

          run_with_args(%w(config add credentials test testuser testpass), client)

          actual_user, actual_pass = AmsLayout.configuration.credentials[:test]
          expect( actual_user ).to eq 'testuser'
          expect( actual_pass ).to eq 'testpass'
        end
      end

      it "displays an error if credentials already exist for the given env" do
        with_target_dir('config/add/credentials') do |dir|
          run_with_args(%w(config init -q), client)

          # Add an environment first...
          run_with_args(%w(config add env test http://example.com), client)

          run_with_args(%w(config add credentials test testuser testpass), client)

          output = capture_output do
            run_with_args(%w(config add credentials test testuser testpass), client)
          end

          expect( output ).to include "credentials already exist for environment 'test'"
        end
      end

      it "displays an error if environment hasn't been created first" do
        with_target_dir('config/add/credentials') do |dir|
          run_with_args(%w(config init -q), client)

          output = capture_output do
            run_with_args(%w(config add credentials test testuser testpass), client)
          end

          expect( output ).to include "environment 'test' doesn't exist"
          expect( output ).to include "create environment before adding credentials"
          expect( AmsLayout.configuration.credentials.key?(:test) ).to be false
        end
      end
    end
  end

  context 'config show' do

    it "returns help info" do
      output = capture_output do
        run_with_args(%w(config help show), client)
      end

      expect( output ).to include "show help [COMMAND]"
      expect( output ).to include "show envs"
      expect( output ).to include "show credentials <envname>"
    end

    context "envs" do

      it "displays an error if configuration hasn't been init'd" do
        with_target_dir('config/show/envs') do |dir|
          output = capture_output do
            run_with_args(%w(config show envs), client)
          end

          expect( output ).to include "Configuration file not found!"
          expect( output ).to include "Have you tried 'config init' first?"
        end
      end

      it "displays configured environments" do
        with_target_dir('config/show/envs') do |dir|
          run_with_args(%w(config init -q), client)

          run_with_args(%w(config add env test1 http://example.com), client)
          run_with_args(%w(config add env test2 http://example.org), client)

          output = capture_output do
            run_with_args(%w(config show envs), client)
          end

          expect( output ).to include 'Environments:'
          expect( output ).to include 'test1  http://example.com'
          expect( output ).to include 'test2  http://example.org'
        end
      end
    end

    context "credentials" do

      it "displays an error if configuration hasn't been init'd" do
        with_target_dir('config/show/credentials') do |dir|
          output = capture_output do
            run_with_args(%w(config show credentials), client)
          end

          expect( output ).to include "Configuration file not found!"
          expect( output ).to include "Have you tried 'config init' first?"
        end
      end

      it "displays configured credentials" do
        with_target_dir('config/show/credentials') do |dir|
          run_with_args(%w(config init -q), client)

          run_with_args(%w(config add env test1 http://example.com), client)
          run_with_args(%w(config add credentials test1 testuser1 testpass1), client)

          run_with_args(%w(config add env test2 http://example.org), client)
          run_with_args(%w(config add credentials test2 testuser2 testpass2), client)

          output = capture_output do
            run_with_args(%w(config show credentials), client)
          end

          expect( output ).to include 'credentials:'
          expect( output ).to include 'test1  testuser1  testpass1'
          expect( output ).to include 'test2  testuser2  testpass2'
        end
      end

      it "displays configured credentials for specified environment" do
        with_target_dir('config/show/credentials') do |dir|
          run_with_args(%w(config init -q), client)

          run_with_args(%w(config add env test1 http://example.com), client)
          run_with_args(%w(config add credentials test1 testuser1 testpass1), client)

          run_with_args(%w(config add env test2 http://example.org), client)
          run_with_args(%w(config add credentials test2 testuser2 testpass2), client)

          output = capture_output do
            run_with_args(%w(config show credentials test1), client)
          end

          expect( output ).to include 'credentials:'
          expect( output ).to include 'test1  testuser1  testpass1'
          expect( output ).to_not include 'test2  testuser2  testpass2'
        end
      end
    end
  end

  context 'config del' do

    it "returns help info" do
      output = capture_output do
        run_with_args(%w(config help del), client)
      end

      expect( output ).to include "del help [COMMAND]"
      expect( output ).to include "del env <envname>"
      expect( output ).to include "del credentials <envname>"
    end

    context "env" do

      it "displays an error if configuration hasn't been init'd" do
        with_target_dir('config/del/env') do |dir|
          output = capture_output do
            run_with_args(%w(config del env test), client)
          end

          expect( output ).to include "Configuration file not found!"
          expect( output ).to include "Have you tried 'config init' first?"
        end
      end

      it "deletes an existing environment" do
        with_target_dir('config/del/env') do |dir|
          run_with_args(%w(config init -q), client)

          run_with_args(%w(config add env test1 http://example.com), client)

          run_with_args(%w(config del env test1), client)

          expect( AmsLayout.configuration.base_urls.key?(:test1) ).to be false
        end
      end

      it "deletes matching credentials when deleting an environment" do
        with_target_dir('config/del/env') do |dir|
          run_with_args(%w(config init -q), client)

          run_with_args(%w(config add env test1 http://example.com), client)
          run_with_args(%w(config add credentials test1 testuser1 testpass1), client)

          run_with_args(%w(config del env test1), client)

          expect( AmsLayout.configuration.base_urls.key?(:test1) ).to be false
          expect( AmsLayout.configuration.credentials.key?(:test1) ).to be false
        end
      end
    end

    context "credentials" do

      it "displays an error if configuration hasn't been init'd" do
        with_target_dir('config/del/credentials') do |dir|
          output = capture_output do
            run_with_args(%w(config del credentials test), client)
          end

          expect( output ).to include "Configuration file not found!"
          expect( output ).to include "Have you tried 'config init' first?"
        end
      end

      it "deletes existing credentials" do
        with_target_dir('config/del/credentials') do |dir|
          run_with_args(%w(config init -q), client)

          run_with_args(%w(config add env test1 http://example.com), client)
          run_with_args(%w(config add credentials test1 testuser1 testpass1), client)

          run_with_args(%w(config del credentials test1), client)

          expect( AmsLayout.configuration.credentials.key?(:test1) ).to be false
        end
      end

      it "does not delete matching environment when deleting credentials" do
        with_target_dir('config/del/credentials') do |dir|
          run_with_args(%w(config init -q), client)

          run_with_args(%w(config add env test1 http://example.com), client)
          run_with_args(%w(config add credentials test1 testuser1 testpass1), client)

          run_with_args(%w(config del credentials test1), client)

          expect( AmsLayout.configuration.base_urls.key?(:test1) ).to be true
          expect( AmsLayout.configuration.credentials.key?(:test1) ).to be false
        end
      end
    end
  end
end

