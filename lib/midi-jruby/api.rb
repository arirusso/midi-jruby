module MIDIJRuby
    
  # Access to javax.sound.midi
  module API

    import javax.sound.midi.MidiSystem
    import javax.sound.midi.MidiDevice
    import javax.sound.midi.MidiEvent
    import javax.sound.midi.Receiver
    import javax.sound.midi.ShortMessage
    import javax.sound.midi.SysexMessage
    import javax.sound.midi.Transmitter

    extend self

    def get_devices
      devices = MidiSystem.get_midi_device_info.map do |info|
        jdevice = MidiSystem.get_midi_device(info)
        { 
          :device => jdevice,
          :id => get_uuid,
          :name => info.get_name, 
          :description => info.get_description, 
          :vendor => info.get_vendor 
        }
      end
      devices
    end

    def get_inputs
      jinputs = get_devices.select { |device| !device[:device].get_max_transmitters.zero? }
      jinputs.map { |jinput| Input.new(jinput[:id], jinput[:device], jinput) }
    end

    def get_outputs
      joutputs = get_devices.select { |device| !device[:device].get_max_receivers.zero? }
      joutputs.map { |joutput| Output.new(joutput[:id], joutput[:device], joutput) } 
    end

    def enable_input(device)
      device.open
      @transmitter ||= {}
      @transmitter[device] = device.get_transmitter
      @transmitter[device].set_receiver(InputReceiver.new)
    end

    def enable_output(device)
      @receiver ||= {}
      @receiver[device] = device.get_receiver
      device.open
    end

    def close_output(device)
      device.close
    end

    def close_input(device)
      @transmitter[device].close
      device.close
    end

    def read_input(device)
      @transmitter[device].get_receiver.read
    end

    def write_output(device, data)
      bytes = Java::byte[data.size].new
      data.each_with_index { |byte, i| bytes.ubyte_set(i, byte) }
      message = data.first.eql?(0xF0) ? SysexMessage.new : ShortMessage.new
      message.set_message(bytes, data.length.to_java(:int))
      @receiver[device].send(message, 0)
    end

    private

    def get_uuid
      @id ||= -1
      @id += 1
    end

    class InputReceiver
      
      include javax.sound.midi.Receiver
    
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
