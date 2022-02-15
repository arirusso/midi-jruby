# frozen_string_literal: true

$LOAD_PATH.unshift(File.join('..', 'lib'))

require 'midi-jruby'

output = MIDIJRuby::Output.all.last
sysex_msg = [0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7]

output.open { |output| output.puts(sysex_msg) }
