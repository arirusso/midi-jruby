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
    # @return [Boolean]
    def puts_bytes(*data)
      API.write_output(@device, data)
    end
    
    # Output the given MIDI message
    # @param [*Fixnum, *String] args 
    # @return [Boolean]
    def puts(*args)
      case args.first
        when Array then puts_bytes(*args.first)
        when Numeric then puts_bytes(*args)
        when String then puts_bytestr(*args)
      end
    end
    alias_method :write, :puts
    
    # Enable this device; also takes a block
    # @param [Hash] options
    # @param [Proc] block
    # @return [Output]
    def enable(options = {}, &block)
      API.enable_output(@device)
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
  end
  
end
