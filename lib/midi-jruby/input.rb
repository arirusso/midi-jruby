module MIDIJRuby
    
  # Input device class
  class Input
    
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
    # @return [Array<Hash>]
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
    # @return [Array<Hash>]
    def gets_s
      messages = gets
      messages.each { |message| message[:data] = numeric_bytes_to_hex_string(message[:data]) }
      messages
    end
    alias_method :gets_bytestr, :gets_s
    alias_method :gets_hex, :gets_s

    # Enable this the input for use; can be passed a block
    # @param [Hash] options
    # @param [Proc] block
    # @return [Input] self
    def enable(options = {}, &block)
      initialize_input
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
    # @return [Boolean]
    def close
      @listener.kill
      API.close_input(@device)
      @enabled = false
    end
    
    # Select the first input
    # @return [Input]
    def self.first
      Device.first(:input)  
    end

    # Select the last input
    # @return [Input]
    def self.last
      Device.last(:input) 
    end
    
    # All inputs
    # @return [Array<Input>]
    def self.all
      Device.all_by_type[:input]
    end
    
    private

    # Initialize the input components
    # @return [Boolean]
    def initialize_input
      initialize_buffer
      API.enable_input(@device)
      @start_time = Time.now.to_f
      initialize_listener
      true
    end
    
    # Initialize the input buffer
    # @return [Boolean]
    def initialize_buffer
      @buffer = []
      @pointer = 0
      def @buffer.clear
        @pointer = 0
        super        
      end
    end
    
    # Get a timestamp for the current time
    # @return [Fixnum]
    def now
      now = Time.now.to_f - @start_time
      now * 1000
    end
    
    # A hash of a MIDI message and corresponding timestamp
    # @param [Array<Fixnum>] message
    # @param [Fixnum] timestamp
    # @return [Hash]
    def get_message_formatted(message, timestamp) 
      { 
        :data => message, 
        :timestamp => timestamp
      }
    end
    
    # Messages in the buffer
    # @return [Array<Array<Fixnum>>]
    def queued_messages
      @buffer.slice(@pointer, @buffer.length - @pointer)
    end
    
    # Are there any new messages in the buffer?
    # @return [Boolean]
    def queued_messages?
      @pointer < @buffer.length
    end
    
    # Launch a background thread that collects messages
    # @return [Thread]
    def initialize_listener
      @listener = Thread.new do
        begin
          loop do        
            while (messages = API.read_input(@device)).empty?
              sleep(1.0/1000)
            end
            add_to_buffer(messages) unless messages.empty?
          end
        rescue Exception => exception
          Thread.main.raise(exception)
        end
      end
      @listener.abort_on_exception = true
      @listener
    end
        
    # @param [Array<Array<Fixnum>>]
    # @return [Array<Array<Fixnum>>]
    def add_to_buffer(messages)
      @buffer += messages.compact.map do |message| 
        get_message_formatted(message, now)
      end
    end

    # Convert an array of numeric bytes to a hex string (eg [0x90, 0x40, 0x40] -> "904040")
    # @param [Array<Fixnum>] bytes
    # @return [String]
    def numeric_bytes_to_hex_string(bytes)
      string_bytes = bytes.map do |byte| 
        string = byte.to_s(16).upcase
        string = "0#{string}" if byte < 0x10
        string
      end
      string_bytes.join
    end 
   
  end

end
