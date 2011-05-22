//
// C++ Interface: osc
//
// Description: 
//
//
// Author: Robert Hamilton <>, (C) 2008
//
// Copyright: See COPYING file that comes with this distribution
//
//


#if defined(__cplusplus) || defined(_cplusplus)
   extern "C" {
#endif

#pragma once
#include "includes/targetver.h"
#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
#include <windows.h> // Windows Header Files:

typedef struct {
  char *hostname;
  char *port;
  int clientnum;
  float origin[3];
  int pm_flags;
  int weapon;
  int weaponstate;
  int jumppad_ent;
  int damageEvent;
  int damageYaw;
  int damagePitch;
  int damageCount;
  int surfaceFlags;
  int groundEntityNum;
  char *classname;
  char *hostnames[20]; // rkh - added array of client IPs
/* additional Data points used in q3apd and for future use in q3osc: */
  int velocity[3];
  int viewangles[3];
  int delta_angles[3];
} osc_client_vars;


typedef struct {
  char *hostname;
  char *port;
  int ownernum;
  int targetnum;
  int bounce;
  int explode;
  float projectilenum;
  float origin[3];
  char *classname;
  char *hostname1;
  char *hostname2;
  char *hostname3;
  char *hostname4;
  char *hostname5;
} osc_projectile_vars;

typedef struct {
  float g_gravity;
  int g_gravity_update;
  int g_speed;
  int g_speed_update;
  int g_homing_speed;
  int g_homing_speed_update;
  int testvar;
} osc_input_vars;

// UnrealScript test structs
struct FString
{
   wchar_t* Data;
   int ArrayNum;
   int ArrayMax;
};

struct FVector
{
   float x,y,z;
};

struct MyPlayerStruct
{
   FString PlayerName;
   FString PlayerPassword;
   float Health;
   float Score;   
   FString testval;
};

struct PointClickStruct
{
	FString Hostname;
	int Port;
	FString TraceHit;
	FString TraceHit_class;
	FString TraceHit_class_outerName;
	float LocX;
	float LocY;
	float LocZ;
	FString HitInfo_material;
	FString HitInfo_physmaterial;
	FString HitInfo_hitcomponent;
};


struct PointClickStructTEST
{
	FString Hostname;
	int Port;
	FString TraceHit;
	FString TraceHit_class;
	FString TraceHit_class_outerName;
	float LocX;
	float LocY;
	float LocZ;
	FString HitInfo_material;
	FString HitInfo_physmaterial;
	FString HitInfo_hitcomponent;
};

struct PlayerStateStruct
{
	FString Hostname;
	int Port;
	FString PlayerName;
	float LocX;
	float LocY;
	float LocZ;
	bool crouch;
};

struct PlayerStateStructTEST
{
	FString Hostname;
	int Port;
	FString PlayerName;
	float LocX;
	float LocY;
	float LocZ;
	bool crouch;
};

struct ProjectileStateStruct
{
	FString Hostname;
	int Port;
	FString ProjName;
	FString ProjType;
	int ProjID;
	float LocX;
	float LocY;
	float LocZ;
	float Size;
	int Bounce;
	int Destroyed;
};

struct MeshStateStruct
{
	FString Hostname;
	int Port;
	FString MeshName;
	FString MeshType;
	FString MeshEvent;
	float LocX;
	float LocY;
	float LocZ;
};

struct OSCMessageStruct
{
	float test;
};

struct OSCGameParams
{
	float gameGravity;
	float gameSpeed;
};

struct OSCTriggerStruct
{
	FString Hostname;
	int Port;
	FString TriggerName;
	int On;
};

struct OSCFingerController
{
	float f1X;
	float f1Y;
	float f1Z;
	float f1on;
	float f2X;
	float f2Y;
	float f2Z;
	float f2on;
	float f3X;
	float f3Y;
	float f3Z;
	float f3on;
	float f4X;
	float f4Y;
	float f4Z;
	float f4on;
	float f5X;
	float f5Y;
	float f5Z;	
	float f5on;
};

//void	sendOSCmessage(int clientno, char *hostname, char *portnumber);
__declspec(dllexport) void	sendOSCbundle(osc_client_vars currentClient);
__declspec(dllexport) void	sendOSCmessage(osc_client_vars currentClient);

__declspec(dllexport) double returnDouble(double a);
__declspec(dllexport) void sendOSCmessageTest();
__declspec(dllexport) void sendOSCmessageTest2();
__declspec(dllexport) void sendOSCmessageTest3(MyPlayerStruct a);
__declspec(dllexport) void sendOSCmessageTest4(MyPlayerStruct* a);
__declspec(dllexport) void sendOSCpointClick(PointClickStruct* a);
__declspec(dllexport) void sendOSCPlayerState(PlayerStateStruct* pState);
__declspec(dllexport)void sendOSCProjectileState(ProjectileStateStruct* pState);
__declspec(dllexport)void sendOSCMeshState(MeshStateStruct* mState);

__declspec(dllexport) void sendOSCPlayerStateTEST(PlayerStateStructTEST* pState);

__declspec(dllexport) OSCMessageStruct getOSCTest();
__declspec(dllexport) float getOSCTestfloat();

// Game State functions
__declspec(dllexport) OSCGameParams getOSCGameParams();
__declspec(dllexport) float getOSCGameSpeed();
__declspec(dllexport) float getOSCGameGravity();

//OSC Coordinate controls by iPad finger controller
__declspec(dllexport) OSCFingerController* getOSCFingerController();
__declspec(dllexport)FVector* getOSCFinger1();

// Initialize the OSC Receiver
__declspec(dllexport) void initOSCReceiver();

// OSC Trigger object
__declspec(dllexport) void triggerActivated(OSCTriggerStruct* a);

void	sendOSCbundle_projectile(osc_projectile_vars currentProjectile);
void	sendOSCmessage_projectile(osc_projectile_vars currentProjectile); //, char *type);

//void	receiveOSCmessage( void ); // osc listener method
unsigned int __stdcall receiveOSCmessage(void *arg );

char*	WcharToChar(int mode, wchar_t* val);

//osc_input_vars	getOSCmessage( void ); // test data retrieval

//#ifdef MACOS_X
	   extern osc_input_vars gOSCvars;
//#else
//	   osc_input_vars gOSCvars;
//#endif
	   
#if defined(__cplusplus) || defined(_cplusplus)
   }
#endif
