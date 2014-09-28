module MIDIJRuby
  
  # Output device class
  class Output

    import javax.sound.midi.ShortMessage
    import javax.sound.midi.SysexMessage
    
    include Device
    
    # Close this output
    def close
      @device.close
      @enabled = false
    end
    
    # Output the given MIDI message
    # @param [String] data A MIDI message expressed as a string of hex digits 
    def puts_s(data)
      data = data.dup
      output = []
      until (string = data.slice!(0,2)) == ""
        output << string.hex
      end
      puts_bytes(*output)
    end
    alias_method :puts_bytestr, :puts_s
    alias_method :puts_hex, :puts_s

    # Output the given MIDI message
    # @param [*Fixnum] data A MIDI messages expressed as Numeric bytes 
    def puts_bytes(*data)
      bytes = Java::byte[data.size].new
      data.each_with_index { |byte, i| bytes.ubyte_set(i, byte) }
      message = data.first.eql?(0xF0) ? SysexMessage.new : ShortMessage.new
      message.set_message(bytes, data.length.to_java(:int))
      @device.get_receiver.send(message, 0)
    end
    
    # Output the given MIDI message
    # @param [*Fixnum, *String] args 
    def puts(*args)
      case args.first
        when Array then puts_bytes(*args.first)
        when Numeric then puts_bytes(*args)
        when String then puts_bytestr(*args)
      end
    end
    alias_method :write, :puts
    
    # Enable this device; also takes a block
    def enable(options = {}, &block)
      @device.open
      @enabled = true
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
    alias_method :open, :enable
    alias_method :start, :enable
    
    # Select the first output
    def self.first
      Device.first(:output) 
    end

    # Select the last output
    def self.last
      Device.last(:output)  
    end
    
    # All outputs
    def self.all
      Device.all_by_type[:output]
    end
  end
  
end
