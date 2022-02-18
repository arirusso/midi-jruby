# frozen_string_literal: true

$LOAD_PATH.unshift(File.join('..', 'lib'))

require 'midi-jruby'

# this program selects the first midi output and sends some arpeggiated chords to it

output = MIDIJRuby::Output.first
notes = [36, 40, 43] # C E G
octaves = 5
duration = 0.1

# MIDIJRuby::Device.all.to_s will list your midi devices

output.open do |output|
  (0..((octaves - 1) * 12)).step(12) do |oct|
    notes.each do |note|
      output.puts(0x90, note + oct, 100) # NOTE: on
      sleep(duration) # wait
      output.puts(0x80, note + oct, 100) # NOTE: off
    end
  end
end
