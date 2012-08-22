require 'rubygems'
require 'osc-ruby'

# DECLARE CONSTANTS
HOST = "localhost"
PORT = "7000"
SPACE = " "
OSCROOT = "/udkosc/script"
PLAYERMOVE = "playerMove"
CAMERAMOVE = "cameraMove"
STARTBLOCK = "["
ENDBLOCK = "]"
WAIT = "wait"
PLAYERX = "X"
PLAYERY = "Y"
PLAYERZ = "Z"
PLAYERSPEED = "speed"
PLAYERJUMP = "jump"
SLEW = "slew"
DUR = "dur"
SLEWRATE = 20.0 # ms
METHOD = "method"
USERID = "userid"
SLEEP = "sleep"

$currentTime = 0.0
$inblock = false
$blockUtime = 0.0

# Parameters to track slew value
$currentVals = Hash.new

# Create queue (Array) to hold created OSC Messages
sendQueue = Array.new

# GET INPUT FILE FROM COMMANDLINE
inputfile = File.new("./data/input.txt", "rb")
linearray = inputfile.readlines
inputfile.close



def createSleep(params)
    messageArray = Array.new
    msg = params[DUR]
    sleepMsg = Hash.new
    sleepMsg[SLEEP] = msg
    messageArray << sleepMsg
    return messageArray
end


def createBundle()

# BUNDLE EXAMPLE
#          msg2 = OSC::Message.new("#{localRoot}/#{k}", "#{$currentVals[k]}")  
#		  msg = OSC::Bundle.new(NIL, msg2)		  
	  
end


# Optional timetag value
def createMove(params, val, *timetag)
  localRoot = OSCROOT + val
  messageArray = Array.new
  noProcessArray = [METHOD, SLEW, USERID, WAIT]
  
  # If this call has a slew value, create slew set of messages
  if params.has_key?(SLEW)
    
    slewCount = params[SLEW].to_i / SLEWRATE.to_i
    
    params.each_pair do |k,v|

      # For data hashes, create a new OSC message and sleep call and pass them back
      if !noProcessArray.include?(k)

        for i in 1..slewCount        
		  # Scale param value by slewCount and "current" param value			
		  #   - find which param it is, take its current value
		  #   - for i=1 (first val in the slew block) start with currentVal for that param and add the stepp'd slew value			
		  #   - for each slew'd val do the same
		  $currentVals[k] = $currentVals[k] + (v.to_f() / slewCount.to_f())
						

          #msg = OSC::Message.new("#{localRoot}/#{k}", "#{$currentVals[k]}")  
          
          timeNow=Time.now()
		  msg = OSC::Message.new_with_time("#{localRoot}/#{k}", 1000.00, NIL, "#{$currentVals[k]}")  
		  
# BUNDLE EXAMPLE
#          msg2 = OSC::Message.new("#{localRoot}/#{k}", "#{$currentVals[k]}")  
#		  msg = OSC::Bundle.new(NIL, msg2)		  
		  
          oscMsg = Hash.new
          oscMsg[OSC] = msg
		  messageArray << oscMsg
			
		  # space out slew'd messages with ms sleep calls on all but last slew'd msg	
		  if i < slewCount
		    sleepMsg = Hash.new
		    sleepMsg[SLEEP] = SLEWRATE
		    messageArray << sleepMsg
          end                      
	    end
      end      
    end      
  else # if not a SLEW value...

    params.each_pair do |k,v|
      if !noProcessArray.include?(k)    
        msg = OSC::Message.new("#{localRoot}/#{k}", "#{params[k]}")                                
        oscMsg = Hash.new
        oscMsg[OSC] = msg
        messageArray << oscMsg
      end
    end
  end
  
  return messageArray
  
end

