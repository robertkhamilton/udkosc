/*******************************************************************************
    OSCPawn

    Creation date: 13/06/2010 01:00
    Copyright (c) 2010, beast
    <!-- $Id: NewClass.uc,v 1.1 2004/03/29 10:39:26 elmuerte Exp $ -->
*******************************************************************************/

class OSCPawn extends UTPawn
 notplaceable
 DLLBind(oscpack_1_0_2);

 // vars for moving trumbruticus trunk in code
var(NPC) SkeletalMeshComponent CurrentMesh;
var SkelControl_CCD_IK TrunkMover;

var SkelControl_CCD_IK OSCRightArm_CCD_IK;
var SkelControl_CCD_IK RightWing_CCD_IK;
var SkelControl_CCD_IK LeftWing_CCD_IK;

// state bools for skeletal mesh changing
var bool isValkordia;
var bool isTrumbruticus;

// array of bones for tracking
var array <name> currentBones;

// test vars for camera offsets
var int camoffsetx, camoffsety, camoffsetz;

// toggles and vars for side and down traces
var bool pawnDowntrace;
var bool pawnSidetrace;
var int gtracelength;
var int gdowntracelength;
var float gLeftTrace;
var float gRightTrace;
var float gDownTrace;
var int gtesttrace;

/**/
// OSC Mode value for toggling pawn and controller modes
var int gOSCMode;

// Pawn's unique ID
var int uid;

var bool sendingOSC;    // toggle to send OSC for this pawn
var bool receivingOSC;     // receiving OSC flag to prevent multiple calls to oscpack to instantiate listener threads
var bool sendDeltaOSC; // whether OSC messages are sent continuously or only on vector deltas

// Old iPad finger-touch code
var array<vector> fingerTouchArray;
var vector object1;
var vector object2;
var vector object3;
var vector object4;
var vector object5;

// vals for setting offsets and min/max for incoming XYZ co-ords
var vector OSCFingerOffsets;
var vector OSCFingerWorldMin;
var vector OSCFIngerWorldMax;
var vector OSCFingerSourceMax;
var vector OSCFingerSourceMin;
var bool OSCUseFingerTouches;
var int currentFingerTouches[5];
        
var float lastX;
var float lastY;
var float lastZ;
var bool lastCrouch;
var bool isCrouching;

var float seekingTurnRate;

var vector OSCCamera;
var bool OSCFreeCamera;                // OSC Controlled Free-moving camera, not attached to Pawn
var bool OSCAttachedCamera;            // OSC Controlled rotating camera attached to Pawn
var bool OSCFollowCamera;                // OSC moving camera which always targets pawn as its view target
var bool OSCFollowLockCamera;        // OSC controlled camera which always targets pawn as its view target
var bool OSCBehindCamera;

var int gRotatorOffset;  // 1177

// testing
var Rotator OSCRotation;

// Animation speed
var float valkordiaAnimSpeed;

// Air Speed
var float baseAirSpeed;

var int selectedPlayerMesh;

struct MyPlayerStruct
{
    var string PlayerName;
    var string PlayerPassword;
    var float Health;
    var float Score;
    var string testval;
};

struct PlayerStateStruct_works
{
    var string Hostname;
    var int Port;
    var string PlayerName;
    var float LocX;
    var float LocY;
    var float LocZ;
    var bool crouch;
};

// Adding LookPitch... etc to track pawn view to pass for binaural testing
struct PlayerStateStruct
{
    var string Hostname;
    var int Port;
    var int id;
    var string PlayerName;
    var float LocX;
    var float LocY;
    var float LocZ;
    var int crouch;
    var float Pitch;
    var float Yaw;
    var float Roll;
    var float leftTrace; 
    var float rightTrace;
    var float downTrace;
    var float sendCall;    // 1/0 Call is fired
    var float bone1X;
    var float bone1Y;
    var float bone1Z;
};

var vector gBone1;

struct PlayerStateStructTEST
{
    var string Hostname;
    var int Port;
    var string PlayerName;
    var float LocX;
    var float LocY;
    var float LocZ;
    var bool crouch;
};

struct OSCFingerController
{
    var float f1X;
    var float f1Y;
    var float f1Z;
    var float f1on;
    var float f2X;
    var float f2Y;
    var float f2Z;
    var float f2on;    
    var float f3X;
    var float f3Y;
    var float f3Z;
    var float f3on;    
    var float f4X;
    var float f4Y;
    var float f4Z;
    var float f4on;    
    var float f5X;
    var float f5Y;
    var float f5Z;
    var float f5on;    
};

struct OSCFingerMessageStruct
{
    var int fingerCount;
    var float X;
    var float Y;
    var float Z;
};

// Struct for holding data from point-click targeting method. Sent via OSC to host
struct PointClickStruct
{
    var string Hostname;
    var int Port;
    var string TraceHit;
    var string TraceHit_class;
    var string TraceHit_class_outerName;
    var float LocX;
    var float LocY;
    var float LocZ;
    var string HitInfo_material;
    var string HitInfo_physmaterial;
    var string HitInfo_hitcomponent;
};

struct OSCMessageStruct
{
    var float test;
};

struct OSCGameParams
{
    var float gameGravity;
    var float gameSpeed;
};

struct OSCScriptPlayerRotationStruct
{
    var float pitch;
    var float yaw;
    var float roll;
};

// OSC Camera data from Playercontroller
struct OSCScriptCameramoveStruct
{
    var float x;
    var float y;
    var float z;
    var float speed;
    var float pitch;
    var float yaw;
    var float roll;
};

// OSC Camera data from Playercontroller
var OSCScriptCameramoveStruct localOSCScriptCameramoveStruct;

//Global vars for this class
var OSCScriptPlayerRotationStruct localOSCScriptPlayerRotationStruct;
var OSCMessageStruct localOSCMessageStruct;
var OSCGameParams localOSCGameParamsStruct;
var OSCFingerController localOSCFingerControllerStruct;
var float lastGameGravity;
var float lastGameSpeed;


var OSCParams OSCParameters;
var string OSCHostname;
var int OSCPort;

// Bone Coords struct /* */
struct Coords
{
   var() config vector Origin, XAxis, YAxis, ZAxis;
};

var vector gCamLoc;
var rotator gCamRot;

// WAVE TRACE VARIABLE BLOCK
var array<vector> waveTraces;                    //Array to hold vector waveTraces
var bool bWaveTraceLog;                            
var bool bWaveTracePoints;
var bool bWaveTraceLines;
var bool bWaveTraceSpheres;
var bool bWaveTraceDebug;
var int waveTraceCount;
var int waveTraceRadius;
var int waveTraceSetSize;
var vector waveTraceStartLocation;

var() ParticleSystemComponent PSC_CallEmitter;
var name                    ValkordiaTailSocket;
var vector pscOffset;

// Player's "Call"
var bool gCall;
var float gSendCall;

dllimport final function sendOSCpointClick(PointClickStruct a);    
dllimport final function sendOSCPlayerState(PlayerStateStruct a);
dllimport final function OSCMessageStruct getOSCTest();
dllimport final function OSCGameParams getOSCGameParams();
dllimport final function float getOSCGameSpeed();
dllimport final function float getOSCGameGravity();
dllimport final function float getOSCTestfloat();
dllimport final function OSCFingerController getOSCFingerController();
dllimport final function vector getOSCFinger1();
dllimport final function initOSCReceiver();
dllimport final function OSCScriptPlayerRotationStruct getOSCScriptPlayerRotation();

//dllimport final function sendOSCPlayerStateTEST(PlayerStateStructTEST a);
//dllimport final function sendMotionState(string currState, vector loc);
//override to do nothing
//simulated function SetCharacterClassFromInfo(class<UTFamilyInfo> Info)
//{
//}

//var AnimNodeBlend ThrottleBlendNode;
//simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
//{
//    super.PostInitAnimTree(SkelComp);
// 
//    if (SkelComp == Mesh)
//    {
//        ThrottleBlendNode = AnimNodeBlend(Mesh.FindAnimNode('Throttle Blend'));
//    }
//}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
    super.PostInitAnimTree(SkelComp);
    
    gRotatorOffset = 1177;
        
    OSCRightArm_CCD_IK = SkelControl_CCD_IK( mesh.FindSkelControl('OSCRightArm_CCD_IK') );
    RightWing_CCD_IK = SkelControl_CCD_IK( mesh.FindSkelControl('RightWing_CCD_IK') );
	LeftWing_CCD_IK  = SkelControl_CCD_IK( mesh.FindSkelControl('LeftWing_CCD_IK') );
	
    // For Trumbruticus trunk moving demo
    //TrunkMover = SkelControl_CCD_IK(Mesh.FindSkelControl('TrunkMover'));
}

simulated exec function setRotatorOffset(int val)
{
    gRotatorOffset = val;
}

//simulated exec function ChangePlayerMesh(int a)
exec function ChangePlayerMesh(int a)
{
//    selectedPlayerMesh = a;
    SetPawnMesh(a);
}

