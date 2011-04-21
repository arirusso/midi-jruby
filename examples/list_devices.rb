dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'midi-jruby'

include MIDIJRuby

p Device.all_by_type