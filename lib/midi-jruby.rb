# Realtime MIDI IO in JRuby using the javax.sound.midi API
#
# Ari Russo
# (c) 2011-2014
# Licensed under Apache 2.0

# libs
require "java"
require "forwardable" 

# modules
require "midi-jruby/api"
require "midi-jruby/device"

# classes
require "midi-jruby/input"
require "midi-jruby/output"

module MIDIJRuby
  
  VERSION = "0.1.2"
       
end
