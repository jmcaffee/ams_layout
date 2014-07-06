$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ams_layout'

Dir["#{File.expand_path('./support', __dir__)}/*.rb"].each do |file|
  require file unless file =~/fakeweb\/.*\.rb/
end

