module MIDIJRuby

  #
  # Module containing methods used by both input and output devices when using the
  # ALSA driver interface
  #
  module Device

    attr_reader :enabled, # has the device been initialized?
                :id, # the id of the device
                :name,
                :description,
                :type # :input or :output

    alias_method :enabled?, :enabled
    
    def initialize(id, device, options = {}, &block)
      @name = options[:name]
      @description = options[:description]
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
      count = 0
      MidiSystem.get_midi_device_info.each do |info|
        device = MidiSystem.get_midi_device(info)
        unless device.get_max_transmitters.zero?
          output = Output.new(count, device, :name => info.get_name, :description => info.get_description)
          count += 1 
          available_devices[:output] << output
        end
        unless device.get_max_receivers.zero?
          input = Input.new(count, device, :name => info.get_name, :description => info.get_description)
          count += 1
          available_devices[:input] << input
        end 
      end
      available_devices
    end

    # all devices of both types
    def self.all
      all_by_type.values.flatten
    end

  end

end