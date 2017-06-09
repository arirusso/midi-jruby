$:.unshift(File.join("..", "lib"))

require "midi-jruby"
require "pp"

pp MIDIJRuby::Device.all_by_type
