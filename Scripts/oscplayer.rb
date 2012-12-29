require 'rubygems'
require 'osc-ruby'
require 'yaml'

address = ARGV[0]
port = ARGV[1]
wait = ARGV[2]			# wait boolean toggles whether the padded time at the beginning of recorded yml osc action is used
m_time = 0
start_time = 0

@client = OSC::Client.new( address, port )
# @client = OSC::Client.new( 'localhost', 3334 )

@messages = YAML.load($stdin)
# e.g. @messages = YAML::load(File.open("/Users/rob/data/udkosc/git/udkosc/Scripts/pawn_0_spiral_4.yml"))

@start = Time.now

@messages.each_with_index do |m, index|

  if index == 0
    start_time = m[:time]
  end

  if wait=='true'
    m_time = m[:time]
  else
    m_time = m[:time] - start_time
  end

  dt = (@start + m_time) - Time.now
#  dt = (@start + m[:time]) - Time.now

  puts "sleeping #{dt}"
  sleep(dt) if dt > 0
  message = OSC::OSCPacket.messages_from_network(m[:message]).first
  p message
  @client.send(message)
end
