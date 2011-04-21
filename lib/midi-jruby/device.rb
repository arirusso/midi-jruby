module MIDIJRuby

  #
  # Module containing methods used by both input and output devices when using the
  # ALSA driver interface
  #
  module Device

                # has the device been initialized?
    attr_reader :enabled,
                # unique int id 
                :id,
                # name property from javax.sound.midi.MidiDevice.Info
                :name,
                # description property from javax.sound.midi.MidiDevice.Info
                :description,
                # vendor property from javax.sound.midi.MidiDevice.Info
                :vendor,
                # :input or :output
                :type 

    alias_method :enabled?, :enabled
    
    def initialize(id, device, options = {}, &block)
      @name = options[:name]
      @description = options[:description]
      @vendor = options[:vendor]
      @id = id
      @device = device

      # cache the type name so that inspecting the class isn't necessary each time
      @type = self.class.name.split('::').last.downcase.to_sym

      @enabled = false
    end

    # select the first device of type <em>type</em>
    def self.first(type)
      all_by_type[type].first
    end

    # select the last device of type <em>type</em>
    def self.last(type)
      all_by_type[type].last
    end

    # a Hash of :input and :output devices
    def self.all_by_type
      available_devices = { :input => [], :output => [] }
      count = -1
      MidiSystem.get_midi_device_info.each do |info|
        device = MidiSystem.get_midi_device(info)
        opts = { :name => info.get_name, 
                 :description => info.get_description, 
                 :vendor => info.get_vendor }
        available_devices[:output] << Output.new(count += 1, device, opts) unless device.get_max_receivers.zero?
        available_devices[:input] << Input.new(count += 1, device, opts) unless device.get_max_transmitters.zero?
      end
      available_devices
    end

    # all devices of both types
    def self.all
      all_by_type.values.flatten
    end

  end

end