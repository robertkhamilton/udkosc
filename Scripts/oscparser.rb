require 'rubygems'
require 'osc-ruby'
require 'yaml'

wait = ARGV[1]			# wait boolean toggles whether the padded time at the beginning of recorded yml osc action is used
m_time = 0
start_time = 0
final_output = ""
output_filename = ARGV[0]

@messages = YAML.load($stdin)
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
  sleep(dt) if dt > 0
  message = OSC::OSCPacket.messages_from_network(m[:message]).first  
  output = m_time.to_s + ", " + message.address

  @a = message.to_a
  @a.each_with_index do |arg, index|
    #p arg
	output = output + ", " + arg.to_s
  end
  final_output = final_output + "" + output + "\n"
end

File.open(output_filename, 'w') { |file| 
    file.write(final_output) 
}  
