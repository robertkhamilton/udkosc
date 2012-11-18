require 'rubygems'
require 'osc-ruby'

# DECLARE CONSTANTS
DEFAULTHOST = "localhost"
DEFAULTPORT = "7001"
CONNECTION = [DEFAULTHOST, DEFAULTPORT]
SPACE = " "
OSCROOT = "/udkosc/script"
PLAYERMOVE = "playermove"
CAMERAMOVE = "cameramove"
STARTBLOCK = "["
ENDBLOCK = "]"
BLOCK = "block"
WAIT = "wait"
PLAYERX = "x"
PLAYERY = "y"
PLAYERZ = "z"
PLAYERSPEED = "speed"
PLAYERJUMP = "jump"
PLAYERCROUCH = "crouch"
PLAYERPITCH = "pitch"
PLAYERYAW = "yaw"
PLAYERROLL = "roll"
PLAYERSTOP = "stop"
PLAYERTELEPORT = "teleport"
CAMERAX = "x"
CAMERAY = "y"
CAMERAZ = "z"
CAMERASPEED = "speed"
CAMERAPITCH = "pitch"
CAMERAYAW = "yaw"
CAMERAROLL = "roll"
SLEW = "slew"
DUR = "dur"
SLEWRATE = 20.0 # ms
METHOD = "method"
USERID = "userid"
SLEEP = "sleep"
OSCMESSAGE = "oscmessage"
OSCBUNDLE = "oscbundle"
ROTATIONCONSTANT = 182.044403
COMMENT = "#"
CONSOLE = "console"
BEHINDVIEW = "behindview"
BLANK = ""
DEFAULTSPEED = 300.0
$commands = Hash.new
$commands[BEHINDVIEW] = 1

module CMD
  BEHINDVIEW = 1
  OSCMOVE = 2
  def get(val)

  end
end

$currentTime = 0.0
$currentBlockTime = 0.0
$inblock = false
$blockUtime = 0.0
$validCommands = [PLAYERMOVE, CAMERAMOVE, WAIT, STARTBLOCK, ENDBLOCK, CONSOLE]
# Parameters to track slew value
$currentVals = Hash.new

class BundleMessage
  attr_accessor :starttime, :msg

  include Comparable

  def initialize(starttime, msg)
    @starttime = starttime
    @msg = msg
  end

  def getTime
    return @starttime
  end

  def getMsg
    return @msg
  end

  def <=>(other)
    @starttime <=> other.starttime
  end

end

def preprocess(arr)

  processedArray = Array.new
  localMoveArrayCmds = [PLAYERX, PLAYERY, PLAYERZ]
  localCurrentSpeed = 0.0
  localPlayerStopped = false
  localInBlock = false

  # step through each line
  arr.each_with_index { |line, index|

    inputArray = processLine(line.strip)

    # if playermove stop call
    if !localInBlock

      break if inputArray[0] == nil

      if inputArray[0] == PLAYERMOVE

        if inputArray[1] == PLAYERSTOP

          # set global
          localPlayerStopped = true

        elsif inputArray[1] == PLAYERSPEED

          # RKH - changed from "currentSpeed = "; keep in mind if issues
          localcurrentSpeed = inputArray[2]

        elsif [PLAYERX, PLAYERY, PLAYERZ].include?(inputArray[1])

          if localPlayerStopped

            # insert row of speed = currentVal
            #processedArray << "#{PLAYERMOVE} #{PLAYERSPEED} #{localCurrentSpeed} #{inputArray[inputArray.count-1]}"

            localPlayerStopped = false
          end

        end

        # processedArray << line

      elsif inputArray[0] == STARTBLOCK

        # if block has a playermove command [x,y,z] then add speed cmd
        localInBlock = true

      end

    elsif inputArray[0] == ENDBLOCK

      localInBlock = false

    end

    processedArray << line

  }

  return processedArray

end

def preProcessInput(lineArray)

  # Create hash to hold block structures
  blockHash = Hash.new

  # PREPROCESS INPUT TO IDENTIFY BLOCKS
  blockarray = Array.new

  blockStart = NIL

  lineArray.each_with_index { |line, index|

    # parse line input into array
    inputArray = processLine(line.strip)

    if inputArray[0] == STARTBLOCK
      blockStart = index
    elsif inputArray[0] == ENDBLOCK
      blockHash[blockStart] = index
    elsif inputArray[0] == COMMENT
      # do nothing in case of comment
    elsif !$validCommands.include?(inputArray[0])
      puts "INPUT COMMAND #{inputArray[0]} IS INVALID. VALID COMMANDS ARE:", $validCommands
      Process.exit
    elsif inputArray[0] == BLANK
      # do nothing for blank lines
    elsif inputArray[0] == NIL
    end
  }

  return blockHash

end

