require 'java'
require 'forwardable' 

#
# Set of modules and classes for interacting with javax.sound.midi
#
module MIDIJRuby
  
    VERSION = "0.0.5"
       
end

require 'midi-jruby/device'
require 'midi-jruby/input'
require 'midi-jruby/output'