def createPlayerMove(params)
  localRoot = OSCROOT + "/playermove"
  messageArray = Array.new
  noProcessArray = [METHOD, SLEW, USERID, WAIT]
  
  # If this call has a slew value, create slew set of messages
  if params.has_key?(SLEW)
    
    slewCount = params[SLEW].to_i / SLEWRATE.to_i
    
    params.each_pair do |k,v|

      # For data hashes, create a new OSC message and sleep call and pass them back
      if !noProcessArray.include?(k)

        for i in 1..slewCount        
		  # Scale param value by slewCount and "current" param value			
		  #   - find which param it is, take its current value
		  #   - for i=1 (first val in the slew block) start with currentVal for that param and add the stepp'd slew value			
		  #   - for each slew'd val do the same
		  $currentVals[k] = $currentVals[k] + v.to_f() / slewCount.to_f()
						
          msg = OSC::Message.new("#{localRoot}/#{k}", "#{$currentVals[k]}")
          oscMsg = Hash.new
          oscMsg[OSC] = msg
		  messageArray << oscMsg
			
		  # space out slew'd messages with ms sleep calls on all but last slew'd msg	
		  if i < slewCount
		    sleepMsg = Hash.new
		    sleepMsg[SLEEP] = SLEWRATE
		    messageArray << sleepMsg
          end                      
	    end
      end      
    end      
  else # if not a SLEW value...

    params.each_pair do |k,v|
      if !noProcessArray.include?(k)    
        msg = OSC::Message.new("#{localRoot}/#{k}", "#{params[k]}")                                
        oscMsg = Hash.new
        oscMsg[OSC] = msg
        messageArray << oscMsg
      end
    end
  end
  
  return messageArray
  
end



def buildHash(val)

  # sendQueue will hold each queue in an array

  params = Hash.new
  params[METHOD] = val[0]

  method = val[0]  
  count = val.count
  
  case method
    when PLAYERMOVE
      params[USERID] = val[count -1]      

      if count == 3
        # jump currently uses 3 total params; default val to 1
        params[val[1]] = 1
        
	  elsif count > 3
	    (1..count-3).step(2) {|i| params[val[i]] = val[i+1] }

	    if count.odd?
	      params[SLEW] = val[count-2]
	    end	  
	  end	  
      
    when CAMERAMOVE
    
	  (1..count-2).step(2) {|i| params[val[i]] = val[i+1] }
	    
	  if count.even?
	    params[SLEW] = val[count-1]
	  end	  	        
	  
	when WAIT
	  params[DUR] = val[1]	
  end
  
  # Track current time in blocks with total time for block
  if $inblock
  
    # find largest val between all block slews or total of wait and slew
    if params.has_key?(WAIT)
      $currentTime = $currentTime.to_f() + params[WAIT].to_f()
    end
  end
  
  if params.has_key?(DUR)
    $currentTime = $currentTime.to_f() + params[DUR].to_f()
  elsif params.has_key?(SLEW)
    $currentTime = $currentTime.to_f() + params[SLEW].to_f()
  end
  	    
  return params
  
end



def createMessages(val)
  
  method = val[0]  
  
  # track when commands are part of a block
  if method == STARTBLOCK
    $inblock = true
  elsif method == ENDBLOCK
    $inblock = false
  else 
    # build hash
    params = buildHash(val)
  end
  
  case method
    when PLAYERMOVE
	  messages = createMove(params, "/#{PLAYERMOVE}")						
    when CAMERAMOVE
	  messages = createMove(params, "/#{CAMERAMOVE}")						    
    when WAIT
      messages = createSleep(params)
    else

  end  

  return messages
  
end



def sendMessage(queue)

  @client = OSC::Client.new( HOST, PORT )

  queue.each do |msg|
	  
	if not msg.nil?
  	  if msg.is_a? Array

  	    msg.each do |val|

  	      val.each_pair do |k,v|
  	        if k == OSC 	            	          
              @client.send(v)
  	        elsif k == SLEEP
  	          sleep v.to_f()/1000.0
  	        end
		  end
  	    end
	  end
	end	  
  end
end



def processLine(val)
  
  # parse line on word-breaks and check osc function call
  array_val = val.split(SPACE)
  
  return array_val
  
end

def initCurrentValues

  $currentVals[PLAYERX] = 0.0
  $currentVals[PLAYERY] = 0.0
  $currentVals[PLAYERZ] = 0.0  
  $currentVals[PLAYERSPEED] = 0.0
  
end

# INIT CURRENT VALUE HASH
initCurrentValues

# CREATE OUTPUT FILE
File.open('./data/output.txt', 'w') do |outfile|

  # PARSE INPUT FILE INTO ARRAY
  for f in linearray

	# parse line input into array
	paramArray = processLine(f)
		
	# build OSC message from parameter array
    messages = createMessages(paramArray)  
	
	# add OSC message to send queue
	sendQueue << messages
    
  end

  # send outgoing OSC messages
  sendMessage(sendQueue)
  
end


# CONVERT HRT (Human Readable Text) TO RUBY CALLS
# STORE OUTPUT TO ARRAY AND CALL client.send and sleep FUNCTIONS PROGRAMATTICALLY)
# @client.send( OSC::Message.new( "/greeting", "hullo!" ))
# sleep 1
# @client.send( OSC::Message.new( "/greeting/a/b/c", "hullo?", 4 ))
# sleep 1