def createSleep(params)
  messageArray = Array.new
  msg = params[DUR]
  sleepMsg = Hash.new
  sleepMsg[SLEEP] = msg
  messageArray << sleepMsg
  return messageArray
end

def createConsoleCommand(params, val)

  localRoot = OSCROOT + val
  messageArray = Array.new
  params.each_pair do |k,v|
    if k !=METHOD
      # Fake Enum of acceptable commands
      val = $commands[v]
      if val != nil
        msg = OSC::Message.new("#{localRoot}", val)
        oscMsg = Hash.new
        oscMsg[OSCMESSAGE] = msg
        messageArray << oscMsg
      end
    end
  end

  return messageArray

end

# Optional timetag value
def createMove(params, val, *timetag)

  localRoot = OSCROOT + "/" + val
  localUID = nil
  messageArray = Array.new
  noProcessArray = [METHOD, SLEW, WAIT, USERID]
  rotationParams = [CAMERAPITCH, CAMERAYAW, CAMERAYAW, PLAYERPITCH, PLAYERYAW, PLAYERROLL]


  if params.has_key?(USERID)
    localUID=params[USERID].to_f()
    $currentVals[PLAYERMOVE+USERID] = localUID
  else
    if val==PLAYERMOVE
      localUID=$currentVals[PLAYERMOVE+USERID]
    end
  end

  # If this call has a slew value, create slew set of messages
  if params.has_key?(SLEW)

    slewCount = params[SLEW].to_i / SLEWRATE.to_i

    params.each_pair do |k,v|

      #Scale Camera vals by constant: ROTATIONCONSTANT
      if rotationParams.include?(k)
        v = v.to_f() * ROTATIONCONSTANT
        #puts "rotated v #{v}"
      end

      # For data hashes, create a new OSC message and sleep call and pass them back
      if !noProcessArray.include?(k)

        for i in 1..slewCount
          # Scale param value by slewCount and "current" param value
          #   - find which param it is, take its current value
          #   - for i=1 (first val in the slew block) start with currentVal for that param and add the stepp'd slew value
          #   - for each slew'd val do the same
          if k == PLAYERYAW || k == PLAYERPITCH || k == PLAYERROLL
            $currentVals["#{val}#{k}"] = (v.to_f() / slewCount.to_f())
            puts $currentVals["#{val}#{k}"]
            puts v.to_f()
          else
            $currentVals["#{val}#{k}"] = $currentVals["#{val}#{k}"] + (v.to_f() / slewCount.to_f())
          end
          #puts "rotated v2 #{v / slewCount.to_f()}"

          # calc time for future use as timetag
          timeNow=Time.now()

          msg = OSC::Message.new_with_time("#{localRoot}/#{k}", 1000.00, NIL, $currentVals["#{val}#{k}"],localUID)
          oscMsg = Hash.new
          oscMsg[OSCMESSAGE] = msg
          messageArray << oscMsg

          # space out slew'd messages with ms sleep calls (all but last?)
          if i <= slewCount
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

        if rotationParams.include?(k)
          v = v.to_f() * ROTATIONCONSTANT
        end

        if k==PLAYERSTOP #|| k== PLAYERCROUCH
          # puts k
          $currentVals["#{val}#{k}"] = 1.0
          msg = OSC::Message.new_with_time("#{localRoot}/#{k}", 1000.00, NIL,$currentVals[PLAYERMOVE+USERID])
        else

          # If setting playerspeed > 0, set currentVal of PLAYERSTOP to 0, indicating that we're moving
          if k==PLAYERSPEED
            if v.to_f() > 0.0
              $currentVals["#{val}#{PLAYERSTOP}"] = 0.0
            end
          end

          # Don't Aggregate jump height, teleport, userid
          if k==PLAYERJUMP || k==USERID
            $currentVals["#{val}#{k}"] = v.to_f()
          elsif k==PLAYERTELEPORT
            # $currentVals["#{val}#{k}"] = "#{v[0]} #{v[1]} #{v[2]}"
            msg = OSC::Message.new_with_time("#{localRoot}/#{k}", 1000.00, NIL, v[0].to_f(), v[1].to_f(), v[2].to_f(), localUID)
            oscMsg = Hash.new
            oscMsg[OSCMESSAGE] = msg
            messageArray << oscMsg
          else
            #puts "CURRENTVALS: #{val}: #{k}"
            # $currentVals["#{val}#{k}"] = $currentVals["#{val}#{k}"] + (v.to_f())
            if val==CAMERAMOVE
              $currentVals["#{val}#{k}"] = $currentVals["#{val}#{k}"] + (v.to_f())
            else
              $currentVals["#{val}#{k}"] = v.to_f()
            end
          end

          if k!=PLAYERTELEPORT
            msg = OSC::Message.new_with_time("#{localRoot}/#{k}", 1000.00, NIL, $currentVals["#{val}#{k}"], localUID)
          end
        end

        if k!=PLAYERTELEPORT
          oscMsg = Hash.new
          oscMsg[OSCMESSAGE] = msg
          messageArray << oscMsg
        end
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
    when COMMENT
      # do nothing in case of comment
    when CONSOLE
      params[CONSOLE] = val[1]
    when PLAYERMOVE
      params[USERID] = val[count -1]

      if count == 3
        # jump/stop currently uses 3 total params; default val to 1 for jump, switch to PLAYERSPEED = 0 for stop

        if val[1]==PLAYERJUMP
          params[val[1]] = 1
        elsif val[1]==PLAYERSTOP
          params[val[1]] = 0.0
          #elsif val[1]==PLAYERCROUCH
          #params[val[1]] = $currentVals["#{PLAYERMOVE}#{PLAYERCROUCH}"]%1
        end
      end

      if count > 3

        if val[1]==PLAYERTELEPORT

          # playermove teleport 500.0 500.0 500.0 1
          teleportCoordinates = Array.new
          teleportCoordinates[0] = val[2]
          teleportCoordinates[1] = val[3]
          teleportCoordinates[2] = val[4]
          params[val[1]] = teleportCoordinates

        else
          (1..count-3).step(2) {|i| params[val[i]] = val[i+1] }

          if count.odd?
            params[SLEW] = val[count-2]
          end
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
    when COMMENT
      # do nothing in case of comment
    when CONSOLE
      messages = createConsoleCommand(params, "/#{CONSOLE}")
    when PLAYERMOVE
      messages = createMove(params, "#{PLAYERMOVE}")
    when CAMERAMOVE
      messages = createMove(params, "#{CAMERAMOVE}")
    when WAIT
      messages = createSleep(params)
    else

  end

  return messages

