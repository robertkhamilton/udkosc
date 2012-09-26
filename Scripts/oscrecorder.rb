require 'rubygems'
require 'osc-ruby'
require 'yaml'

port = ARGV[0]

@server = OSC::Server.new( port )

@messages = []
@server.add_method // do | message |
  @messages << { :message => message.encode, :time => Time.now - @start }
end

begin
  @start = Time.now
  @server.run
rescue SystemExit, Interrupt
  puts @messages.to_yaml
end
