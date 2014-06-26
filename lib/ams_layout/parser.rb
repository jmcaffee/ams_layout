##############################################################################
# File::    parser.rb
# Purpose:: Parse a Loan Entry screen and generate the layout data for the
#           controls on the screen.
#
# Author::    Jeff McAffee 06/21/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

require 'nokogiri'

module AmsLayout
  class Parser

    def layout
      @layout ||= {}
    end

    def parse html
      # Table: ctl00_ContentPlaceHolder1_tblMain
      Nokogiri::HTML(html).css("table#ctl00_ContentPlaceHolder1_tblMain").each do |tbl|
        tbl.css('tr').each do |row|
          parse_row row
        end
      end

      layout
    end

  private
    def parse_row row
      cells = row.css('td')

      if cells[0]['class'] == 'sectionheader'
        add_section cells[0].text
        return
      end

      if cells.size >= 2
        add_control build_control(cells[0], cells[1])
      end

      if cells.size >= 4
        add_control build_control(cells[2], cells[3])
      end
    end

    def add_section section_name
      @current_section = section_name
    end

    def current_section
      fail "@current_section not set" if @current_section.nil?

      if layout[@current_section].nil?
        layout[@current_section] = Array.new
      end

      layout[@current_section]
    end

    def add_control control
      current_section << control.to_hash unless control.is_a?(NullControl)
    end

    def build_control label_cell, control_cell
      assert_label_td label_cell
      assert_control_td control_cell

      label = label_cell.text.gsub("\u00A0", ' ').strip
      # Return if this is a blank cell
      return NullControl.new if label.empty?

      # Actual control is nested INPUT field
      ctrl = find_input_element(control_cell)
      if ctrl.nil?
        fail "Unable to determine input element.\n#{control_cell.inspect}"
      end
      id = ctrl['id']
      type = ctrl['type']
      type = ctrl.name if type.nil?
      assert_control_type type
      Control.new label, id, type
    end

    def find_input_element cell
      ctrl = cell.css('input').first
      ctrl = cell.css('select').first if ctrl.nil?
      ctrl = cell.css('textarea').first if ctrl.nil?
      ctrl
    end

    def assert_label_td cell
      label_classes = %w[LabelTD Mandatory]
      fail "TD does not contain class attribute of 'LabelTD'" unless label_classes.include?(cell['class'])
    end

    def assert_control_td cell
      fail "TD does not contain class attribute of 'ControlTD'" unless cell['class'] == 'ControlTD'
    end

    def assert_control_type type
      fail 'nil control type' if type.nil?
      fail "unexpected control type: #{type}" unless %w[text textarea select checkbox].include?(type)
    end

    class Control
      attr_reader :label, :id, :type

      def initialize label, id, type
        @label = label
        @id = id
        @type = type
      end

      def to_hash
        {label: @label, id: @id, type: @type}
      end
    end # Control

    class NullControl
      attr_reader :label, :id, :type

      def initialize
        @label = ''
        @id = ''
        @type = ''
      end

      def to_hash
        {label: @label, id: @id, type: @type}
      end
    end # Control
  end # Parser
end # AmsLayout