end

def sendMessage(queue)

  #@client = OSC::Client.new( HOST, PORT )
  @client = OSC::Client.new( CONNECTION[0], CONNECTION[1] )

  queue.each do |msg|

    if not msg.nil?

      msg.each do |aMsg|

#        aMsg.each { |k,v| puts "#{k} => #{v}" }

        aMsg.each_pair do |k,v|
          if k == OSCMESSAGE
            @client.send(v)
          elsif k == OSCBUNDLE
            if !v.is_a? Array
              @client.send(v)
            end
          elsif k == SLEEP
            sleep v.to_f()/1000.0
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

  $currentVals["#{PLAYERMOVE}#{PLAYERX}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERY}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERZ}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERSPEED}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERPITCH}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERYAW}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERROLL}"] = 0.0
  $currentVals["#{CAMERAMOVE}#{CAMERAX}"] = 0.0
  $currentVals["#{CAMERAMOVE}#{CAMERAY}"] = 0.0
  $currentVals["#{CAMERAMOVE}#{CAMERAZ}"] = 0.0
  $currentVals["#{CAMERAMOVE}#{CAMERASPEED}"] = 0.0
  $currentVals["#{CAMERAMOVE}#{CAMERAPITCH}"] = 0.0
  $currentVals["#{CAMERAMOVE}#{CAMERAYAW}"] = 0.0
  $currentVals["#{CAMERAMOVE}#{CAMERAROLL}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERSTOP}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERJUMP}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERCROUCH}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{PLAYERTELEPORT}"] = 0.0
  $currentVals["#{PLAYERMOVE}#{USERID}"] = -1

end

def createBlockMessages(val)

  # Array to hold unordered queue of all slewd messages for the given queue message
  blockQueue = Array.new

  method = val[0]

  # build hash
  params = buildHash(val)

  # RETURNS ARRAY OF OSCMESSAGES AND SLEEP CALLS FOR EACH SLEWD VALUE, OR SINGLE MSG FOR NON SLEWD VALUES
  case method
    when COMMENT
      # Ignore comment lines
    when PLAYERMOVE
      messages = createMove(params, "#{PLAYERMOVE}")
    when CAMERAMOVE
      messages = createMove(params, "#{CAMERAMOVE}")
    when WAIT
      messages = createSleep(params)
    else
  end

  # messages is an array of MOVES. For each message, create a sortable bundle message with time
  messages.each do |msg|

    # get start time for each message by summing sleep calls btwn msgs

    # if message is SLEEP + val hash...
    if msg.has_key?(SLEEP)

      $currentBlockTime = $currentBlockTime.to_f() + msg[SLEEP].to_f()

    else

      lCurrentTime = $currentBlockTime

      # Add message and time to object and add to queue
      blockQueue << BundleMessage.new(lCurrentTime, msg)

    end

  end

  $currentBlockTime = 0.0

  # RETURNS ARRAY OF BUNDLEMESSAGE OBJECTS WITH obj.starttime param to be used in sorting bundles
  return blockQueue

