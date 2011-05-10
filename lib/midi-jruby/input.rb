require 'forwardable'

module MIDIJRuby
		
  #
  # Input device class
  #
  class Input
    
    import javax.sound.midi.Transmitter

    include Device
    
    attr_reader :buffer
    
    class InputReceiver
      
      include javax.sound.midi.Receiver
      extend Forwardable
    
      attr_reader :stream

      def initialize
        @buffer, @internal_buffer = [], []
      end
      
      def read
        to_return = @internal_buffer.dup
        @internal_buffer.clear
        to_return
      end
      
      def send(msg, timestamp = -1)
        if msg.respond_to?(:get_packed_msg)
          @internal_buffer << unpack(msg.get_packed_msg)
        else
          str = String.from_java_bytes(msg.get_data)
          arr = str.unpack("C" * str.length)
          arr.insert(0, msg.get_status)
          @internal_buffer << arr 
        end
      end      
      
      private
      
      def unpack(msg)
        # there's probably a better way of doing this
        o = []
        s = msg.to_s(16)
        while s.length > 0 
          o << s.slice!(0,2).hex
        end
        o.reverse        
      end
     
    end

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
      @listener.join
      msgs = @internal_buffer.dup
      @internal_buffer.clear
      spawn_listener
      msgs 
    end
    alias_method :read, :gets
    
    # same as gets but returns message data as string of hex digits as such:
    # [ 
    #   { :data => "904060", :timestamp => 904 },
    #   { :data => "804060", :timestamp => 1150 },
    #   { :data => "90447F", :timestamp => 1300 }
    # ]
    #
    #
    def gets_s
      msgs = gets
      msgs.each { |msg| msg[:data] = msg[:data].map { |b| s = b.to_s(16).upcase; b < 16 ? s = "0" + s : s; s }.join }
      msgs  
    end
    alias_method :gets_bytestr, :gets_s
    alias_method :gets_hex, :gets_s

    # enable this the input for use; can be passed a block
    def enable(options = {}, &block)
      @device.open
      @transmitter = @device.get_transmitter
      @transmitter.set_receiver(InputReceiver.new)
      @internal_buffer = []
      @start_time = Time.now.to_f
      spawn_listener
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
      @listener.kill
      @transmitter.close
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
    
    private
    
    # give a message its timestamp and package it in a Hash
    def get_message_formatted(raw)
      time = ((Time.now.to_f - @start_time) * 1000).to_i # same time format as winmm
      { :data => raw, :timestamp => time }
    end
    
    # launch a background thread that collects messages
    def spawn_listener
      @listener = Thread.fork do
        while (msgs = @transmitter.get_receiver.read).empty? do
          sleep(0.1)
        end
        msgs.each do |raw|
          msg = hex_string_to_numeric_byte_array(raw)
          @buffer << msg
          @internal_buffer << msg          
        end
      end
    end
    
    # convert byte str to byte array 
    def hex_string_to_numeric_byte_array(str)
      bytes = []
      until m.eql?("")
        bytes << str.slice!(0, 2).hex
      end
      bytes
    end

  end

end