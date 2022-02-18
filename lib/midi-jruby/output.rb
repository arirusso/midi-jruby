# frozen_string_literal: true

module MIDIJRuby
  # Output device class
  class Output
    include Device

    # Close this output
    # @return [Boolean]
    def close
      API.close_output(@device)
      @enabled = false
    end

    # Output the given MIDI message
    # @param [String] data A MIDI message expressed as a string of hex digits
    # @return [Boolean]
    def puts_s(data)
      bytes = hex_string_to_numeric_bytes(data)
      puts_bytes(*bytes)
    end
    alias puts_bytestr puts_s
    alias puts_hex puts_s

    # Output the given MIDI message
    # @param [*Fixnum] data A MIDI messages expressed as Numeric bytes
    # @return [Boolean]
    def puts_bytes(*data)
      API.write_output(@device, data)
    end

    # Output the given MIDI message
    # @param [*Fixnum, *String] args
    # @return [Boolean]
    def puts(*args)
      case args.first
      when Array then args.each { |arg| puts(*arg) }
      when Numeric then puts_bytes(*args)
      when String then puts_bytestr(*args)
      end
    end
    alias write puts

    # Enable this device; also takes a block
    # @param [Hash] options
    # @param [Proc] block
    # @return [Output]
    def enable(_options = {})
      unless @enabled
        API.enable_output(@device)
        @enabled = true
      end
      if block_given?
        begin
          yield(self)
        ensure
          close
        end
      else
        self
      end
    end
    alias open enable
    alias start enable

    # Select the first output
    # @return [Output]
    def self.first
      Device.first(:output)
    end

    # Select the last output
    # @return [Output]
    def self.last
      Device.last(:output)
    end

    # All outputs
    # @return [Array<Output>]
    def self.all
      Device.all_by_type[:output]
    end

    private

    # Convert a hex string to numeric bytes (eg "904040" -> [0x90, 0x40, 0x40])
    # @param [String] string
    # @return [Array<Fixnum>]
    def hex_string_to_numeric_bytes(string)
      string = string.dup
      bytes = []
      until (string_byte = string.slice!(0, 2)) == ''
        bytes << string_byte.hex
      end
      bytes
    end
  end
end