end

def sortBlockArray(blockArray)

  #SORT BLOCKARRAY ON TIME
  blockArray.sort!

  return blockArray

end

def createSortedBundle(messages)

  # FIND UNIQUE SET OF STARTTIMES - EACH ONE WILL BE A SEPARATE BUNDLE
  uniqueStarttimes = Array.new

  # RETURN ARRAY OF OSC BUNDLES
  bundleArray = Array.new

  # CREATE SET OF UNIQUE START TIMES
  messages.each do |msg|
    if !uniqueStarttimes.include? msg.starttime
      uniqueStarttimes << msg.starttime
    end
  end

  lastStarttime = 0.0

  # ADD MESSAGES TO AN ARRAY FOR EACH UNIQUE START TIME. THESE WILL BECOME BUNDLES
  uniqueStarttimes.each do |stime|



    currentBundle = Array.new

    messages.each_with_index do |mesg, index|

      # ADD NEW OSC MESSAGE TO CURRENT BUNDLE ARRAY
      if mesg.starttime == stime
        currentBundle << mesg.getMsg[OSCMESSAGE]  #mesg.getMsg
      end

      # ON FIRST MSG PROCESSED LOOK AT LAST START TIME AND ADD SLEEP MSG BEFORE CONTINUING
      if stime != lastStarttime

        # ADD SLEEP MSG HASH TO BUNDLE ARRAY ON LAST VAL
        sleepMsg = Hash.new
        sleepMsg[SLEEP] = stime - lastStarttime
        bundleArray << sleepMsg

        # UPDATE LAST START TIME
        lastStarttime = stime

      end
    end

    oscBundle = Hash.new
    nextBundle = OSC::Bundle.new(NIL, *currentBundle)
    oscBundle[OSCBUNDLE] = OSC::Bundle.new(NIL, *currentBundle)
    bundleArray << oscBundle

  end

  return bundleArray

end


ARGV.each_with_index do |a, index|
  # puts "Argument: #{a}"
  if a != nil
    CONNECTION[index] = a
  end
end


# Create queue (Array) to hold created OSC Messages
sendQueue = Array.new

# GET INPUT FILE FROM COMMANDLINE
if CONNECTION[2] !=nil
  inputfile = File.new(CONNECTION[2], "rb")
else
  inputfile = File.new("./data/input.txt", "rb")
end

linearray = inputfile.readlines
inputfile.close

# Pre-process linearray for PLAYERSTOP calls
linearray = preprocess(linearray)

# INIT CURRENT VALUE HASH
initCurrentValues

# PREPROCESS INPUT FOR BLOCK STRUCTURES (k=startIndex, v=endIndex)
blocks = preProcessInput(linearray)

# CREATE OUTPUT FILE
File.open('./data/output.txt', 'w') do |outfile|

  # PARSE INPUT FILE INTO ARRAY
  linearray.each_with_index do |f, index|

    # parse line input into array
    paramArray = processLine(f)

    if paramArray[0] != COMMENT

      # are we in the block's starting row
      if blocks.has_key?(index)

        $inblock = true

        # CREATE HOLDING ARRAY FOR BLOCK MESSAGES
        blockArray = Array.new

        # CYCLE THROUGH LINEARRAY UNTIL DONE WITH BLOCK
        # DO WE USE INDEX OR INDEX + 1 HERE
        for i in (index+1)..(blocks[index]-1)

          # CREATE ARRAY FOR EACH BLOCK MESSAGE
          blockParamArray = processLine(linearray[i])

          # CREATE ARRAY of BLOCK MESSAGE Object ARRAYS WITH TIME AND MSG PARAMETERS FOR SORTING AND ADD TO ARRAY
          if blockParamArray[0] != COMMENT
            blockArray << createBlockMessages(blockParamArray)
          end

        end

        # blockArray is an Array of Arrays. Merge each subarray into one uber array
        blockCount = blockArray.count

        uberBlockArray = Array.new

        # MERGE EACH BLOCK ARRAY INTO UBER ARRAY
        blockArray.each do |bl|
          bl.each do |b|
            uberBlockArray << b
          end
        end

        # RETURN SORTED ARRAY OF OBJECTS
        sortedBlockArray = sortBlockArray(uberBlockArray)

        # FOR EACH GROUP OF SAME STARTTIME OBJECTS, CREATE NEW OSC BUNDLE
        newBundle = createSortedBundle(sortedBlockArray)

        sendQueue << newBundle

      else

        if $inblock == false && paramArray[0] != STARTBLOCK

          # build OSC message from parameter array
          messages = createMessages(paramArray)

          # add OSC message to send queue
          sendQueue << messages

        elsif paramArray[0] == ENDBLOCK

          $inblock = false

        end
      end
    end
  end

  # send outgoing OSC messages
  sendMessage(sendQueue)

end