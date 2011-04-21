module MIDIJRuby
	
  #
  # Input device class
  #
  class Input
    
    include Device

    #
    # returns an array of MIDI event hashes as such:
    # [
    #   { :data => [144, 60, 100], :timestamp => 1024 },
    #   { :data => [128, 60, 100], :timestamp => 1100 },
    #   { :data => [144, 40, 120], :timestamp => 1200 }
    # ]
    #
    # the data is an array of Numeric bytes
    # the timestamp is the number of millis since this input was enabled
    #
    def gets
 
    end
    alias_method :read, :gets
    
    # same as gets but returns message data as String of hex digits
    def gets_bytestr

    end

    # enable this the input for use; can be passed a block
    def enable(options = {}, &block)
      @device.open
      @receiver = device.get_receiver
      @enabled = true
      unless block.nil?
        begin
          block.call(self)
        ensure
          close
        end
      end
    end
    alias_method :open, :enable
    alias_method :start, :enable

    # close this input
    def close
      @device.close
      @enabled = false
    end
    
    def self.first
      Device.first(:input)	
    end

    def self.last
      Device.last(:input)	
    end
    
    def self.all
      Device.all_by_type[:input]
    end

  end

end