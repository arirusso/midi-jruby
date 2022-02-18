# frozen_string_literal: true

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

    SYSEX_STATUS_BYTES = [0xF0, 0xF7].freeze

    # Get all MIDI devices that are available via javax.sound.midi
    # @return [Array<Hash>] A set of hashes for each available device
    def get_devices
      MidiSystem.get_midi_device_info.map do |info|
        jdevice = MidiSystem.get_midi_device(info)
        {
          device: jdevice,
          id: get_uuid,
          name: info.get_name,
          description: info.get_description,
          vendor: info.get_vendor
        }
      end
    end

    # Get all MIDI inputs that are available via javax.sound.midi
    # @return [Array<Input>]
    def get_inputs
      jinputs = get_devices.reject { |device| device[:device].get_max_transmitters.zero? }
      jinputs.map { |jinput| Input.new(jinput[:id], jinput[:device], jinput) }
    end

    # Get all MIDI outputs that are available via javax.sound.midi
    # @return [Array<Output>]
    def get_outputs
      joutputs = get_devices.reject { |device| device[:device].get_max_receivers.zero? }
      joutputs.map { |joutput| Output.new(joutput[:id], joutput[:device], joutput) }
    end

    # Enable the given input device to receive MIDI messages
    # @param [Java::ComSunMediaSound::MidiInDevice] device
    # @return [Boolean]
    def enable_input(device)
      device.open
      @transmitter ||= {}
      @transmitter[device] = device.get_transmitter
      @transmitter[device].set_receiver(InputReceiver.new)
      true
    end

    # Enable the given output to emit MIDI messages
    # @param [Java::ComSunMediaSound::MidiOutDevice] device
    # @return [Boolean]
    def enable_output(device)
      @receiver ||= {}
      @receiver[device] = device.get_receiver
      device.open
      true
    end

    # Close the given output device
    # @param [Java::ComSunMediaSound::MidiOutDevice] device
    # @return [Boolean]
    def close_output(device)
      unless @receiver[device].nil?
        @receiver[device].close
        @receiver.delete(device)
      end
      device.close
      true
    end

    # Close the given input device
    # @param [Java::ComSunMediaSound::MidiInDevice] device
    # @return [Boolean]
    def close_input(device)
      # http://bugs.java.com/bugdatabase/view_bug.do?bug_id=4914667
      # @transmitter[device].close
      # device.close
      @transmitter.delete(device)
      true
    end

    # Read any new MIDI messages from the given input device
    # @param [Java::ComSunMediaSound::MidiInDevice] device
    # @return [Array<Array<Fixnum>>]
    def read_input(device)
      @transmitter[device].get_receiver.read
    end

    # Write the given MIDI message to the given output device
    # @param [Java::ComSunMediaSound::MidiOutDevice] device
    # @param [Array<Fixnum>] data
    # @return [Boolean]
    def write_output(device, data)
      bytes = Java::byte[data.size].new
      data.each_with_index { |byte, i| bytes.ubyte_set(i, byte) }
      if SYSEX_STATUS_BYTES.include?(data.first)
        message = SysexMessage.new
        message.set_message(bytes, data.length.to_java(:int))
      else
        message = ShortMessage.new
        begin
          message.set_message(*bytes)
        rescue
          # support older java versions
          message.set_message(bytes)
        end
      end
      @receiver[device].send(message, device.get_microsecond_position)
      true
    end

    private

    # Generate a uuid for a MIDI device
    # @return [Fixnum]
    def get_uuid
      @id ||= -1
      @id += 1
    end

    # Input event handler class
    class InputReceiver
      include javax.sound.midi.Receiver

      attr_reader :stream

      def initialize
        @buffer = []
      end

      # Pluck messages from the buffer
      # @return [Array<Array<Fixnum>>]
      def read
        messages = @buffer.dup
        @buffer.clear
        messages
      end

      # Add a new message to the buffer
      # @param [javax.sound.midi.MidiMessage] message
      # @param [Fixnum] timestamp
      # @return [Array<Array<Fixnum>>]
      def send(message, _timestamp = -1)
        bytes = if message.respond_to?(:get_packed_message)
                  packed = message.get_packed_message
                  unpack(packed)
                else
                  string = String.from_java_bytes(message.get_message)
                  string.unpack('C' * string.length)
                end
        @buffer << bytes
      end

      def close; end

      private

      # @param [String]
      # @return [Array<Fixnum>]
      def unpack(message)
        bytes = []
        string = message.to_s(16)
        string = "0#{s}" if string.length.divmod(2).last.positive?
        string = string.rjust(6, '0')
        while string.length.positive?
          string_byte = string.slice!(0, 2)
          bytes << string_byte.hex
        end
        bytes.reverse
      end
    end
  end
end
