# frozen_string_literal: true
require 'helper'

describe 'MIDIJRuby input buffer' do
  # These tests assume that the test input is connected to the test output
  let(:input) { SpecHelper.device[:input].open }
  let(:output) { SpecHelper.device[:output].open }
  before do
    input.buffer.clear
  end
  after do
    input.close
    output.close
  end

  describe 'Source#buffer' do
    let(:messages) { SpecHelper.numeric_messages }

    it 'has the correct messages in the buffer' do
      bytes = []
      messages.each do |message|
        p "sending: #{message}"
        output.puts(message)
        bytes += message

        sleep 0.3

        buffer = input.buffer.map { |m| m[:data] }.flatten
        p "received: #{buffer}"
        expect(buffer).to eq(bytes)
      end
      buffer_length = input.buffer.map { |m| m[:data] }.flatten.length
      expect(buffer_length).to eq(bytes.length)
    end
  end
end
