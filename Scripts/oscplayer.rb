require 'rubygems'
require 'osc-ruby'
require 'yaml'

address = ARGV[0]
port = ARGV[1]

@client = OSC::Client.new( address, port )
# @client = OSC::Client.new( 'localhost', 3334 )

@messages = YAML.load($stdin)

@start = Time.now
@messages.each do |m|
  dt = (@start + m[:time]) - Time.now
  puts "sleeping #{dt}"
  sleep(dt) if dt > 0
  message = OSC::OSCPacket.messages_from_network(m[:message]).first
  p message
  @client.send(message)
end
