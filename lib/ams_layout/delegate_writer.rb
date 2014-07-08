##############################################################################
# File::    delegate_writer.rb
# Purpose:: Generate a ruby source file that is a delegate class containing
#           the fields on the Loan Entry screen.
# 
# Author::    Jeff McAffee 06/23/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################

module AmsLayout
  class DelegateWriter

    attr_writer :source_file_name
    attr_writer :class_name
    attr_writer :delegated_class_name
    #attr_writer :aliases

    ##
    # Name of this class' source file
    #

    def source_file_name
      class_name.snakecase + '.rb'
    end

    ##
    # Name of this class
    #

    def class_name
      @class_name ||= AmsLayout.configuration.delegate_class_name
    end

    ##
    # Name of class we will delegate to
    #

    def delegated_class_name
      @delegated_class_name ||= AmsLayout.configuration.layout_class_name
    end

    ##
    # List of aliases for specified fields
    #

    def aliases
      @aliases ||= {}
    end

    def aliases=(data)
      @aliases = Hash(data)
    end

    ##
    # Write a class file, based on the the layout.yml, to the provided stream
    #

    def write stream, layout
      stream << header

      layout.each do |section_label, fields|
        stream << section(section_label)

        fields.each do |fld|
          stream << field(fld[:label], fld[:id], fld[:type])
          write_aliases stream, fld[:label], fld[:id], fld[:type]
        end # fields
      end # layout

      stream << footer
    end

  private

    ##
    # Write a field's aliases to the stream
    #

    def write_aliases stream, label, id, type
      label_aliases = aliases.key?(label) ? aliases[label] : []
      label_aliases.each do |al|
        stream << field_alias(al, id, type)
      end
    end

    ##
    # Emit a file header
    #

    def header
      text =<<TEXT
#############################################################################
# #{source_file_name}
#
# This file has been generated by AmsLayout.
# Do not modify this file manually.
#
#############################################################################

require_relative 'loan_entry_fields'
require 'nokogiri'

class #{class_name} < DelegateClass(#{delegated_class_name})

  ##
  # Capture and parse the page's raw HTML with Nokogiri
  # Returns a Nokogiri::HTML document
  #

  def html_doc
    @html_doc ||= Nokogiri::HTML(__getobj__.raw_html)
      #Nokogiri::HTML(html).css("table#ctl00_ContentPlaceHolder1_tblMain").each do |tbl|
  end

  ##
  # Return the first element matching the given ID
  # Returns a Nokogiri Element
  #

  def noko_element(id)
    html_doc.css(id).first
  end

  ##
  # Returns true if element is checked
  #

  def checked?(id)
    # el['type'] = 'checkbox'
    is_checked = noko_element(id)['checked']
    ! is_checked.nil?
  end

  ##
  # Returns a text element's value
  #

  def get_text_element_value(id)
    # el['type'] = 'text'
    value = noko_element(id)['value']
  end

  ##
  # Returns a textarea element's value
  #

  def get_textarea_element_value(id)
    noko_element(id).text
  end

  ##
  # Returns the selected option, '-- Please Select --' if no option is selected
  #

  def get_selected_option id
    elem = noko_element(id)
    elem.children.each do |c|
      if c.attributes.key? 'selected'
        return c.text
      end
    end

    # Return the default value if nothing is selected
    '-- Please Select --'
  end

  #
  # Fields (ordered by section as seen on screen)
  #
TEXT
    end

    ##
    # Emit a section header
    #

    def section label
      text =<<TEXT


  # Section: #{label}
TEXT
    end

    ##
    # Emit field methods
    #

    def field label, id, type
      case type
      when 'text'
        return text_field_methods(label, id, type)
      when 'textarea'
        return textarea_field_methods(label, id, type)
      when 'select'
        return select_field_methods(label, id, type)
      when 'checkbox'
        return checkbox_field_methods(label, id, type)
      else
        return "\n# unknown_field_type: #{label}, #{id}, #{type}\n"
      end
    end

    ##
    # Emit field methods for aliased fields
    #

    def field_alias label, id, type
      field label, id, type
    end

    ##
    # Emit text field methods
    #

    def text_field_methods label, id, type
      field_label = snakecase label
      field_id = '#' + id

      if field_id.include? 'PlaceHolder1_cn'
        return float_field_methods label, id, type
      end

      text =<<TEXT

  def #{field_label}=(value)
    if get_text_element_value('#{field_id}') != value
      super(value)
    # else skip sending the value.
    end
  end
TEXT
    end

    ##
    # Emit float field methods
    #

    def float_field_methods label, id, type
      field_label = snakecase label
      field_id = '#' + id

      text =<<TEXT

  def #{field_label}=(value)
    current_value = get_text_element_value('#{field_id}')

    current_value = '0' if current_value.empty?
    value = '0' if value.empty?

    if ((Float(current_value) * 1000) != (Float(value) * 1000))
      super(value)
    # else skip sending the value.
    end
  end
TEXT
    end

    ##
    # Emit textarea field methods
    #

    def textarea_field_methods label, id, type
      field_label = snakecase label
      field_id = '#' + id

      text =<<TEXT

  def #{field_label}=(value)
    if get_textarea_element_value('#{field_id}') != value
      super(value)
    # else skip sending the value.
    end
  end
TEXT
    end

    ##
    # Emit select field methods
    #

    def select_field_methods label, id, type
      field_label = snakecase label
      field_id = '#' + id

      text =<<TEXT

  def #{field_label}=(value)
    if get_selected_option('#{field_id}') != value
      super(value)
    # else skip sending the value.
    end
  end
TEXT
    end

    ##
    # Emit checkbox field methods
    #

    def checkbox_field_methods label, id, type
      field_label = snakecase label
      field_id = '#' + id

      text =<<TEXT

  def check_#{field_label}
    if ! checked?('#{field_id}')
      super()
    # else skip sending the value.
    end
  end

  def uncheck_#{field_label}
    if checked?('#{field_id}')
      super()
    # else skip sending the value.
    end
  end
TEXT
    end

    ##
    # Emit file footer
    #

    def footer
      text =<<TEXT

end # #{class_name}

TEXT
    end

    ##
    # Convert a field name to snake_case
    #

    def snakecase str
      snake = str.gsub /[^a-zA-Z0-9]/, '_'
      snake = snake.gsub /_+/, '_'
      snake.downcase
    end
  end # DelegateWriter
end # AmsLayout
