require "helper"

class MIDIJRuby::IOTest < Test::Unit::TestCase

  # ** these tests assume that TestOutput is connected to TestInput
  context "MIDIJRuby" do

    setup do
      @output = $test_device[:output].open
      @input = $test_device[:input].open
      @input.buffer.clear
    end

    context "full IO" do

      context "using Arrays" do

        setup do
          @messages = TestHelper.numeric_messages
          @messages_arr = @messages.inject(&:+).flatten
          @received_arr = []
          @pointer = 0
        end

        should "do IO" do
          @messages.each do |msg|

            $>.puts "sending: " + msg.inspect

            @output.puts(msg)
            sleep(1)
            received = @input.gets.map { |m| m[:data] }.flatten

            $>.puts "received: " + received.inspect

            assert_equal(@messages_arr.slice(@pointer, received.length), received)
            @pointer += received.length
            @received_arr += received
          end
          assert_equal(@messages_arr.length, @received_arr.length)
        end
      end

      context "using byte Strings" do

        setup do
          @messages = TestHelper.string_messages
          @messages_str = @messages.join
          @received_str = ""
          @pointer = 0
        end

        should "do IO" do
          @messages.each do |msg|

            $>.puts "sending: " + msg.inspect

            @output.puts(msg)
            sleep(1)
            received = @input.gets_bytestr.map { |m| m[:data] }.flatten.join
            $>.puts "received: " + received.inspect

            assert_equal(@messages_str.slice(@pointer, received.length), received)
            @pointer += received.length
            @received_str += received
          end
          assert_equal(@messages_str, @received_str)

        end

      end

    end

  end

end
