module MIDIJRuby

  # Common methods used by both input and output devices
  module Device
    
    import javax.sound.midi.MidiSystem
    import javax.sound.midi.MidiDevice
    import javax.sound.midi.MidiEvent
    import javax.sound.midi.Receiver

    attr_reader :enabled, # has the device been initialized?
                :id, # unique int id
                :name, # name property from javax.sound.midi.MidiDevice.Info
                :description, # description property from javax.sound.midi.MidiDevice.Info
                :vendor, # vendor property from javax.sound.midi.MidiDevice.Info
                :type # :input or :output 

    alias_method :enabled?, :enabled
    
    def initialize(id, device, options = {}, &block)
      @name = options[:name]
      @description = options[:description]
      @vendor = options[:vendor]
      @id = id
      @device = device

      @type = get_type
      @enabled = false
    end

    # Select the first device of the given direction
    def self.first(direction)
      all_by_type[direction].first
    end

    # Select the last device of the given direction
    def self.last(direction)
      all_by_type[direction].last
    end

    # A hash of :input and :output devices
    def self.all_by_type
      available_devices = { 
        :input => [], 
        :output => [] 
      }
      count = -1
      MidiSystem.get_midi_device_info.each do |info|
        device = MidiSystem.get_midi_device(info)
        options = { 
          :name => info.get_name, 
          :description => info.get_description, 
          :vendor => info.get_vendor 
        }
        unless device.get_max_receivers.zero?
          available_devices[:output] << Output.new(count += 1, device, options) 
        end
        unless device.get_max_transmitters.zero?
          available_devices[:input] << Input.new(count += 1, device, options) 
        end
      end
      available_devices
    end

    # All devices of both directions
    def self.all
      all_by_type.values.flatten
    end

    private

    def get_type
      self.class.name.split('::').last.downcase.to_sym
    end

  end

end
