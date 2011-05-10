module MIDIJRuby
  
  #
  # Output device class
  #
  class Output
    import javax.sound.midi.ShortMessage
    import javax.sound.midi.SysexMessage
    
    include Device
    
    # close this output
    def close
      @device.close
      @enabled = false
    end
    
    # sends a MIDI message comprised of a String of hex digits 
    def puts_s(data)
      data = data.dup
      output = []
      until (str = data.slice!(0,2)).eql?("")
        output << str.hex
      end
      puts_bytes(*output)
    end
    alias_method :puts_bytestr, :puts_s
    alias_method :puts_hex, :puts_s

    # sends a MIDI messages comprised of Numeric bytes 
    def puts_bytes(*data)
      if data.first.eql?(0xF0)
        msg = SysexMessage.new
        msg.set_message(data.to_java(:byte), data.length)
      else
        msg = ShortMessage.new
        msg.set_message(*data)
      end
      @device.get_receiver.send(msg, 0)
    end
    
    # send a MIDI message of an indeterminant type
    def puts(*a)
      case a.first
        when Array then puts_bytes(*a.first)
        when Numeric then puts_bytes(*a)
        when String then puts_bytestr(*a)
      end
    end
    alias_method :write, :puts
    
    # enable this device; also takes a block
    def enable(options = {}, &block)
      @device.open
      @enabled = true
      unless block.nil?
        begin
          block.call(self)
        ensure
          close
        end
      else
        self
      end
    end
    alias_method :open, :enable
    alias_method :start, :enable
    
    def self.first
      Device.first(:output) 
    end

    def self.last
      Device.last(:output)  
    end
    
    def self.all
      Device.all_by_type[:output]
    end
  end
  
end