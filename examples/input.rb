# frozen_string_literal: true

require 'English'
require 'English'
require 'English'
$LOAD_PATH.unshift(File.join('..', 'lib'))

require 'midi-jruby'

# this program selects the first midi input and sends an inspection of the first 10 messages
# messages it receives to standard out

num_messages = 10

# MIDIJRuby::Device.all.to_s will list your midi devices
# or amidi -l from the command line

MIDIJRuby::Input.first.open do |input|
  $DEFAULT_OUTPUT.puts 'send some MIDI to your input now...'

  num_messages.times do
    m = input.gets
    $DEFAULT_OUTPUT.puts(m.inspect)
  end

  $DEFAULT_OUTPUT.puts 'finished'
end
