##############################################################################
# File::    string.rb
# Purpose:: String monkey patches
# 
# Author::    Jeff McAffee 07/08/2014
# Copyright:: Copyright (c) 2014, kTech Systems LLC. All rights reserved.
# Website::   http://ktechsystems.com
##############################################################################


# Re-open String class and add snakecase method.
class String
  def ams_layout_snakecase
    # Strip everything but alphanumerics, :, _, - and space
    # Replace :: with /
    # Separate CamelCased text with _
    # Remove :
    # Replace space and - with _
    # Replace multiple _ with one _
    self.gsub(/[^a-zA-Z0-9:_\s-]/, '').
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    gsub(/:/, '').
    gsub(/[\s-]/, '_').
    gsub(/(_)+/,'_').
    downcase
  end
end

