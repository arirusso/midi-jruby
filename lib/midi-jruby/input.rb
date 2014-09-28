module MIDIJRuby
    
  # Input device class
  class Input
    
    import javax.sound.midi.Transmitter

    include Device
    
    attr_reader :buffer
        
    #
    # An array of MIDI event hashes as such:
    # [
    #   { :data => [144, 60, 100], :timestamp => 1024 },
    #   { :data => [128, 60, 100], :timestamp => 1100 },
    #   { :data => [144, 40, 120], :timestamp => 1200 }
    # ]
    #
    # The data is an array of numeric bytes
    # The timestamp is the number of millis since this input was enabled
    #
    def gets
      loop until queued_messages?
      messages = queued_messages
      @pointer = @buffer.length
      messages
    end
    alias_method :read, :gets
    
    # Same as Input#gets but returns message data as string of hex digits:
    # [ 
    #   { :data => "904060", :timestamp => 904 },
    #   { :data => "804060", :timestamp => 1150 },
    #   { :data => "90447F", :timestamp => 1300 }
    # ]
    #
    def gets_s
      messages = gets
      messages.each { |message| message[:data] = numeric_bytes_to_hex_string(message[:data]) }
      messages  
    end
    alias_method :gets_bytestr, :gets_s
    alias_method :gets_hex, :gets_s

    # Enable this the input for use; can be passed a block
    def enable(options = {}, &block)
      @device.open
      @transmitter = @device.get_transmitter
      @transmitter.set_receiver(InputReceiver.new)
      initialize_buffer
      @start_time = Time.now.to_f
      initialize_listener
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

    # Close this input
    def close
      @listener.kill
      @transmitter.close
      @device.close
      @enabled = false
    end
    
    # Select the first input
    def self.first
      Device.first(:input)  
    end

    # Select the last input
    def self.last
      Device.last(:input) 
    end
    
    # All inputs
    def self.all
      Device.all_by_type[:input]
    end
    
    private
    
    def initialize_buffer
      @buffer = []
      @pointer = 0
      def @buffer.clear
        @pointer = 0
        super        
      end
    end
    
    def now
      now = Time.now.to_f - @start_time
      now * 1000
    end
    
    # give a message its timestamp and package it in a Hash
    def get_message_formatted(raw, time) 
      { 
        :data => raw, 
        :timestamp => time 
      }
    end
    
    def queued_messages
      @buffer.slice(@pointer, @buffer.length - @pointer)
    end
    
    def queued_messages?
      @pointer < @buffer.length
    end
    
    # Launch a background thread that collects messages
    def initialize_listener
      @listener = Thread.new do
        begin
          loop do        
            while (messages = poll_system_buffer).empty?
              sleep(1.0/1000)
            end
            populate_local_buffer(messages) unless messages.empty?
          end
        rescue Exception => exception
          Thread.main.raise(exception)
        end
      end
      @listener.abort_on_exception = true
      @listener
    end
    
    def poll_system_buffer
      @transmitter.get_receiver.read
    end
    
    def populate_local_buffer(messages)
      @buffer += messages.compact.map do |raw| 
        get_message_formatted(raw, now)
      end
    end

    def numeric_bytes_to_hex_string(bytes)
      string_bytes = bytes.map do |byte| 
        string = byte.to_s(16).upcase
        string = "0#{string}" if byte < 16
        string
      end
      string_bytes.join
    end 

    class InputReceiver
      
      include javax.sound.midi.Receiver
      extend Forwardable
    
      attr_reader :stream

      def initialize
        @buffer = []
      end
      
      def read
        to_return = @buffer.dup
        @buffer.clear
        to_return
      end
      
      def send(message, timestamp = -1)
        bytes = if message.respond_to?(:get_packed_message)
          packed = message.get_packed_message
          unpack(packed)
        else
          string = String.from_java_bytes(message.get_message)
          string.unpack("C" * string.length)
        end
        @buffer << bytes
      end      
      
      private
      
      def unpack(message)
        bytes = []
        string = message.to_s(16)
        string = "0#{s}" if string.length.divmod(2).last > 0
        while string.length > 0
          string_byte = string.slice!(0,2)
          bytes << string_byte.hex
        end
        bytes.reverse        
      end
     
    end
   
  end

end
