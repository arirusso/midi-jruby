dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'

require 'midi-jruby'
require 'pp'

pp MIDIJRuby::Device.all_by_type