#
# MIDI-JRuby
# Realtime MIDI IO in JRuby using the javax.sound.midi API
#
# (c) 2011-2017 Ari Russo
# Licensed under Apache 2.0
# https://github.com/arirusso/midi-jruby
#

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

  VERSION = "0.1.6"

end
