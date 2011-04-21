require 'java'

#
# Set of modules and classes for interacting with javax.sound.midi
#
module MIDIJRuby
  
    VERSION = "0.0.1"
    
    midi = javax.sound.midi
    import midi.MidiSystem
    import midi.MidiDevice
    import midi.MidiEvent
    import midi.ShortMessage
    import midi.Receiver 
    import midi.SysexMessage
    
end
 
require 'midi-jruby/device'
require 'midi-jruby/input'
require 'midi-jruby/output'