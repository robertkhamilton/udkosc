class OSCTrigger extends Trigger
	placeable
	DLLBind(oscpack_1_0_2);
	
struct OSCTriggerStruct
{
	var string Hostname;
	var int Port;
	var string TriggerName;
	var int On;
};

dllimport final function triggerActivated(OSCTriggerStruct a);

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);
	`log("OSCTrigger: Touch");
}

/** called when this trigger has successfully been used to activate a Kismet event */
function NotifyTriggered()
{
	`log("OSCTrigger: NotifyTriggered");
	Super.NotifyTriggered();
	sendTrigger(1);
}

function UnTrigger()	
{
	Super.UnTrigger();
	sendTrigger(0);
}

function sendTrigger(int val)
{
	local OSCTriggerStruct currentTrigger;
	local OSCParams OSCParameters;
	local string OSCHostname;
	local int OSCPort;
	
	`log("OSCTrigger: sendTrigger");
	
	OSCParameters = spawn(class'OSCParams');
	OSCHostname = OSCParameters.getOSCHostname();
	OSCPort = OSCParameters.getOSCPort();
	
	currentTrigger.Hostname = OSCHostname;
	currentTrigger.Port = OSCPort;	
	currentTrigger.TriggerName = ""$Tag$""; //"testTrigger";
	currentTrigger.On = val;
	
	triggerActivated(currentTrigger);
}
