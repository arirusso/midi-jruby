# frozen_string_literal: true

$LOAD_PATH.unshift(File.join('..', 'lib'))

require 'midi-jruby'
require 'pp'

pp MIDIJRuby::Device.all_by_type
