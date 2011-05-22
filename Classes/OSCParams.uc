class OSCParams extends Actor
	config(OSC);

// values stored in DefaultOSC.ini
 var config string OSCHostname;
 var config int OSCPort;

 // quasi-globals
 var float OSCProjectileSpeed;
 
function string getOSCHostname()
{
	return OSCHostname;
}

function int getOSCPort()
{
	return OSCPort;
}

function setOSCHostname(string val)
{
	OSCHostname=val;
	SaveConfig();
}

function setOSCPort(int val)
{
	OSCPort=val;
	SaveConfig();
}

function float getOSCProjectileSpeed()
{
	return OSCProjectileSpeed;
}

function setOSCProjectileSpeed(float val)
{
	OSCProjectileSpeed=val;
}

defaultproperties
{
}