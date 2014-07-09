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
  def snakecase
    # Strip the following characters out: /, (, ), #, &
    # Replace :: with /
    # Separate CamelCased text with _
    # Replace space with _
    # Replace - with _
    # Replace multiple _ with one _
    self.gsub("/", '').
    gsub("(",'').
    gsub(")",'').
    gsub("#",'').
    gsub("&",'').
    gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    gsub(" ",'_').
    tr("-", "_").
    gsub(/(_)+/,'_').
    downcase
  end
end