simulated function setPawnMesh(int a)
//server reliable function setPawnMesh(int a)
{
    //local AnimNode temp;

    selectedPlayerMesh = a;
    
    if(a==1)
    {
        self.Mesh.SetSkeletalMesh(SkeletalMesh'thesis_characters.trumbruticus.CHA_trumbruticus_skel_01');
        self.Mesh.SetPhysicsAsset(PhysicsAsset'thesis_characters.trumbruticus.CHA_trumbruticus_skel_01_Physics');
        self.Mesh.AnimSets[0]=AnimSet'thesis_characters.trumbruticus.CHA_trumbruticus_skel_01_Anims';
        self.Mesh.SetAnimTreeTemplate(AnimTree'thesis_characters.trumbruticus.CHA_trumbruticus_AnimTree_spawntest');

        //self.Mesh.GlobalAnimRateScale=self.GroundSpeed/440.0;
        //`log("Groundspeed = "$self.GroundSpeed);
        
//        Weapon.SetHidden(True);
        
        //Pawn.GroundSpeed
        isValkordia=false;
        isTrumbruticus=true;
        
        } else if(a==2) {
        self.Mesh.SetSkeletalMesh(SkeletalMesh'thesis_characters.valkordia.CHA_valkordia_skel_01');
        self.Mesh.SetPhysicsAsset(PhysicsAsset'thesis_characters.valkordia.CHA_valkordia_skel_01_Physics');
        self.Mesh.AnimSets[0]=AnimSet'thesis_characters.valkordia.CHA_valkordia_skel_01_Anims';
        self.Mesh.SetAnimTreeTemplate(AnimTree'thesis_characters.valkordia.CHA_valkordia_AnimTree_01');    
        //self.Mesh.SetAnimTreeTemplate(AnimTree'OSCthesis_characters.valkordia.CHA_valkordia_AnimTree_01');
        // Add bones to array for tracking /* */
        currentBones.Length = 0;            // Clear the array
        
        currentBones.addItem('valkordia_01Lwing_front_4');
        currentBones.addItem('valkordia_01Rwing_front_4');        
                    
//        Weapon.SetHidden(True);
        
         // Search for the animation node blend list by name.
        //temp = self.Mesh.FindAnimNode('UDKAnimBlendByFlying');
        
        isValkordia=true;
        isTrumbruticus=false;
        
        self.Mesh.ForceSkelUpdate();
        
    } else if(a==3) {    
        self.Mesh.SetSkeletalMesh(SkeletalMesh'CH_LIAM_Cathode.Mesh.SK_CH_LIAM_Cathode');
        self.Mesh.SetPhysicsAsset(PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics');
        self.Mesh.AnimSets[0]=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale';
        // self.Mesh.SetAnimTreeTemplate(AnimTree'CH_AnimHuman_Tree.AT_CH_Human');
        self.Mesh.SetAnimTreeTemplate(AnimTree'OSC_AnimHuman_Tree.AT_CH_Human');
        
        isValkordia=false;
        isTrumbruticus=false;
        
    } else if(a==4) {
        self.Mesh.SetSkeletalMesh(SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA');
        self.Mesh.SetPhysicsAsset(PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics');
        self.Mesh.AnimSets[0]=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale';
        // self.Mesh.SetAnimTreeTemplate(AnimTree'CH_AnimHuman_Tree.AT_CH_Human');
        self.Mesh.SetAnimTreeTemplate(AnimTree'OSC_AnimHuman_Tree.AT_CH_Human');
        
        isValkordia=false;
        isTrumbruticus=false;
        
    } else if(a==5) {
        self.Mesh.SetSkeletalMesh(SkeletalMesh'CH_IronGuard_Male.Mesh.SK_CH_IronGuard_MaleA');
        self.Mesh.SetPhysicsAsset(PhysicsAsset'CH_AnimCorrupt.Mesh.SK_CH_Corrupt_Male_Physics');
        self.Mesh.AnimSets[0]=AnimSet'CH_AnimHuman.Anims.K_AnimHuman_BaseMale';
        // self.Mesh.SetAnimTreeTemplate(AnimTree'CH_AnimHuman_Tree.AT_CH_Human');
        self.Mesh.SetAnimTreeTemplate(AnimTree'OSC_AnimHuman_Tree.AT_CH_Human');

        isValkordia=false;
        isTrumbruticus=false;
        
    }  else if(a==6) {
        self.Mesh.SetSkeletalMesh(SkeletalMesh'thesis_characters.valkordia.CHA_valkordia_skel_01');
        self.Mesh.SetPhysicsAsset(PhysicsAsset'thesis_characters.valkordia.CHA_valkordia_skel_01_Physics');
        self.Mesh.AnimSets[0]=AnimSet'thesis_characters.valkordia.CHA_valkordia_skel_01_Anims';
        //self.Mesh.SetAnimTreeTemplate(AnimTree'thesis_characters.valkordia.CHA_valkordia_AnimTree_01');    
        self.Mesh.SetAnimTreeTemplate(AnimTree'OSCthesis_characters.valkordia.CHA_valkordia_AnimTree_01');
        // Add bones to array for tracking /* */
        currentBones.Length = 0;            // Clear the array
        
        currentBones.addItem('valkordia_01Lwing_front_4');
        currentBones.addItem('valkordia_01Rwing_front_4');        
                    
//        Weapon.SetHidden(True);
        
         // Search for the animation node blend list by name.
        //temp = self.Mesh.FindAnimNode('UDKAnimBlendByFlying');
        
        isValkordia=true;
        isTrumbruticus=false;
        
        //self.Mesh.ForceSkelUpdate();
    }
}

/* " */
// Trigger player Call
exec function Call(bool val) {

    gCall = val;    
    sendCall();
}

function sendCall() {
    
    if(gCall) {
        gSendCall = 1;
        gCall = False;
    } else {
        gSendCall = 0;
    }
        
}

// Disable FeignDeath (from UTPawn)
exec simulated function FeignDeath()
{
//    ServerFeignDeath();
}

simulated exec function setEyeHeight(float X)
{
  BaseEyeheight=X;
}

simulated exec function setOSCFingerOffsets(float X, float Y, float Z)
{
    OSCFingerOffsets.X=X;
    OSCFingerOffsets.Y=Y;
    OSCFingerOffsets.Z=Z;
}

simulated exec function setOSCFingerWorldMin(float X, float Y, float Z)
{
    OSCFingerWorldMin.X = X;
    OSCFingerWorldMin.Y = Y;
    OSCFingerWorldMin.Z = Z;
}

simulated exec function setOSCFingerWorldMax(float X, float Y, float Z)
{
    OSCFingerWorldMax.X = X;
    OSCFingerWorldMax.Y = Y;
    OSCFingerWorldMax.Z = Z;
}

simulated exec function setOSCFingerSourceMax(float X, float Y, float Z)
{
    OSCFingerSourceMax.X = X;
    OSCFingerSourceMax.Y = Y;
    OSCFingerSourceMax.Z = Z;
}

simulated exec function setOSCFingerSourceMin(float X, float Y, float Z)
{
    OSCFingerSourceMin.X = X;
    OSCFingerSourceMin.Y = Y;
    OSCFingerSourceMin.Z = Z;
}

simulated function vector getScaledFingerTouch(int fingerTouch)
{
    local vector scaledFingerTouch;
// for iPad
// x range = 0 to 320
// y range = 0 to 420
// finger touch ~ 7 to 20
//    `log("OSCFingerSourceMin: "$OSCFingerSourceMin);
//    `log("OSCFingerSourceMax: "$OSCFingerSourceMax);
//    `log("OSCFingerWorldMax: "$OSCFingerWorldMax);
//    `log("OSCFingerWorldMin: "$OSCFingerWorldMin);
    
    scaledFingerTouch.X = scaleRange( fingerTouchArray[fingerTouch].X, OSCFingerSourceMin.X, OSCFingerSourceMax.X, OSCFingerWorldMin.X, OSCFingerWorldMax.X);
    scaledFingerTouch.Y = scaleRange( fingerTouchArray[fingerTouch].Y, OSCFingerSourceMin.Y, OSCFingerSourceMax.Y, OSCFingerWorldMin.Y, OSCFingerWorldMax.Y);
    scaledFingerTouch.Z = scaleRange( fingerTouchArray[fingerTouch].Z, OSCFingerSourceMin.Z, OSCFingerSourceMax.Z, OSCFingerWorldMin.Z, OSCFingerWorldMax.Z);
    
    return scaledFingerTouch;
}

simulated function float scaleRange(float in, float oldMin, float oldMax, float newMin, float newMax)
{
    return ( in / ((oldMax - oldMin) / (newMax - newMin))) + newMin;
}

simulated exec function setSeekingTurnRate(float val) {
    seekingTurnRate=val;
}

simulated function float getSeekingTurnRate() {
    return seekingTurnRate;
}

simulated exec function initOSCFingerTouches(bool val) {
    OSCUseFingerTouches=val;
}

simulated exec function getOSCFingerTouches() {
    ClientMessage("Current OSC FingerTouches value: "$OSCUseFingerTouches);
}

simulated exec function getOSCHostname() {
ClientMessage("Current OSC Hostname value: "$OSCParameters.getOSCHostname());
}

simulated exec function getOSCPort() {
ClientMessage("Current OSC Port value: "$OSCParameters.getOSCPort());
}

simulated exec function getOSC() {
ClientMessage("Current OSC Hostname::Port values: "$OSCParameters.getOSCHostname()$"::"$OSCParameters.getOSCPort());
}

simulated exec function setOSCHostname(string hostname) {
OSCParameters.setOSCHostname(hostname);
}

simulated exec function setOSCPort(int port) {
OSCParameters.setOSCPort(port);
}

simulated exec function setOSC(string hostname, int port) {
OSCParameters.setOSCHostname(hostname);
OSCParameters.setOSCPort(port);
}

simulated exec function getAirSpeed() {
    ClientMessage("AirSpeed: "$AirSpeed);
}

simulated exec function setAirSpeed(float as) {
    AirSpeed=as;
    baseAirSpeed = as;    // set for slewed airspeed in OSCPlayerControllerDLL.uc
}

simulated exec function getGroundSpeed() {
    ClientMessage("GroundSpeed: "$groundspeed);
}

simulated exec function setGroundSpeed(float gs) {
    groundspeed=gs;
}

simulated event PostBeginPlay() {

    `log("In PostBeginPlay... OSCPawn");
    
    Super.PostBeginPlay();
    
    self.Mesh.SetPhysicsAsset(PhysicsAsset'thesis_characters.valkordia.CHA_valkordia_skel_01_Physics');
    self.Mesh.SetSkeletalMesh(SkeletalMesh'thesis_characters.valkordia.CHA_valkordia_skel_01');
    self.Mesh.AnimSets[0]=AnimSet'thesis_characters.valkordia.CHA_valkordia_skel_01_Anims';
    
    gCall = FALSE;
    gSendCall = 0.0;
    
}

simulated event PreBeginPlay() {
    Super.PreBeginPlay();

    self.Mesh.SetPhysicsAsset(PhysicsAsset'thesis_characters.valkordia.CHA_valkordia_skel_01_Physics');    
    self.Mesh.SetSkeletalMesh(SkeletalMesh'thesis_characters.valkordia.CHA_valkordia_skel_01');
    self.Mesh.AnimSets[0]=AnimSet'thesis_characters.valkordia.CHA_valkordia_skel_01_Anims';
    
    `log("In PreBeginPlay... OSCPawn");
        
    // ****************************************************************************** //
    // HACK FOR CRASHING WITH LOST OSCPARAMETERS REFERENCE
    // ****************************************************************************** //
OSCParameters = spawn(class'OSCParams');    
OSCHostname = OSCParameters.getOSCHostname();
OSCPort = OSCParameters.getOSCPort();    

    object1.X=0; 
    object1.Y=0;
    object1.Z=0;
    object2.X=0;
    object2.Y=0;
    object2.Z=0;
    object3.X=0;
    object3.Y=0;
    object3.Z=0;
    object4.X=0;
    object4.Y=0;
    object4.Z=0;
    object5.X=0;
    object5.Y=0;
    object5.Z=0;
    
    fingerTouchArray[0]=object1;
    fingerTouchArray[1]=object2;
    fingerTouchArray[2]=object3;
    fingerTouchArray[3]=object4;
    fingerTouchArray[4]=object5;
    
    OSCFingerSourceMax = vect(320.00000, 420.00000, 20.00000);
    OSCFingerSourceMin = vect(0.00001, 0.00001, 7.40000);
    OSCFingerWorldMax = vect(2000.00000, 2000.00000, 2300.00000);
    OSCFingerWorldMin = vect(-2000.00000, -2000.00000, 0.00001);
    OSCFingerOffsets = vect(-160.00000, -210.00000, 0.00001);    
        
}

// Overloading FaceRotation from UTPawn to let pawn pitch follow camera
simulated function FaceRotation(rotator NewRotation, float DeltaTime)
{

    bForceNetUpdate = TRUE; // Force replication
    
    if ( Physics == PHYS_Ladder )
    {
        NewRotation = OnLadder.Walldir;
    }    
    else if ( (Physics == PHYS_Walking) )//|| (Physics == PHYS_Falling) )
    {
        NewRotation.Pitch = 0;
    } 
    
    SetRotation(NewRotation);
    
/*
    if(OSCFreeCamera || OSCAttachedCamera)
    {
            SetRotation(NewRotation);    
    } else 
    {
        //NewRotation.Roll = Rotation.Roll;
        //NewRotation.Pitch = Rotation.Pitch;
        
        SetRotation(NewRotation);    
    }
*/    
}

simulated function sendPlayerState()
{
    
    Local vector loc, norm, end;
    Local TraceHitInfo hitInfo;
    Local Actor traceHit;
    //local MyPlayerStruct tempVals;
    local PlayerStateStruct psStruct;
    local bool sendOSC;
    local Rotator viewrotator;

    end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
    traceHit = trace(loc, norm, end, Location, true,, hitInfo);
    
    // Populate pcStruct with tracehit info using rkh String format hack
    psStruct.PlayerName ="bob";
    psStruct.id = Controller.PlayerReplicationInfo.PlayerID;//uid;  Changed for multiplayer... bots and AI are still on manual iDs (NEED TO CHANGE)
    psStruct.LocX = Location.X;
    psStruct.LocY = Location.Y;
    psStruct.LocZ = Location.Z;
    if(isCrouching) {
        psStruct.Crouch = 1;
    } else {
        psStruct.Crouch = 0;
    }
        
    psStruct.leftTrace = gLeftTrace;
    psStruct.rightTrace = gRightTrace;
    psStruct.downTrace = gDownTrace;
    psStruct.sendCall = gSendCall;
    
    // adding rotation to the player output call
    psStruct.Yaw = Rotation.Yaw%65535;

    // get view rotation for Pitch for osc output
    viewrotator = GetViewRotation();    
    psStruct.Pitch = viewrotator.Pitch%65535;
    psStruct.Roll = Rotation.Roll%65535;
    
    psStruct.bone1X = gBone1.X;
    psStruct.bone1Y = gBone1.Y;
    psStruct.bone1Z = gBone1.Z;
    
    
OSCHostname = OSCParameters.getOSCHostname();
OSCPort = OSCParameters.getOSCPort();
psStruct.Hostname = OSCParameters.getOSCHostname();
psStruct.Port = OSCParameters.getOSCPort();

    // HACK TO QUICK FIX OSCParameters going haywire!!!?!?!??!
//    psStruct.Hostname = "10.0.1.20";
//    psStruct.Port = 57120;
    
    sendOSC=true;

    // only send OSC if nothing has changed (XYZ or crouch)
    if(sendDeltaOSC) {
        if( (Location.X == lastX) && (Location.Y == lastY) && (Location.Z == lastZ) && (isCrouching==lastCrouch))
            sendOSC=false;
    }

    if(sendOSC)
        sendOSCPlayerState(psStruct);

    // update last xyz coordinates
    lastX = Location.X;
    lastY = Location.Y;
    lastZ = Location.Z;
    lastCrouch = isCrouching;
    
}

function showTargetInfo()
{
    
    Local vector loc, norm, end;
    Local TraceHitInfo hitInfo;
    Local Actor traceHit;
    local MyPlayerStruct tempVals;
    local PointClickStruct pcStruct;
    
    end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
    traceHit = trace(loc, norm, end, Location, true,, hitInfo);

    ClientMessage("");
    ClientMessage("In showTargetInfo: oscpawn.");

    if (traceHit == none)
    {
        ClientMessage("Nothing found, try again.");
        return;
    }

    // Play a sound to confirm the information
    //ClientPlaySound(SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock');

    // By default only 4 console messages are shown at the time
     ClientMessage("Hit: "$traceHit$"  class: "$traceHit$"."$traceHit.class);
     ClientMessage("Location: "$loc.X$","$loc.Y$","$loc.Z);
     ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
    ClientMessage("Component: "$hitInfo.HitComponent);
    
    // Populate pcStruct with tracehit info using rkh String format hack
    pcStruct.TraceHit = ""$traceHit$"";
    pcStruct.TraceHit_class = ""$traceHit.class$"";
    pcStruct.TraceHit_class_outerName = ""$traceHit.class.outer.name$"";
    pcStruct.LocX = loc.X;
    pcStruct.LocY = loc.Y;
    pcStruct.LocZ = loc.Z;
    pcStruct.HitInfo_material = ""$hitInfo.Material$"";
    pcStruct.HitInfo_physmaterial = ""$hitInfo.PhysMaterial$"";
    pcStruct.HitInfo_hitcomponent = ""$hitInfo.HitComponent$"";

    
    
    sendOSCPointClick(pcStruct);
}

//function showHitLocation(vector HitLocation)
simulated function showHitLocation()
{

    Local vector loc, norm, end;
    Local TraceHitInfo hitInfo;
    Local Actor traceHit;
    local MyPlayerStruct tempVals;
    local PointClickStruct pcStruct;
    
    end = Location + normal(vector(Rotation))*32768; // trace to "infinity"
    traceHit = trace(loc, norm, end, Location, true,, hitInfo);

    ClientMessage("");

    ClientMessage("In showhitlocation: oscpawn.");

    if (traceHit == none)
    {
        ClientMessage("Nothing found, try again.");
        return;
    }

    // Play a sound to confirm the information
    //ClientPlaySound(SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock');

    // By default only 4 console messages are shown at the time
     ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
     //ClientMessage("HitLocation: "$tracehit.Location.X$", "$tracehit.Location.Y$", "$tracehit.Location.Z$"");//$HitLocation.X$","$HitLocation.Y$","$HitLocation.Z);
     ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
    ClientMessage("Component: "$hitInfo.HitComponent);
    /*
    // Populate pcStruct with tracehit info using rkh String format hack
    pcStruct.TraceHit = ""$traceHit$"";
    pcStruct.TraceHit_class = ""$traceHit.class$"";
    pcStruct.TraceHit_class_outerName = ""$traceHit.class.outer.name$"";
    pcStruct.LocX = HitLocation.X;
    pcStruct.LocY = HitLocation.Y;
    pcStruct.LocZ = HitLocation.Z;
    pcStruct.HitInfo_material = ""$hitInfo.Material$"";
    pcStruct.HitInfo_physmaterial = ""$hitInfo.PhysMaterial$"";
    pcStruct.HitInfo_hitcomponent = ""$hitInfo.HitComponent$"";
*/
    setProjectileTargets(Loc.X, Loc.Y, Loc.Z);
    //setProjectileTargets(tracehit.Location.X, tracehit.Location.Y, tracehit.Location.Z);
    `log("SEnding target location:"$loc.X$","$loc.Y$","$loc.Z);
//    sendOSCPointClick(pcStruct);
}

exec function activateCallEmitter()
{
    PSC_CallEmitter.ActivateSystem();
    
//    PSC_CallEmitter.SetActive(bNowActive);

}

exec function deactivateCallEmitter()
{
    PSC_CallEmitter.DeactivateSystem();
}

exec function attachEmitter()
{

    // on bone: 'valkordia_01Tail2'
    ValkordiaTailSocket = 'trail_socket_01';
    
    // Attach Component...    ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'
    if (ValkordiaTailSocket != '') {
        if (Mesh != none && PSC_CallEmitter != none) {
            Mesh.AttachComponentToSocket(PSC_CallEmitter, ValkordiaTailSocket);
            PSC_CallEmitter.ActivateSystem();
        }
    }

/*    
    if (Mesh.GetSocketByName(ValkordiaTailSocket) != None)
{
  // Socket exists
  `log("SOCKET EXISTS");
}
else
{
  // Socket doesn't exist
    `log("SOCKET DOESN'T EXIST");
}
*/
}

simulated function StartFire(byte FireModeNum)
{

    Super.StartFire(FireModeNum);
    if(FireModeNum==0)
    {
        showHitLocation();
    }

}

simulated exec function OSCStartInput() {

    `log("Initializing OSC Input...");
    if(!receivingOSC) 
    {
        initOSCReceiver();
        receivingOSC=True;
    }
}

simulated exec function OSCStartOutput() {
    `log("Initializing OSC Output...");
    sendingOSC = true;
}

simulated exec function OSCStopOutput() {
    `log("stopping OSC Output...");
    sendingOSC = false;
}

// Toggle whether OSC sends in continuous mode or only on Deltas
simulated exec function OSCSendDeltas() {
    if(sendDeltaOSC) {
       sendDeltaOSC=false;
    } else {
        sendDeltaOSC=true;
    }
}

simulated event StartCrouch(float HeightAdjust)
{
    Super.StartCrouch(HeightAdjust);
    
    //if(sendingOSC)
        //showTargetInfo();
    
    isCrouching=true;
    
}

simulated event EndCrouch(float HeightAdjust)
{
    Super.EndCrouch(HeightAdjust);
    isCrouching=false;
}


simulated exec function setGrav(float val)
{
//    `log("setting WorldGravitzZ from: "$WorldInfo.WorldGravityZ);
`log("Setting Grav: "$val);
    WorldInfo.WorldGravityZ=val-500.0;
}

simulated function TakeFallingDamage() {

}


simulated exec function setGameSpeed(float val)
{
`log("Setting Game Speed: "$val);
    WorldInfo.Game.SetGameSpeed(val);
}

simulated function getOSCFingerData()
{
    local vector vals;
    vals = getOSCFinger1();
    `log("vals: "$vals);
    
}


simulated function setOSCFingerTouches(OSCFingerController fstruct)
{

    //`log("in setOSCFingerTouches");
    //`log("fstruct = "$fstruct.f1X);

    currentFingerTouches[0]=fstruct.f1on;
    currentFingerTouches[1]=fstruct.f2on;
    currentFingerTouches[2]=fstruct.f3on;
    currentFingerTouches[3]=fstruct.f4on;
    currentFingerTouches[4]=fstruct.f5on;
    
    if(fstruct.f1on>0.0)
    {
/*    
    `log("in setOSCFingerTouches");
    `log("fstruct.f1X = "$fstruct.f1X);
    `log("fstruct.1fon: "$fstruct.f1on);
*/    
    
        fingerTouchArray[0].X=fstruct.f1X;    
        fingerTouchArray[0].Y=fstruct.f1Y;
        fingerTouchArray[0].Z=fstruct.f1Z;
    }

    if(fstruct.f2on>0.0)
    {
/*
    `log("fstruct.f2X = "$fstruct.f2X);
    `log("fstruct.2fon: "$fstruct.f2on);
*/
        fingerTouchArray[1].X=fstruct.f2X;    
        fingerTouchArray[1].Y=fstruct.f2Y;
        fingerTouchArray[1].Z=fstruct.f2Z;
    }
    
    if(fstruct.f3on>0.0)
    {
        fingerTouchArray[2].X=fstruct.f3X;    
        fingerTouchArray[2].Y=fstruct.f3Y;
        fingerTouchArray[2].Z=fstruct.f3Z;
    }
    
    if(fstruct.f4on>0.0)
    {
        fingerTouchArray[3].X=fstruct.f4X;    
        fingerTouchArray[3].Y=fstruct.f4Y;
        fingerTouchArray[3].Z=fstruct.f4Z;
    }
    
    if(fstruct.f5on>0.0)
    {
        fingerTouchArray[4].X=fstruct.f5X;    
        fingerTouchArray[4].Y=fstruct.f5Y;
        fingerTouchArray[4].Z=fstruct.f5Z;
    }
    
/*    
    if(fstruct.f1on>0)
    {
    `log("in setOSCFingerTouches");
    `log("fstruct = "$fstruct.f1X);
    
        ut3osc(WorldInfo.Game).fingerTouchArray[0].X=fstruct.f1X;    
        ut3osc(WorldInfo.Game).fingerTouchArray[0].Y=fstruct.f1Y;
        ut3osc(WorldInfo.Game).fingerTouchArray[0].Z=fstruct.f1Z;
    }

    if(fstruct.f2on>0)
    {
        ut3osc(WorldInfo.Game).fingerTouchArray[1].X=fstruct.f2X;    
        ut3osc(WorldInfo.Game).fingerTouchArray[1].Y=fstruct.f2Y;
        ut3osc(WorldInfo.Game).fingerTouchArray[1].Z=fstruct.f2Z;
    }
    
    if(fstruct.f3on>0)
    {
        ut3osc(WorldInfo.Game).fingerTouchArray[2].X=fstruct.f3X;    
        ut3osc(WorldInfo.Game).fingerTouchArray[2].Y=fstruct.f3Y;
        ut3osc(WorldInfo.Game).fingerTouchArray[2].Z=fstruct.f3Z;
    }
    
    if(fstruct.f4on>0)
    {
        ut3osc(WorldInfo.Game).fingerTouchArray[3].X=fstruct.f4X;    
        ut3osc(WorldInfo.Game).fingerTouchArray[3].Y=fstruct.f4Y;
        ut3osc(WorldInfo.Game).fingerTouchArray[3].Z=fstruct.f4Z;
    }
    
    if(fstruct.f5on>0)
    {
        ut3osc(WorldInfo.Game).fingerTouchArray[4].X=fstruct.f5X;    
        ut3osc(WorldInfo.Game).fingerTouchArray[4].Y=fstruct.f5Y;
        ut3osc(WorldInfo.Game).fingerTouchArray[4].Z=fstruct.f5Z;
    }
*/    
}


function setFingerTouchesTest(float val)
{
    //ut3osc(WorldInfo.Game).fingerTouchArray[0].X = val;
    //`log("TESTING"$ut3osc(WorldInfo.Game).fingerTouchArray[0].X);
}

/*
// Try to grab the WorldInfo and use that to write the message to the screen.
public static function WorldInfoClientMessage(string message)
{
    local WorldInfo wi;
 
    wi = GetWorldInfo();
 
    if(wi != none)
        ClientMessage(wi, message);
    else
    {
        LogMessage(message);
        LogMessage("Could not send the previous message to clients because WorldInfo0 was not found.");
    }
}
 */
// Try to grab the WorldInfo.

private static function WorldInfo GetWorldInfo()
{
    return WorldInfo(FindObject("WorldInfo_0", class'WorldInfo'));
    
}


simulated event Landed(vector HitNormal, Actor FloorActor)
{
    Super.Landed(HitNormal, FloorActor);
    //showTargetInfo();
}

function testInputData()
{
    //`log("AAAAAAAAAAAAAAAAAA");
    if(localOSCMessageStruct.test > 0.000)
    {
    `log("..."$localOSCMessageStruct.test$"...");
    }
    
    
}

function setOSCCamera(vector val) {
    OSCCamera = val;
    
}

simulated exec function OSCSetFollowLockCamera(bool val) {
    OSCFollowLockCamera = val;

    if(val) {
        OSCBehindCamera=false;
        OSCAttachedCamera=false;
        OSCFreeCamera=false;
        OSCBehindCamera=false;
        OSCFollowCamera = false;
    }
    
}

simulated exec function OSCSetFollowCamera(bool val) {
    OSCFollowCamera = val;
    if(val) {
        OSCBehindCamera=false;
        OSCAttachedCamera=false;
        OSCFreeCamera=false;
        OSCBehindCamera=false;
        OSCFollowLockCamera=false;
    }
    
}

simulated exec function OSCSetBehindCamera(int val) {

    if(val == 0) {
        OSCBehindCamera=false;
    } else {
        OSCAttachedCamera=false;
        OSCFreeCamera=false;
        OSCFollowCamera=false;
        OSCFollowLockCamera=false;        
        OSCBehindCamera = true;
    }
}
simulated exec function OSCSetAttachedCamera() {
    if(OSCAttachedCamera) {
        setOSCAttachedCamera(0);
    } else {
        setOSCAttachedCamera(1);
    }
}


simulated exec function setOSCAttachedCamera(int val) {
    if(val == 0) {
        OSCAttachedCamera=false;
    } else {
        OSCAttachedCamera=true;
        OSCFollowCamera=false;        
        OSCFollowLockCamera=false;        
        OSCFreeCamera=false;
    }
}

simulated exec function OSCSetFreeCamera() {
    if(OSCFreeCamera) {
        setOSCFreeCamera(0);
    } else {
        setOSCFreeCamera(1);
    }
}


simulated exec function setOSCFreeCamera(int val) {
    if(val == 0) {
        OSCFreeCamera=false;
    } else {
        OSCFreeCamera=true;
        OSCFollowCamera=false;        
        OSCFollowLockCamera=false;        
    }
}

/*
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{

    local vector start, end, hl, hn, hl2;
    local actor a;
    local Rotator rot2, SavedRot;

    if(OSCPlayerControllerDLL(Controller).bUseMouseFreeLook)
    {
        start = Location;
    
        if (Controller != none)
        {
            end = Location - (Vector(Controller.Rotation) * 100.f);
        }
        else
        {
            end = Location - (Vector(Rotation) * 100.f);
        }
    
        a = Trace(hl, hn, end, start, false);
    
        if (a != none)
        {
            out_CamLoc = hl + vect(0,0,50);
        }
        else
        {
        //    if (bUsingFreeCam)
//            {
                out_CamLoc.X = Location.X + Sin(Controller.Rotation.Yaw*0.0001) * 100.f;
                out_CamLoc.Y = Location.Y + Cos(Controller.Rotation.Yaw*0.0001) * 100.f;
                out_CamLoc.Z = Location.Z + CamOffset.Z;
//            }
//            else
//            {
//                out_CamLoc = end + vect(0,0,50);
//            }
        }
    
        GetActorEyesViewPoint(hl2, rot2);

//        if (bUsingFreeCam)
//        {
            out_CamRot = Rotator(Location - out_CamLoc);
//        }
//        else
//        {
//            out_CamRot = rot2;
//        }

        return true;

    }
}
*/



    /*
    
    function RotationUpdate(TViewTarget OutVT, float dt)
{

  local Vector fromTarget;
  local Vector desiredDir;
  local float  currAngle;
  local float  desiredAngle;
  local Vector CamNoZ;
  local Vector TargetNoZ;
 
  CamNoZ      = CurrentCamLocation;
  CamNoZ.Z    = 0.f;
  TargetNoZ   = OutVT.Target.Location;
  TargetNoZ.Z = 0.f;
 
  fromTarget = CamNoZ - TargetNoZ;
 
  if(fromTarget.X != 0) currAngle = Atan( fromTarget.Y / fromTarget.X );
  else                  currAngle = Pi/2;
  if(fromTarget.X < 0 ) currAngle -= Pi;
 
  desiredAngle = currAngle + DesiredTurn / TurnRateRatio;
 
  desiredDir.Y = Sin(desiredAngle);
  desiredDir.X = Cos(desiredAngle);
 
  CurrentCamLocation = OutVT.Target.Location + (desiredDir*VSize(fromTarget));
 
  fromTarget = OutVT.Target.Location - CurrentCamLocation;
  CurrentCamRotation = rotator(fromTarget + FreeCamOffset);
}
    
    */
    
simulated function bool __CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{

}
    
simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
{
    local float CamDistance;
    local float CamDistanceX;
    local float zValue;
    
    CamDistance = OSCPlayerControllerDLL(Controller).gCameraDistance;
    //CamDistance = 0;
    
//    if(OSCPlayerControllerDLL(Controller).PlayerInput.aMouseX > 0)
//    {
//        
//    }
    
    if(OSCPlayerControllerDLL(Controller).bUseMouseFreeLook)
    {

        if(    OSCPlayerControllerDLL(Controller).bUseMouseDive) {
            out_CamLoc.X = Location.X + Sin(Controller.Rotation.Yaw * -0.0001) * 100.f;
            out_CamLoc.Y = Location.Y + Cos(Controller.Rotation.Yaw * -0.0001) * 100.f;        
            out_CamLoc.Z = (Location.Z ) + ATan(OSCPlayerControllerDLL(Controller).gTotalMousePitch * -0.0001) * (1000.0 + CamDistance); 
        } else if ( OSCPlayerControllerDLL(Controller).gCameraMode == 1 ) {  
            // static camera, no motion    
            out_CamLoc = gCamLoc;            
            out_CamRot = gCamRot;
        } else if ( OSCPlayerControllerDLL(Controller).gCameraMode == 2 ) {  
            // disable x and y mouse motion, leave Z/up attached 
            out_CamLoc = gCamLoc;
            out_CamLoc.X += CamDistanceX;
            out_CamLoc.Z = (Location.Z ) + ATan(OSCPlayerControllerDLL(Controller).gTotalMousePitch * -0.0001) * (1000.0 + CamDistance); 
        } else if ( OSCPlayerControllerDLL(Controller).gCameraMode == 3) {
            // don't change camera location/leave it where it is        
            out_CamLoc = gCamLoc;
            out_CamLoc.X += CamDistanceX;
        } else {
            out_CamLoc.X = (Location.X  ) - Sin(OSCPlayerControllerDLL(Controller).gMouseRotation.Yaw * 0.0001) * (1000.0 + CamDistance);
            out_CamLoc.Y = (Location.Y  )  - Cos(OSCPlayerControllerDLL(Controller).gMouseRotation.Yaw * 0.0001) * (1000.0 + CamDistance);
            out_CamLoc.Z = (Location.Z ) + ATan(OSCPlayerControllerDLL(Controller).gTotalMousePitch * -0.0001) * (1000.0 + CamDistance);     
        }
        
        if ( OSCPlayerControllerDLL(Controller).gCameraMode != 1 ) {  
            out_CamRot = rotator(Location - out_CamLoc);
            // 1177 ???
            out_CamRot.Pitch += gRotatorOffset;
        }

        
        //`log("mouseFreeLook CameraLocation: "$out_CamLoc.X$", "$out_CamLoc.Y$", "$out_CamLoc.Z);
        //`log("mouseFreeLook CameraRotation: "$out_CamRot.Pitch$", "$out_CamRot.Yaw$", "$out_CamRot.Roll);                
    } else {        

        CamDistanceX = 0;
        if( OSCPlayerControllerDLL(Controller).gCameraMode == 0)
            CamDistanceX = OSCPlayerControllerDLL(Controller).gCameraOffsetX;
        
        out_CamLoc.X = out_CamLoc.X + CamDistanceX + CamOffset.X;
        Super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);

        if( OSCPlayerControllerDLL(Controller).gCameraMode == 0)
            CamDistanceX = OSCPlayerControllerDLL(Controller).gCameraOffsetX;
        
        //`log("______________CameraLocation: "$out_CamLoc.X$", "$out_CamLoc.Y$", "$out_CamLoc.Z);
        //`log("______________CameraRotation: "$out_CamRot.Pitch$", "$out_CamRot.Yaw$", "$out_CamRot.Roll);        
    }
    // 251
    // 915 = 736
    
    // keep memory of last set camera location for freeze-camera routines
    gCamLoc = out_CamLoc;
    gCamLoc.X = out_CamLoc.X + CamDistanceX;
    gCamRot = out_CamRot;
    
    return true;
}


state OSCPlayerMoving {

    exec function oscplayermoveTEST2()
    {
    
        `log("PAWN: IN OSCPLAYERMOVING");
    
    }

    exec function oscRotate(float xval, float yval, float zval)
    {
        local vector locVect;
        locVect.X = xval;
        locVect.Y = yval;
        locVect.Z = zval;
    
        OSCRotation.Pitch=xval;
        OSCRotation.Roll=yval;
        OSCRotation.Yaw=zval;
    
    
        UpdatePawnRotation(Rotator(locVect));
        `log("OSCROTATETEST *******************: "$xval);
    
    }
    
    simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
    {
        local string command;
    /**/
//        `log("IN OSCPAWN::CalcCamera");
    
        if(OSCFreeCamera) 
        {
        
        out_CamLoc.X = localOSCScriptCameramoveStruct.x;
        out_CamLoc.Y = localOSCScriptCameramoveStruct.y;
        out_CamLoc.Z = localOSCScriptCameramoveStruct.z;

        out_CamRot.Pitch = localOSCScriptCameramoveStruct.pitch;
        out_CamRot.Yaw = localOSCScriptCameramoveStruct.yaw;
        out_CamRot.Roll = localOSCScriptCameramoveStruct.roll;        
        
        //out_CamLoc = Location;
//            out_CamLoc.X = OSCCamera.X;
//            out_CamLoc.Y = OSCCamera.Y;  //1800;
//            out_CamLoc.Z = OSCCamera.Z;  //128;
        } else {
    
            if(OSCAttachedCamera)
            {
//            `log("IN HERE");
            
            out_CamLoc = Location;                        
            out_CamLoc.X += localOSCScriptCameramoveStruct.x;
            out_CamLoc.Y += localOSCScriptCameramoveStruct.y;
            out_CamLoc.Z += localOSCScriptCameramoveStruct.z;    
                
            out_CamRot = Rotation;
//            out_CamRot = rotator(Location - out_CamLoc);
            out_CamRot.Pitch += localOSCScriptCameramoveStruct.pitch;
            out_CamRot.Yaw += localOSCScriptCameramoveStruct.yaw;
            out_CamRot.Roll += localOSCScriptCameramoveStruct.roll;
            
            } else if (OSCFollowCamera) {

                out_CamLoc = Location;                        
                out_CamLoc.X += localOSCScriptCameramoveStruct.x;
                out_CamLoc.Y += localOSCScriptCameramoveStruct.y;
                out_CamLoc.Z += localOSCScriptCameramoveStruct.z;    

                out_CamRot = rotator(Location - out_CamLoc);

            } else if(OSCFollowLockCamera) {
            
                out_CamLoc.X = localOSCScriptCameramoveStruct.x;
                out_CamLoc.Y = localOSCScriptCameramoveStruct.y;
                out_CamLoc.Z = localOSCScriptCameramoveStruct.z;        

                out_CamRot = rotator(Location - out_CamLoc);
                
            } else {
/*                if(OSCBehindCamera )
                {
                            camoffsetx = localOSCScriptCameramoveStruct.x;
    camoffsety = localOSCScriptCameramoveStruct.y;
    camoffsetz = localOSCScriptCameramoveStruct.z;
    CamOffset.X = localOSCScriptCameramoveStruct.x;
    CamOffset.Y = localOSCScriptCameramoveStruct.y;
    CamOffset.Z = localOSCScriptCameramoveStruct.z;
                }
*/                
                Super.CalcCamera(fDeltaTime, out_CamLoc, out_CamRot, out_FOV);
                
            }
//            out_CamLoc = Location;
//            out_CamLoc.X += OSCCamera.X;
//            out_CamLoc.Y += OSCCamera.Y;  //1800;        
//            out_CamLoc.Z += OSCCamera.Z;  //128;
        }
/*
        `log("IN OSCPAWN::CalcCamera::OSCFreeCamera = "$OSCFreeCamera);
        
        `log("CalcCamera::out_CamLoc.X = "$out_CamLoc.X);
        `log("CalcCamera::localOSCScriptCameramoveStruct.x = "$localOSCScriptCameramoveStruct.x);
        `log("CalcCamera::out_CamLoc.Y = "$out_CamLoc.Y);
        `log("CalcCamera::localOSCScriptCameramoveStruct.y = "$localOSCScriptCameramoveStruct.y);
        `log("CalcCamera::out_CamLoc.Z = "$out_CamLoc.Z);        
        `log("CalcCamera::localOSCScriptCameramoveStruct.z = "$localOSCScriptCameramoveStruct.z);
        
        `log("CalcCamera::out_CamRot.Pitch = "$out_CamRot.Pitch);
        `log("CalcCamera::out_CamRot.Yaw = "$out_CamRot.Yaw);
        `log("CalcCamera::out_CamRot.Roll = "$out_CamRot.Roll);
*/        
        // Testing camera rotation fixes
//        out_CamRot = Rot(0,0,0);
        
//        out_CamRot.Pitch = 0;
//        out_CamRot.Yaw = -16384;
//        out_CamRot.Roll = 0;

        return true;

    }    

/*    
    simulated function setOSCScriptPlayerRotationData(OSCScriptPlayerRotationStruct fstruct)
    {
        localOSCScriptPlayerRotationStruct = fstruct;
    }

    simulated function setOSCRotation()
    {
        local vector localPawnRotation;
        
                
    //    localPawnRotation.X = localOSCScriptPlayerRotationStruct.Pitch;
    //    localPawnRotation.Y = localOSCScriptPlayerRotationStruct.Yaw;
    //    localPawnRotation.Z = localOSCScriptPlayerRotationStruct.Roll;
        
        // Causes problems with PawnBots using OSCPawn
        localPawnRotation.X = OSCPlayerControllerDLL(Controller).localOSCPlayerStateValuesStruct.Pitch;
        localPawnRotation.Y = OSCPlayerControllerDLL(Controller).localOSCPlayerStateValuesStruct.Yaw;
        localPawnRotation.Z = OSCPlayerControllerDLL(Controller).localOSCPlayerStateValuesStruct.Roll;

        `log("localPawnRotation.X: "$localPawnRotation.X );
        `log("localPawnRotation.Y: "$localPawnRotation.Y );
        `log("localPawnRotation.Z: "$localPawnRotation.Z );
        
        UpdatePawnRotation(Rotator(localPawnRotation));
        
    }
    */
    simulated function Tick(float DeltaTime)
    {
        local string command;

    //`log("**************************** OSCPAWN::OSCPlayerMoving:Tick::SENDING OSC: "$sendingOSC);

    if(sendingOSC)
        sendPlayerState();
    


    
/*    
 if(OSCBehindCamera) {
            camoffsetx = localOSCScriptCameramoveStruct.x;
    camoffsety = localOSCScriptCameramoveStruct.y;
    camoffsetz = localOSCScriptCameramoveStruct.z;
    CamOffset.X = localOSCScriptCameramoveStruct.x;
    CamOffset.Y = localOSCScriptCameramoveStruct.y;
    CamOffset.Z = localOSCScriptCameramoveStruct.z;
*/    
//                command = "BehindViewSet "$localOSCScriptCameramoveStruct.x$" "$localOSCScriptCameramoveStruct.y$" "$localOSCScriptCameramoveStruct.z;
                // relative camera motion (relative to pawn)
//                OSCPlayerControllerDLL(Controller).ConsoleCommand(command); //$localOSCScriptCameramoveStruct.x" "$localOSCScriptCameramoveStruct.y" "$localOSCScriptCameramoveStruct.z);
//                `log("Calling Command: "$command);
//    }
    // DO I NEED TO SEND THESE HERE TOO???
/*
    if(pawnDowntrace) {
        downTrace();
    }
    
    if(pawnSidetrace) {
        psideTrace();    
    }
*/    
//        THESE AREN'T VALID ANYMORE: don't do anything right now

        //setOSCScriptPlayerRotationData(getOSCScriptPlayerRotation());
        
        //setOSCRotation();
    }
    
}

exec function setAnimScale(int val, float speed)
{
    if(val==2)
    {
        valkordiaAnimSpeed = speed;
    }
}

simulated function setPawnAnimSpeed()
{
    local float currentRate;
    
    if(OSCPlayerControllerDLL(Controller)!=None) {
    
      if(isTrumbruticus) {
        self.Mesh.GlobalAnimRateScale=self.GroundSpeed / 440.0;
      } else if(isValkordia) {
        if(OSCPlayerControllerDLL(Controller).flying)
        {
//        if(self.AirSpeed < 440.0) {
//            self.Mesh.GlobalAnimRateScale=OSCPlayerControllerDLL(Controller).currentSpeed / 7.0;
//        } else {
            //self.Mesh.GlobalAnimRateScale=self.AirSpeed / valkordiaAnimSpeed;// 440.0;
            currentRate = loge(OSCPlayerControllerDLL(Controller).currentSpeed) -1.0;
            if(currentRate > 1.8) {
                currentRate = 1.8;
            } else if(currentRate < 0.70) {
                currentRate = 0.70;
            }
            
            self.Mesh.GlobalAnimRateScale= currentRate;
//            `log("GlobalAnimRateScale = "$self.Mesh.GlobalAnimRateScale);
            //        }
        }
      }
    
    }
//    `log("Groundspeed = "$self.GroundSpeed);
}

simulated event BecomeViewTarget( PlayerController PC )
{
    Super.BecomeViewTarget(PC);
    
//    if (Weapon.Mesh != None )
//    {
//        Weapon.Mesh.SetOwnerNoSee(True);
//    }
}

function drawWaveTraces()
{
    local int i;
    local vector origLocation;
    local LinearColor col;

    col.A = 255;
    col.R = 255;

    for(i=0; i<waveTraceCount; i++)
    {
        
        origLocation = waveTraces[i];
        origLocation.Z = waveTraceStartLocation.Z;
        
        //waveTraces[i].Z = waveTraces[i].Z + 500;
    
        if(bWaveTracePoints)
            DrawDebugPoint(waveTraces[i], 1, col, false);
        
        if(bWaveTraceLines)
            DrawDebugLine(origLocation, waveTraces[i], 255,0,0,false);
        
        if(bWaveTraceSpheres)
            DrawDebugSphere(waveTraces[i], 10, 10, 0, 255, 0, false);
//        native static final function DrawDebugPoint (Object.Vector Position, float Size, Object.LinearColor PointColor, optional bool bPersistentLines) const
//native static final function DrawDebugSphere (Object.Vector Center, float Radius, int Segments, byte R, byte G, byte B, optional bool bPersistentLines) const
    }
}

simulated function Tick(float DeltaTime)
{
    //SetMeshVisibility(true);
    //local OSCMessageStruct localOSCMessageStruct;
    
    localOSCMessageStruct.test = getOSCTestfloat();
    testInputData(); // rkh testing input data
    
    localOSCGameParamsStruct.gameGravity = getOSCGameGravity();
    localOSCGameParamsStruct.gameSpeed = getOSCGameSpeed();
    
    // Control ShockBall movements via OSC Finger touch data 
    if(OSCUseFingerTouches)
        setOSCFingerTouches(getOSCFingerController());
    
    //getOSCFingerData();
    
    if( localOSCGameParamsStruct.gameGravity != lastGameGravity ) 
    {
        setGrav(localOSCGameParamsStruct.gameGravity);
//        `log("set Gravity to "$localOSCGameParamsStruct.gameGravity$"");
    }

    if( localOSCGameParamsStruct.gameSpeed != lastGameSpeed ) 
    {
        setGameSpeed(localOSCGameParamsStruct.gameSpeed);
    }
    
    lastGameGravity = localOSCGameParamsStruct.gameGravity;
    lastGameSpeed = localOSCGameParamsStruct.gameSpeed;

    if(bWaveTraceDebug) {
        
        drawWaveTraces();
    }
    
    Super.Tick(DeltaTIme);

    //`log("**************************** OSCPAWN::SENDING OSC: "$sendingOSC);

    if(sendingOSC)
        sendPlayerState();

    // Scale player animation speed by pawn sspeed
    setPawnAnimSpeed();
    
    if(pawnDowntrace) {
//            `log("********************************************: IN TICK *************** PAWNTRACE ");

        downTrace();
    }
    
    if(pawnSidetrace) {
        psideTrace();    
    }

    // set playermesh by default to Valkordia    
    if(selectedPlayerMesh==0) {
        `log("OSCPawn::Tick::selectedPlayerMesh: "$selectedPlayerMesh);
        selectedPlayerMesh = 5;
        SetPawnMesh(selectedPlayerMesh);
    } else if(selectedPlayerMesh == 5){ 
        `log("OSCPawn::Tick::selectedPlayerMesh: "$selectedPlayerMesh);
        selectedPlayerMesh = 2;
        SetPawnMesh(selectedPlayerMesh);            
    }

    
    // Testing bone location
    if(currentBones.Length > 0)
        GetBoneLocations();
    
}

exec function sidetrace(int val)
{
    gtracelength = val;
    
    if(pawnSidetrace)
    {
        pawnSidetrace = true;
    } else {
        pawnSidetrace = true;
    }
}


exec function pawntrace(int val)
{
    gdowntracelength = val;
    
//    `log("********************************************: PAWNTRACE "$val);
    
    if(pawnDowntrace)
    {
        pawnDowntrace = true;
    } else {
        pawnDowntrace = true;
    }
}

exec function testtrace(int val)
{
    gtesttrace = val;
}

simulated function psideTrace()
{
    // Left and Right traces
//    sideTracer(16384);
//    sideTracer(-16384);

    sideTracer(1);
    sideTracer(-1);
    
}

simulated function sideTracer(int rval)
{

    local vector loc, norm, end;
    local TraceHitInfo hitInfo;
    local Actor traceHit;
    local vector tempRotation;
    
    local vector out_Location;
    local rotator out_Rotation;
    local vector startTrace;
    local vector viewVector;
    
    local Rotator currRot;
    local bool left;
    local string msg;
    
    local vector lVector, localLeft;
    local float trace_distance;
    
    startTrace = Location;
    startTrace.Z +=BaseEyeHeight;
    
//    viewVector .X+= 90*DegToUnrRot;
    //"
/*
    if(gtesttrace==0)
    {
        currRot = Rotation;
        currRot.Yaw += rval;    //+=16384 for L or R, or +-90*DegToUnrRot;
        end = startTrace + normal(vector(currRot))*gtracelength;
        traceHit = trace(loc, norm, end, startTrace, true,, hitInfo);
        DrawDebugLine(startTrace, end, 255,0,0,false);
        
    } else if (gtesttrace==1) { */
        localLeft.X = 0;
        localLeft.Y = rval;
        localLeft.Z = 0;
//        localLeft = vect(0, rval, 0);
        end = Location + (localLeft*gtracelength >> Rotation);        
        traceHit = trace(loc, norm, end, startTrace, true,, hitInfo);
        //DrawDebugLine(startTrace, end, 255, 0, 0, false);
//    }
    
    /*
    if (traceHit == none)
    {
        gRightTrace = 0;
        gLeftTrace = 0;
        return;
    }
    else
    {
*/    
        trace_distance = VSize(Location - loc);
        
        if(trace_distance > gtracelength)
        {
            trace_distance = 0;
        }
        
//        if(rval==16384)    // Right
        if(rval==1)    
        {
            left=false;
            msg = "Right";
            gRightTrace = trace_distance;
//        } else if(rval==-16384)  // Left 
        } else if(rval==-1)  // Left 
        {
            left=true;
            msg="Left";
            gLeftTrace = trace_distance;
        }
        
        // float distance between Pawn (Location) and object (loc)
        //ClientMessage(msg$": "$trace_distance);//VSize(Location - loc));
        
//         ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
//         ClientMessage("Location: "$loc.X$","$loc.Y$","$loc.Z);
//         ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
//        ClientMessage("Component: "$hitInfo.HitComponent);
//    }
    
}




simulated function downTrace()
{

    local vector loc, norm, end;
    local TraceHitInfo hitInfo;
    local Actor traceHit;
    local vector tempRotation;
    local float trace_distance;
    
    //end = Location + normal(vector(Rotation))*gtracelength; // trace to "infinity"
    end = Location + vect(0, 0, -1)*gdowntracelength;
    traceHit = trace(loc, norm, end, Location, true,, hitInfo);
    trace_distance = VSize(Location - loc);
    
//    `log("********************************************:  IN PAWNTRACE *************** trace_distance "$trace_distance);

    if(trace_distance > gdowntracelength)
    {
        trace_distance = 0;
    }

//    `log("********************************************:  IN PAWNTRACE *************** AFTER CHECK: trace_distance "$trace_distance);
//    `log("********************************************:  IN PAWNTRACE *************** AFTER CHECK: gdowntracelength "$gdowntracelength);
    
    //sDrawDebugLine(Location, end, 255,0,0,false);
    
    /*
    if (traceHit == none)
    {
        ClientMessage("Trace failed.");
        gDownTrace = 0;
        return;        
    }
    else
    {
*/    
        gDownTrace = trace_distance;

        //ClientMessage("Down: "$trace_distance);

        // Play a sound to confirm the information
//        ClientPlaySound(SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock');

        // By default only 4 console messages are shown at the time
 //        ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
 //        ClientMessage("Location: "$loc.X$","$loc.Y$","$loc.Z);
 //        ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
//        ClientMessage("Component: "$hitInfo.HitComponent);
}

exec function setWaveTraceDebug(bool val)
{
    bWaveTraceDebug = val;
}

exec function setWaveTraceLog(bool val)
{
    bWaveTraceLog = val;
}

exec function setWaveTraceSpheres(bool val)
{
    bWaveTraceSpheres = val;
}

exec function setWaveTracePoints(bool val)
{
    bWaveTracePoints = val;
}

exec function setWaveTraceLines(bool val)
{
    bWaveTraceLines = val;
}

exec function setWaveTraceCount(int val)
{
    waveTraceCount = val;
    waveTrace();
}

exec function setWaveTraceRadius(int val)
{
    waveTraceRadius = val;
}

exec function setWaveTraceSetSize(int val)
{
    waveTraceSetSize = val;
    waveTrace();
}

function spawnOSCTraceLight(float Xpos, float Ypos, float Zpos)
{
    local OSCTraceLight p;
    local OSCProj_ShockBall sb;
    local float xval, yval, zval;
    local vector positionVector;

    positionVector.X = Xpos;
    positionVector.Y = Ypos;
    positionVector.Z = Zpos+1400.0;
    
//p = Spawn(class'OSCTraceLight',,, positionVector, rot(0, 0, -1), ,true );

//p.setBrightness(10);
//p.setColor(255, 0, 255, 255);

sb = Spawn(class'OSCProj_ShockBall',,, positionVector, rot(0,0,0), , true);
sb.Init( positionVector);
sb.setSpeed(0);
sb.freeze();

//debug info
`log("made a light!");


}


// Create a ring of traces in a circle around the pawn and move them outwards
exec function waveTrace()
{
    local vector loc, norm, end;
    local TraceHitInfo hitInfo;
    local Actor traceHit;
    local vector tempRotation;
    local float trace_distance;
    local vector tempLocation;
    local float currentAngle;// = 360.0 / traceCount;
    local int i, j;
    local int waveTraceSetCount;
    local float rotateSet;
    
    waveTraceStartLocation = Location;
    
    for(j=0; j<(waveTraceCount / waveTraceSetSize); j++) {
    //end = Location + normal(vector(Rotation))*gtracelength; // trace to "infinity"
      for(i=0; i<waveTraceSetSize; i++) {
            
        // create new trace and add it to array
        // ( Math.cos( angle ) * radius, Math.sin( angle ) * radius )

//        X = radius * Cos(Angle);
//        Y = radius * Sin(Angle);
//        currentAngle = 360.0 / i+1;
        
        // On odd iterations of the set loop, half-rotate the set a notch for better coverage
//        if( ((waveTraceCount / waveTraceSetSize) % (j+1)) > 0)  {
//            rotateSet = (360.0 / waveTraceSetSize) / 2.0;
//        } else {
//            rotateSet = 0.0;
//        }

        currentAngle = 0 + i * (360.0 / waveTraceSetSize) + rotateSet;
        
        tempLocation = waveTraceStartLocation;
        tempLocation.X = waveTraceStartLocation.X + (j+1) * waveTraceRadius * Cos(currentAngle);
        tempLocation.Y = waveTraceStartLocation.Y + (j+1) * waveTraceRadius * Sin(currentAngle);
        
        // each trace should be at 360deg/traceCount around a circle at an offset radius 
        end = tempLocation + vect(0, 0, -1)* 32768;//gtracelength;
        traceHit = trace(loc, norm, end, tempLocation, true,, hitInfo);
        trace_distance = VSize(tempLocation - loc);
    
            // By default only 4 console messages are shown at the time
         //`log("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
         //`log("Location: "$loc.X$","$loc.Y$","$loc.Z);
         //`log("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
        //`log("Component: "$hitInfo.HitComponent);
        
        //tempLocation.Z = tempLocation.Z - trace_distance;
        
        waveTraces[i + j * waveTraceSetSize] = loc; //tempLocation;        
        
//        `log("WaveTrace #"$i + j * waveTraceSetSize$": "$tempLocation.X$", "$tempLocation.Y$", "$tempLocation.Z);
        if(bWaveTraceLog)
            `log("WaveTrace #"$i + j * waveTraceSetSize$": "$loc.X$", "$loc.Y$", "$loc.Z);

        //spawnOSCTraceLight(tempLocation.X, tempLocation.Y, tempLocation.Z);
        
        
        
        
        //DrawDebugLine(tempLocation, end, 255,0,0,false);
            
        //bWaveTraced = TRUE;
      }
    }
    
//    `log("********************************************:  IN PAWNTRACE *************** trace_distance "$trace_distance);
//    `log("********************************************:  IN PAWNTRACE *************** AFTER CHECK: trace_distance "$trace_distance);
//    `log("********************************************:  IN PAWNTRACE *************** AFTER CHECK: gdowntracelength "$gdowntracelength);
    
    
    /*
    if (traceHit == none)
    {
        ClientMessage("Trace failed.");
        gDownTrace = 0;
        return;        
    }
    else
    {
*/    
//        gDownTrace = trace_distance;

        //ClientMessage("Down: "$trace_distance);

        // Play a sound to confirm the information
//        ClientPlaySound(SoundCue'A_Vehicle_Cicada.SoundCues.A_Vehicle_Cicada_TargetLock');

        // By default only 4 console messages are shown at the time
 //        ClientMessage("Hit: "$traceHit$"  class: "$traceHit.class.outer.name$"."$traceHit.class);
 //        ClientMessage("Location: "$loc.X$","$loc.Y$","$loc.Z);
 //        ClientMessage("Material: "$hitInfo.Material$"  PhysMaterial: "$hitInfo.PhysMaterial);
//        ClientMessage("Component: "$hitInfo.HitComponent);
}


simulated exec function setProjectileTargets(float X, float Y, float Z)
{
    local OSCProj_SeekingShockBall pSSB;
    local vector currentTarget;
    
    bForceNetUpdate = TRUE; // Force replication
    
    currentTarget.X = X;
    currentTarget.Y = Y;
    currentTarget.Z = Z;
    
    ForEach AllActors(class'OSCProj_SeekingShockBall', pSSB) {
        pSSB.setSeekLocation(currentTarget);
    }
}

// Try outputting WeaponFired's HitLocation if exists with OSC
simulated function WeaponFired(Weapon InWeapon, bool bViaReplication, optional vector HitLocation)
{
    Super.WeaponFIred(InWeapon, bViaReplication, HitLocation);
    //showHitLocation(HitLocation);
}


event Possess(Pawn inPawn, bool bVehicleTransition)
{
    //super.Possess(inPawn, bVehicleTransition);
    SetMovementPhysics();
//    `log("******************DONE POSSESSING OSCPawn");

}

exec function getPawnUid()
{
    ClientMessage("Pawn UID = "$getUID());
    
    // Need Controller ID Here to differentiate pawns from bots from AI
    //ClientMessage("GetALocalPlayerControllerId(): "$GetALocalPlayerControllerId());
    
    ClientMessage("PlayerID: "$Controller.PlayerReplicationInfo.PlayerID);
    
}

simulated function int getUID()
{
    return uid;
}

simulated function setUID(int val)
{
    if (uid >= 0) {
//        `log("UID IS:"$uid);
    }
    else
    {
//        `log("UID IS NONE");
        uid = val;
    }
}

simulated exec function behindviewset(int _x, int _y, int _z)
{
//  CamOffset = (X=60, Y=0, Z= 0);
    camoffsetx = _x;
    camoffsety = _y;
    camoffsetz = _z;
    CamOffset.X = _x;
    CamOffset.Y = _y;
    CamOffset.Z = _z;//= (X=camoffsetx, Y=camoffsety, Z=camoffsetz)
	
	//OSCPlayerControllerDLL(Controller).camx = CamOffset.X;
	//OSCPlayerControllerDLL(Controller).camy = CamOffset.Y;
	//OSCPlayerControllerDLL(Controller).camz = CamOffset.Z;
	
}




/*
// CUSTOM CAMERA CODE
simulated function name GetDefaultCameraMode( PlayerController RequestedBy )
{
    return 'default';
}
*/


// BONE COORDINATE TESTING
/*
GetBoneCoords

native final function coords GetBoneCoords( name BoneName )
GetBoneCoords returns the global coordinates of the bone specified by _BoneName. The results are returned as a Coords struct (definition shown below). Origin is the location of the bone and axes are the orientation of the bone (XAxis is forward).

struct Coords
{
   var() config vector Origin, XAxis, YAxis, ZAxis;
};
*/

exec function GetBoneLocations()
{
    getBoneLocation();
}

function getBoneLocation()
{
    //local     int             Idx;
    local     vector        BoneLoc;
    local     vector        offset;
    local name bone;
    //array<Name>            Bones;
    
//    for( Idx = 0; Idx < Bones.Length; Idx++ )
//    {
//        HitInfo.BoneName     = Bones[Idx];
//        HitInfo.HitComponent = Mesh;

//        BoneLoc = Mesh.GetBoneLocation(Bones[Idx]);

        foreach currentBones(bone)
        {    
//            BoneLoc = Mesh.GetBoneLocation('valkordia_01Rwing_front_4');
            BoneLoc = Mesh.GetBoneLocation(bone);
			//SkeletalMeshComponent.GetBoneLocation( name BoneName, optional int Space ); // 0 == World, 1 == Local (Component)

        // global coordinate
//        `log("Bone Location [valkordia_01Rwing_front_4]: "$BoneLoc);
        /* */
            offset = BoneLoc - Location; 
            offset = offset << Rotation; 
        
            // local coordinate (? need to transform from global to local space?)
//            `log("Bone Offset [valkordia_01Rwing_front_4]: "$offset);


// *******************************************************************************************
            // THIS WORKS HERE: COMMENTING OUT FOR NOW (ROB - 7/7/13)
// *******************************************************************************************
            //`log("Bone Offset ["$bone$"]: "$offset);
            // Send offset to OSC
            gBone1 = offset;      
        
        }
//    }

}
/*
exec function GetBone()
{
    local Coords C;

    local Vector Loc;
    Local SkeletalMeshSocket SMS;
    
    SMS = SkeletalMeshComponent(Mesh).GetSocketByName('valkordia_01Lwing_front_4' );

    if( SMS != none )
    {
        Loc = SkeletalMeshComponent(Mesh).GetBoneLocation(SMS.BoneName);
        return Loc;    

    
//    `log("GBC: "$Mesh.GetBoneCoords( 'valkordia_01Lwing_front_4' ).Origin);
    
//    `log("Get Bone: "$C.Origin);
//    `log("Get Bone: "$GetBoneCoords( 'valkordia_01Rwing_front_4' ));    
}
*/
/*
exec function setParticleOffset(float X, float Y, float Z)
{
    PSC_CallEmitter.Translation.X = X;
    PSC_CallEmitter.Translation.Y = Y;
    PSC_CallEmitter.Translation.Z = Z;
}
*/


defaultproperties
{
    // number of waveTraces to perform, radius and set size 
    waveTraceCount = 72;
    waveTraceRadius = 200;
    waveTraceSetSize = 12;
    
    //groundspeed=10000.0
    seekingTurnRate=20.00000

    bHidden=false;
    
    bWeaponAttachmentVisible = false;

    // From UTPawn.uc
    RotationRate=(Pitch=20000, Yaw=20000, Roll=200000)//(Pitch=20000,Yaw=20000,Roll=20000)
    MaxLeanRoll=20480//2048    
    
    valkordiaAnimSpeed = 440.0
    baseAirSpeed = 440.0
    
    // for iPad
    // x range = 0 to 320
    // y range = 0 to 420
    // finger touch ~ 7 to 20
    /*
    OSCFingerSourceMax.X=320.00000
    OSCFingerSourceMin.X=0.00000
    OSCFingerSourceMax.Y=420.00000
    OSCFingerSourceMin.Y=0.00000
    OSCFingerSourceMax.Z=20.00000
    OSCFingerSourceMin.Z=7.00000
    OSCFingerOffsets.X = -160.00000
    OSCFingerOffset.Y = -210.0000
    OSCFingerOffset.Z = 0.00000
    OSCFingerWorldMax.X = 3000.00000
    OSCFingerWorldMin.X = -3000.00000
    OSCFingerWorldMax.Y = 3000.00000
    OSCFingerWorldMin.Y = -3000.00000
    OSCFingerWorldMax.Z = 3000.00000
    OSCFingerWorldMin.Z = 0.00001
*/

/*
Begin Object Name=WPawnSkeletalMeshComponent
//AnimTreeTemplate=AnimTree'thesis_characters.valkordia.CHA_valkordia_AnimTree'
AnimTreeTemplate=AnimTree'thesis_characters.valkordia.CHA_valkordia_AnimTree_01'
End Object
*/


Begin Object Name=WPawnSkeletalMeshComponent
//Begin Object Class=SkeletalMeshComponent Name=SkelMeshComp
    bHasPhysicsAssetInstance=true
    PhysicsAsset=PhysicsAsset'thesis_characters.valkordia.CHA_valkordia_skel_01_Physics'
    SkeletalMesh=SkeletalMesh'thesis_characters.valkordia.CHA_valkordia_skel_01'
    AnimTreeTemplate=AnimTree'thesis_characters.valkordia.CHA_valkordia_AnimTree_01'
    AnimSets(0)=AnimSet'thesis_characters.valkordia.CHA_valkordia_skel_01_Anims'
End Object

Begin Object Class=ParticleSystemComponent Name=CallEmitter
    bOwnerNoSee=false
    bAutoActivate=false
    //Translation=(X=21.0, Y=0.0, Z=-25.0)
    Template=ParticleSystem'WP_LinkGun.Effects.P_WP_Linkgun_Projectile'
End Object
PSC_CallEmitter = CallEmitter
Components.Add(CallEmitter)                                // If used, PSC not attaching to Socket?
//components.add(WPawnSkeletalMeshComponent)

//Mesh=SkelMeshComp
//components.add(SkelMeshComp); //(WPawnSkeletalMeshComponent)
//    StartLocationOffset=(X=121.000000,Y=0.000000,Z=-120.000000)


//ControllerClass=class'OSCPlayerControllerDLL'

 CamOffset = (X=60, Y=0, Z= 0)
 // CamOffset = (X=camoffsetx, Y=camoffsety, Z=camoffsetz)
  
}