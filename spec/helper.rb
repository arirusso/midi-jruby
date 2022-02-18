# frozen_string_literal: true

$LOAD_PATH.unshift(File.join('..', 'lib'))

require 'rspec'
require 'midi-jruby'

module SpecHelper
  module_function

  # http://stackoverflow.com/questions/8148898/java-midi-in-mac-osx-broken
  def sysex_ok?
    RbConfig::CONFIG["host_os"] != 'darwin'
  end

  def bytestrs_to_ints(arr)
    data = arr.map { |m| m[:data] }.join
    output = []
    until (bytestr = data.slice!(0, 2)).eql?('')
      output << bytestr.hex
    end
    output
  end

  def numeric_messages
    messages = [
      [0x90, 100, 100], # NOTE: on
      [0x90, 43, 100], # NOTE: on
      [0x90, 76, 100], # NOTE: on
      [0x90, 60, 100], # NOTE: on
      [0x80, 100, 100] # NOTE: off
    ]
    messages << [0xF0, 0x41, 0x10, 0x42, 0x12, 0x40, 0x00, 0x7F, 0x00, 0x41, 0xF7] if sysex_ok?
    messages
  end

  def string_messages
    messages = [
      '906440', # NOTE: on
      '804340' # NOTE: off
    ]
    messages << 'F04110421240007F0041F7' if sysex_ok?
    messages
  end

  def device
    @device ||= select_devices
  end

  def select_devices
    @device ||= {}
    { input: MIDIJRuby::Input.all, output: MIDIJRuby::Output.all }.each do |type, devs|
      puts ''
      puts "select an #{type}..."
      while @device[type].nil?
        devs.each do |device|
          puts "#{device.id}: #{device.name}"
        end
        selection = $stdin.gets.chomp
        next unless selection != ''

        selection = selection.to_i
        @device[type] = devs.find { |d| d.id == selection }
        puts "selected #{selection} for #{type}" unless @device[type]
      end
    end
    @device
  end
end
