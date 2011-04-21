dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'midi-jruby'

# this program selects the first midi output and sends some arpeggiated chords to it

notes = [36, 40, 43] # C E G
octaves = 5
duration = 0.1

# MIDIJRuby::Device.all.to_s will list your midi devices
# or amidi -l from the command line

MIDIJRuby::Output.first.open do |output|

  (0..((octaves-1)*12)).step(12) do |oct|

    notes.each do |note|
    	
      output.puts([0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7]) # note on
      sleep(duration)				     # wait
      output.puts(0x80, note + oct, 100) # note off
      
    end
    
  end

end