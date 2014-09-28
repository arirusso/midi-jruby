require "helper"

class MIDIJRuby::InputBufferTest < Test::Unit::TestCase

  context "MIDIJRuby" do

    setup do
      @output = $test_device[:output].open
      @input = $test_device[:input].open
      @input.buffer.clear
      @pointer = 0
    end

    context "Source#buffer" do

      setup do
        @messages = TestHelper.numeric_messages
        @messages_arr = @messages.inject(&:+).flatten
        @received_arr = []
      end

      should "have the correct messages in the buffer" do
        bytes = []
        @messages.each do |message|
          puts "sending: #{message.inspect}"
          @output.puts(message)
          bytes += message

          sleep(1)

          buffer = @input.buffer.map { |m| m[:data] }.flatten
          puts "received: #{buffer.to_s}"
          assert_equal(bytes, buffer)
        end
        assert_equal(bytes.length, @input.buffer.map { |m| m[:data] }.flatten.length)
      end

    end

  end
end
