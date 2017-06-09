module MIDIJRuby

  # Common methods used by both input and output devices
  module Device

    attr_reader :enabled, # has the device been initialized?
                :id, # unique int id
                :name, # name property from javax.sound.midi.MidiDevice.Info
                :description, # description property from javax.sound.midi.MidiDevice.Info
                :vendor, # vendor property from javax.sound.midi.MidiDevice.Info
                :type # :input or :output

    alias_method :enabled?, :enabled

    # @param [Fixnum] The uuid for the given device
    # @param [Java::ComSunMediaSound::MidiInDevice, Java::ComSunMediaSound::MidiOutDevice] device The underlying Java device object
    # @param [Hash] options
    # @option options [String] :description
    # @option options [String] :name
    # @option options [String] :vendor
    def initialize(id, device, options = {})
      @name = options[:name]
      @description = options[:description]
      @vendor = options[:vendor]
      @id = id
      @device = device

      @type = get_type
      @enabled = false
    end

    # Select the first device of the given direction
    # @param [Symbol] direction
    # @return [Input, Output]
    def self.first(direction)
      all_by_type[direction].first
    end

    # Select the last device of the given direction
    # @param [Symbol] direction
    # @return [Input, Output]
    def self.last(direction)
      all_by_type[direction].last
    end

    # A hash of :input and :output devices
    # @return [Hash]
    def self.all_by_type
      @devices ||= {
        :input => API.get_inputs,
        :output => API.get_outputs
      }
    end

    # All devices of both directions
    # @return [Array<Input, Output>]
    def self.all
      all_by_type.values.flatten
    end

    private

    # @return [String]
    def get_type
      self.class.name.split("::").last.downcase.to_sym
    end

  end

end
