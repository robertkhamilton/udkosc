
#include "osc.h"

//extern "C" {
//#include "../game/g_local.h"
//}
#include "includes/stdafx.h"
#include <stdio.h>
#include <assert.h>

#include <string>
#include <sstream>
//#include "../ui/menudef.h"			// rkh
#include <iostream> //rkh
#include "osc/OscOutboundPacketStream.h"
#include "ip/UdpSocket.h"
#include "ip/IpEndpointName.h"
#include "osc/OscReceivedElements.h"
#include "osc/OscPacketListener.h"

#include <stdlib.h>
#include "atlbase.h"
#include "atlstr.h"
#include "comutil.h"

#include <windows.h>
#include <process.h>
#include <math.h>

#define C_DATA_SIZE	30000000

//#define ADDRESS "127.0.0.1"
//#define ADDRESS "192.168.1.77"
#define PORT 7000
#define APORT 7001
#define CURRENTHOST "10.0.1.3"
#define CURRENTPORT 7000
#define OUTPUT_BUFFER_SIZE 2048

//osc_input_vars gOSCvars;
OSCMessageStruct testStruct;
OSCGameParams OSCGameParamsStruct;
static OSCFingerController OSCFingerControllerStruct;

OSCScriptPlayermove OSCScriptPlayermoveStruct;
OSCScriptCameramove OSCScriptCameramoveStruct;
OSCConsoleCommand OSCConsoleCommandStruct;

float f1X, f1Y, f1Z;

namespace osc{

class PacketListener : public osc::OscPacketListener {
protected:

    virtual void ProcessMessage( const osc::ReceivedMessage& m, 
				const IpEndpointName& remoteEndpoint )
    {
        try{	
            // example of parsing single messages. osc::OsckPacketListener
            // handles the bundle traversal.
  
            if( strcmp( m.AddressPattern(), "/g_gravity" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a3;
                args >> a3 >> osc::EndMessage;
				//gOSCvars.g_gravity = a3;
				//gOSCvars.g_gravity_update = 1;
                std::cout << "received '/g_gravity': "
				<< a3 << "\n";
	    }else if( strcmp( m.AddressPattern(), "/g_speed" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a3;
                args >> a3 >> osc::EndMessage;
				//gOSCvars.g_speed = a3;
				//gOSCvars.g_speed_update = 1;
                
                std::cout << "received '/g_speed': "
                    << a3 << "\n";
		 }else if( strcmp( m.AddressPattern(), "/test" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a3;
                args >> a3 >> osc::EndMessage;
				testStruct.test = a3;
				//gOSCvars.g_speed_update = 1;
                
                //std::cout << "received '/test': "
                //    << a3 << "\n";
		 }else if( strcmp( m.AddressPattern(), "/gameGravity" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCGameParamsStruct.gameGravity = a1;
		 }else if( strcmp( m.AddressPattern(), "/gameSpeed" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCGameParamsStruct.gameSpeed = a1;
		 }else if( strcmp( m.AddressPattern(), "/fingers" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1,a2,a3,a5,a6,a7,a9,a10,a11,a13,a14,a15,a17,a18,a19;
				float b4,b8,b12,b16,b20;
				
                args >> a1 >> a2 >> a3 >> b4 >> a5 >> a6 >> a7 >> b8 >> a9 >> a10 >> a11 >> b12 >> a13 >> a14 >> a15 >> b16 >> a17 >>a18 >>a19 >> b20 >>  osc::EndMessage;
				OSCFingerControllerStruct.f1X = a1;
				OSCFingerControllerStruct.f1Y = a2;
				OSCFingerControllerStruct.f1Z = a3;
				OSCFingerControllerStruct.f1on = b4;
				OSCFingerControllerStruct.f2X = a5;
				OSCFingerControllerStruct.f2Y = a6;
				OSCFingerControllerStruct.f2Z = a7;
				OSCFingerControllerStruct.f2on = b8;
				OSCFingerControllerStruct.f3X = a9;
				OSCFingerControllerStruct.f3Y = a10;
				OSCFingerControllerStruct.f3Z = a11;
				OSCFingerControllerStruct.f3on = b12;
				OSCFingerControllerStruct.f4X = a13;
				OSCFingerControllerStruct.f4Y = a14;
				OSCFingerControllerStruct.f4Z = a15;
				OSCFingerControllerStruct.f4on = b16;
				OSCFingerControllerStruct.f5X = a17;
				OSCFingerControllerStruct.f5Y = a18;
				OSCFingerControllerStruct.f5Z = a19;
				OSCFingerControllerStruct.f5on = b20;
            }else if( strcmp( m.AddressPattern(), "/g_homing_speed" ) == 0 ){

                // example #1 -- argument stream interface
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                //bool a1;
                //osc::int32 a2;
                float a3;
                //const char *a4;
                args >> a3 >> osc::EndMessage;
				//gOSCvars.g_homing_speed = a3;
				//gOSCvars.g_homing_speed_update = 1;
                
                std::cout << "received '/g_homing_speed': "
                    << a3 << "\n";
		
            }else if( strcmp( m.AddressPattern(), "/test2" ) == 0 ){
                // example #2 -- argument iterator interface, supports
                // reflection for overloaded messages (eg you can call 
                // (*arg)->IsBool() to check if a bool was passed etc).
                osc::ReceivedMessage::const_iterator arg = m.ArgumentsBegin();
                bool a1 = (arg++)->AsBool();
                int a2 = (arg++)->AsInt32();
                float a3 = (arg++)->AsFloat();
                const char *a4 = (arg++)->AsString();
                if( arg != m.ArgumentsEnd() )
                    throw osc::ExcessArgumentException();
                
                std::cout << "received '/test2' message with arguments: "
                    << a1 << " " << a2 << " " << a3 << " " << a4 << "\n";
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/playermove/x" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptPlayermoveStruct.x = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/playermove/y" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptPlayermoveStruct.y = a1;
				}else if( strcmp( m.AddressPattern(), "/udkosc/script/playermove/z" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptPlayermoveStruct.z = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/playermove/speed" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptPlayermoveStruct.speed = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/playermove/jump" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptPlayermoveStruct.jump = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/playermove/stop" ) == 0 ){
                //osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                //float a1;
                //args >> a1 >> osc::EndMessage;
				OSCScriptPlayermoveStruct.stop = 1.0;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/playermove/fly" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptPlayermoveStruct.fly = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/playermove/airspeed" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptPlayermoveStruct.airspeed = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/cameramove/x" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptCameramoveStruct.x = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/cameramove/y" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptCameramoveStruct.y = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/cameramove/z" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptCameramoveStruct.z = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/cameramove/pitch" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptCameramoveStruct.pitch = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/cameramove/yaw" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptCameramoveStruct.yaw = a1;
			}else if( strcmp( m.AddressPattern(), "/udkosc/script/cameramove/roll" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
				OSCScriptCameramoveStruct.roll = a1;
            }else if( strcmp( m.AddressPattern(), "/udkosc/script/console" ) == 0 ){
                osc::ReceivedMessageArgumentStream args = m.ArgumentStream();
                float a1;
                args >> a1 >> osc::EndMessage;
                OSCConsoleCommandStruct.command = a1;
            } else {
					osc::ReceivedMessage::const_iterator arg = m.ArgumentsBegin();
					float a1 = (arg++)->AsFloat();
					std::cout <<"Else in PacketListener: " << a1 << std::endl;
			}
        }catch( osc::Exception& e ){
            // any parsing errors such as unexpected argument types, or 
            // missing arguments get thrown as exceptions.
            std::cout << "error while parsing message: "
                << m.AddressPattern() << ": " << e.what() << "\n";
        }
    }
};

}	// end namespace osc

__declspec(dllexport) void triggerActivated(OSCTriggerStruct* pState)
{
   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
  UdpTransmitSocket socket( IpEndpointName( WcharToChar(1, pState->Hostname.Data), pState->Port ));
   p.Clear();

	p << osc::BeginMessage( "/trigger" )
		<< WcharToChar(1, pState->TriggerName.Data)
		<< (int)pState->On
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)OSCGameParams getOSCGameParams()
{
  return OSCGameParamsStruct;
}

_declspec(dllexport)OSCScriptPlayermove getOSCScriptPlayermove()
{
	OSCScriptPlayermove localStruct;
	localStruct = OSCScriptPlayermoveStruct;
	if(OSCScriptPlayermoveStruct.jump > 0.0)
	{
		OSCScriptPlayermoveStruct.jump = 0.0;
	}

	if(OSCScriptPlayermoveStruct.stop == 1.0)
	{
		OSCScriptPlayermoveStruct.stop = 0.0;
		OSCScriptPlayermoveStruct.x = 0.0;
		OSCScriptPlayermoveStruct.y = 0.0;
		OSCScriptPlayermoveStruct.z = 0.0;
	}
	return localStruct;
	//return OSCScriptPlayermoveStruct;

}

_declspec(dllexport)OSCScriptCameramove getOSCScriptCameramove()
{
	return OSCScriptCameramoveStruct;
}

_declspec(dllexport)float getOSCConsoleCommand()
{
	return OSCConsoleCommandStruct.command;
}

__declspec(dllexport)double returnDouble(double a)
{
  return a+a;
}

__declspec(dllexport)OSCMessageStruct getOSCTest()
{
  return testStruct;
}

__declspec(dllexport)float getOSCGameSpeed()
{
  return OSCGameParamsStruct.gameSpeed;
}

__declspec(dllexport)float getOSCGameGravity()
{
  return OSCGameParamsStruct.gameGravity;
}


__declspec(dllexport)float getOSCTestfloat()
{
  return testStruct.test;
}

__declspec(dllexport)OSCFingerController* getOSCFingerController()
{
	return &OSCFingerControllerStruct;
}

__declspec(dllexport)FVector* getOSCFinger1()
{
	static FVector result;
	result.x = OSCFingerControllerStruct.f1X;
	result.y = OSCFingerControllerStruct.f1Y;
	result.z = OSCFingerControllerStruct.f1Z;
	return &result;
}

/*
	__declspec(dllexport) FVector* CallDLL2(float x, float y, float z)
	{
		static FVector result;	// declared static so that the struct's memory is still valid after the function returns.
		result.x = x;
		result.y = y;
		result.z = z;
		return &result;
	}
*/

__declspec(dllexport)void sendOSCPlayerState(PlayerStateStruct* pState)
{
   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
  //UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
  UdpTransmitSocket socket( IpEndpointName( WcharToChar(1, pState->Hostname.Data), pState->Port ));
   p.Clear();

	p << osc::BeginMessage( "/player" )
		<< WcharToChar(1, pState->PlayerName.Data)
	    << (float)pState->LocX
		<< (float)pState->LocY
		<< (float)pState->LocZ
		<< (bool)pState->crouch
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCProjectileState(ProjectileStateStruct* pState)
{
   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
  //UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
  UdpTransmitSocket socket( IpEndpointName( WcharToChar(1, pState->Hostname.Data), pState->Port ));
   p.Clear();

	p << osc::BeginMessage( "/projectile" )
		<< WcharToChar(1, pState->ProjName.Data)
		<< WcharToChar(1, pState->ProjType.Data)
		<< (int)pState->ProjID
		<< (float)pState->LocX
		<< (float)pState->LocY
		<< (float)pState->LocZ
		<< (float)pState->Size
		<< (int)pState->Bounce
		<< (int)pState->Destroyed
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCMeshState(MeshStateStruct* mState)
{
   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
  //UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
  UdpTransmitSocket socket( IpEndpointName( WcharToChar(1, mState->Hostname.Data), mState->Port ));
   p.Clear();

	p << osc::BeginMessage( "/mesh" )
		<< WcharToChar(1, mState->MeshName.Data)
		<< WcharToChar(1, mState->MeshType.Data)
		<< WcharToChar(1, mState->MeshEvent.Data)
		<< (float)mState->LocX
		<< (float)mState->LocY
		<< (float)mState->LocZ
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCPlayerStateTEST(PlayerStateStructTEST* pState)
{
   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
   //UdpTransmitSocket socket( IpEndpointName( WcharToChar(1, pState->Hostname.Data), pState->Port ));
   p.Clear();

	p << osc::BeginMessage( "/player" )
		<< WcharToChar(1, pState->PlayerName.Data)
	    << (float)pState->LocX
		<< (float)pState->LocY
		<< (float)pState->LocZ
		<< (bool)pState->crouch
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCpointClick(PointClickStruct* pointClick)
{
/*
struct PointClickStruct
{
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
*/
	// Convert to a char*
    //char* traceHit = WcharToChar(1, pointClick->TraceHit.Data);

	int test1 = 100;
	float test2 = 222;
	
   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
   p.Clear();

	p << osc::BeginMessage( "/player" )
		<< WcharToChar(1, pointClick->TraceHit.Data)
		<< WcharToChar(1, pointClick->TraceHit_class.Data)
		<< WcharToChar(1, pointClick->TraceHit_class_outerName.Data)
	    << (float)pointClick->LocX
		<< (float)pointClick->LocY
		<< (float)pointClick->LocZ
		<< WcharToChar(1, pointClick->HitInfo_material.Data)
		<< WcharToChar(1, pointClick->HitInfo_physmaterial.Data)
		<< WcharToChar(1, pointClick->HitInfo_hitcomponent.Data)
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCpointClickTEST(PointClickStructTEST* pointClick)
{

	// Convert to a char*
    //char* traceHit = WcharToChar(1, pointClick->TraceHit.Data);

	int test1 = 100;
	float test2 = 222;
	
   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
   //UdpTransmitSocket socket( IpEndpointName( WcharToChar(1, pointClick->Hostname.Data), CURRENTPORT ));
   p.Clear();

	p << osc::BeginMessage( "/player" )
		<< WcharToChar(1, pointClick->TraceHit.Data)
		<< WcharToChar(1, pointClick->TraceHit_class.Data)
		<< WcharToChar(1, pointClick->TraceHit_class_outerName.Data)
	    << (float)pointClick->LocX
		<< (float)pointClick->LocY
		<< (float)pointClick->LocZ
		<< WcharToChar(1, pointClick->HitInfo_material.Data)
		<< WcharToChar(1, pointClick->HitInfo_physmaterial.Data)
		<< WcharToChar(1, pointClick->HitInfo_hitcomponent.Data)
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}
__declspec(dllexport)void sendOSCmessageTest4(MyPlayerStruct* Player)
{
/*
	wchar_t temp[1024];
	swprintf_s(temp, 1024, L"PlayerName: '%s', PlayerPassword: '%s', Health: %f, Score: %f",
		Player->PlayerName.Data ? Player->PlayerName.Data : L"",			// Player->PlayerName.Data could be NULL in the case of an empty string.
		Player->PlayerPassword.Data ? Player->PlayerPassword.Data : L"",	// Player->PlayerPassword.Data could be NULL in the case of an empty string.
		Player->Health,
		Player->Score);
	//MessageBox(0, temp, L"StructTest", MB_OK	);
*/
   wchar_t* playername = Player->testval.Data;

	// Convert to a char*
    size_t origsize = wcslen(playername) + 1;
    const size_t newsize = 100;
    size_t convertedChars = 0;
	char char_playername[newsize];
   wcstombs_s(&convertedChars, char_playername, origsize, playername, _TRUNCATE);

	int test1 = 100;
	float test2 = 222;
	
   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
   p.Clear();

	p << osc::BeginMessage( "/player" )
		<< char_playername
	    << (int)test1
	    << (float)test2
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCmessageTest3(MyPlayerStruct a)
{
	//std::string str(currentClient.port);
	//std::istringstream strin(str);
	//int port;
	//strin >> port;

	int test1 = 100;
	float test2 = 222;
	
   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
   p.Clear();

   wchar_t* playername = a.testval.Data;

	// Convert to a char*
    size_t origsize = wcslen(playername) + 1;
    const size_t newsize = 100;
    size_t convertedChars = 0;
	char char_playername[newsize];
   wcstombs_s(&convertedChars, char_playername, origsize, playername, _TRUNCATE);

	CString cstring(a.testval.Data);



   // std::string teststr(a.PlayerName.Data);
   // std::string teststr(a.PlayerName);

	p << osc::BeginMessage( "/player" )
		<< cstring
		<< char_playername
	    << (int)test1
	    << (float)test2
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCmessageTest2()
{
	//std::string str(currentClient.port);
	//std::istringstream strin(str);
	//int port;
	//strin >> port;
	int test1 = 100;
	float test2 = 222;

   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
   p.Clear();

	p << osc::BeginMessage( "/player" )
	    << (int)test1
	    << (float)test2
	  << osc::EndMessage;
	
   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCmessageTest()
{
	//std::string str(currentClient.port);
	//std::istringstream strin(str);
	//int port;
	//strin >> port;
	int test1 = 100;
	float test2 = 222;

   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
   p.Clear();

	p << osc::BeginMessage( "/player" )
	    << (int)test1
	    << (float)test2
	  << osc::EndMessage;

   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCmessageTest2(double d, float f, int i, char c )
{
	//std::string str(currentClient.port);
	//std::istringstream strin(str);
	//int port;
	//strin >> port;
	int test1 = 100;
	float test2 = 222;
	std::string teststr("this is a test");
 

   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( CURRENTHOST, CURRENTPORT ));
   p.Clear();

	p << osc::BeginMessage( "/player" )
		<< "this is a test"
	    << (int)test1
	    << (float)test2
		<< (int)i
		<< (float)f
		<< (double)d
	  << osc::EndMessage;

   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

// if dynamic IP is enabled, ip's will be selected from an array populated by the user
// currently, ips are set in the client and assed in 
void getIPAddress (int index){

}

char* WcharToChar(int mode, wchar_t* val)
{
	// mode will be used later for multiple conversion types

	// Convert to a char*
    size_t origsize = wcslen(val) + 1;
    const size_t newsize = 100;
    size_t convertedChars = 0;
	char char_result[newsize];
    wcstombs_s(&convertedChars, char_result, origsize, val, _TRUNCATE);

   return char_result;

}
void sendOSCmessage_projectile(osc_projectile_vars currentProjectile) //, char *type)
{
//	std::string classname = currentProjectile.classname;
//	std::string slash = "/";

	std::string str(currentProjectile.port);
	std::istringstream strin(str);
	int port;
	strin >> port;
	char buffer[OUTPUT_BUFFER_SIZE];
	osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );

	UdpTransmitSocket socket( IpEndpointName( currentProjectile.hostname, port ));
	p.Clear();

//	p << osc::BeginMessage((slash + classname).c_str())
	p << osc::BeginMessage("/projectile")
            << currentProjectile.classname
	    << (int)currentProjectile.ownernum
	    << (int)currentProjectile.projectilenum
	    << (float)currentProjectile.origin[0]
	    << (float)currentProjectile.origin[1]
	    << (float)currentProjectile.origin[2]
	    << (int)currentProjectile.targetnum
	    << (int)currentProjectile.bounce
	    << (int)currentProjectile.explode
	  << osc::EndMessage;
	
	if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

void sendOSCbundle_projectile(osc_projectile_vars currentProjectile)
{
	std::string str(currentProjectile.port);
	std::istringstream strin(str);
	int port;
	strin >> port;
	char buffer[OUTPUT_BUFFER_SIZE];
	osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );

	UdpTransmitSocket socket( IpEndpointName( currentProjectile.hostname, port ));
	p.Clear();

	p << osc::BeginBundle()
		<< osc::BeginMessage( "/classname" ) << currentProjectile.classname << osc::EndMessage
		<< osc::BeginMessage( "/projectilenum" ) << (int)currentProjectile.projectilenum << osc::EndMessage
		<< osc::BeginMessage( "/origin" ) << (float)currentProjectile.origin[0] << (float)currentProjectile.origin[1] << (float)currentProjectile.origin[2] << osc::EndMessage
//		<< osc::BeginMessage( "/originy" ) << currentProjectile.origin[1] << osc::EndMessage
//		<< osc::BeginMessage( "/originz" ) << currentProjectile.origin[2] << osc::EndMessage
		<< osc::BeginMessage( "/ownernum" ) << currentProjectile.ownernum << osc::EndMessage
		<< osc::BeginMessage( "/targetnum" ) << currentProjectile.targetnum << osc::EndMessage
		<< osc::BeginMessage( "/bounce" ) << currentProjectile.bounce << osc::EndMessage
		<< osc::BeginMessage( "/explode" ) << currentProjectile.explode << osc::EndMessage
	<< osc::EndBundle;

	if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport)void sendOSCmessage(osc_client_vars currentClient)
{
	std::string str(currentClient.port);
	std::istringstream strin(str);
	int port;
	strin >> port;

   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( currentClient.hostname, port ));
   p.Clear();

	p << osc::BeginMessage( "/player" )
	    << currentClient.classname
	    << (int)currentClient.clientnum
	    << (float)currentClient.origin[0]
	    << (float)currentClient.origin[1]
	    << (float)currentClient.origin[2]

	    << (float)currentClient.velocity[0]
	    << (float)currentClient.velocity[1]
	    << (float)currentClient.velocity[2]
 
		<< (float)currentClient.viewangles[0]
		<< (float)currentClient.viewangles[1]
		<< (float)currentClient.viewangles[2]

		<< (float)currentClient.delta_angles[0]
		<< (float)currentClient.delta_angles[1]
		<< (float)currentClient.delta_angles[2]
 
		<< (int)currentClient.weapon
		<< (int)currentClient.weaponstate
 		<< (int)currentClient.jumppad_ent
 
 		<< (int)currentClient.damageEvent
		<< (int)currentClient.damageYaw
		<< (int)currentClient.damagePitch
		<< (int)currentClient.damageCount
		<< (int)currentClient.groundEntityNum

 /*
 currentClient.velocity[0] = pm.ps->velocity[0];
 currentClient.velocity[1] = pm.ps->velocity[1];
 currentClient.velocity[2] = pm.ps->velocity[2];
 currentClient.viewangles[0] = pm.ps->viewangles[0];
 currentClient.viewangles[1] = pm.ps->viewangles[1];
 currentClient.viewangles[2] = pm.ps->viewangles[2];
 currentClient.delta_angles[0] = pm.ps->delta_angles[0];
 currentClient.delta_angles[1] = pm.ps->delta_angles[1];
 currentClient.delta_angles[2] = pm.ps->delta_angles[2];
 currentClient.weapon = pm.ps->weapon;
 currentClient.weaponstate = pm.ps->weaponstate;
 currentClient.jumppad_ent = pm.ps->jumppad_ent;
 currentClient.damageEvent = pm.ps->damageEvent;
 currentClient.damageYaw = pm.ps->damageYaw;
 currentClient.damagePitch = pm.ps->damagePitch;
 currentClient.damageCount = pm.ps->damageCount;
 currentClient.groundEntityNum = pm.ps->groundEntityNum;
 //	currentClient.surfaceFlags = pm.surfaceFlags;
 */
	  << osc::EndMessage;

   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport) void sendOSCbundle(osc_client_vars currentClient)
{

	std::string str(currentClient.port);
	std::istringstream strin(str);
	int port;
	strin >> port;

   char buffer[OUTPUT_BUFFER_SIZE];
   osc::OutboundPacketStream p( buffer, OUTPUT_BUFFER_SIZE );
   UdpTransmitSocket socket( IpEndpointName( currentClient.hostname, port ));
   p.Clear();

   p << osc::BeginBundle()
	<< osc::BeginMessage( "/classname" ) << currentClient.classname << osc::EndMessage	
	<< osc::BeginMessage( "/client" ) << currentClient.clientnum << osc::EndMessage
	<< osc::BeginMessage( "/originx" ) << currentClient.origin[0] << osc::EndMessage
	<< osc::BeginMessage( "/originy" ) << currentClient.origin[1] << osc::EndMessage
	<< osc::BeginMessage( "/originz" ) << currentClient.origin[2] << osc::EndMessage

	<< osc::BeginMessage( "/velocity/x" ) << currentClient.velocity[0] << osc::EndMessage
	<< osc::BeginMessage( "/velocity/y" ) << currentClient.velocity[1] << osc::EndMessage
	<< osc::BeginMessage( "/velocity/z" ) << currentClient.velocity[2] << osc::EndMessage

	<< osc::BeginMessage( "/viewangles/x" ) << currentClient.viewangles[0] << osc::EndMessage
	<< osc::BeginMessage( "/viewangles/y" ) << currentClient.viewangles[1] << osc::EndMessage
	<< osc::BeginMessage( "/viewangles/z" ) << currentClient.viewangles[2] << osc::EndMessage

	<< osc::BeginMessage( "/delta_angles/x" ) << currentClient.delta_angles[0] << osc::EndMessage
	<< osc::BeginMessage( "/delta_angles/y" ) << currentClient.delta_angles[1] << osc::EndMessage
	<< osc::BeginMessage( "/delta_angles/z" ) << currentClient.delta_angles[2] << osc::EndMessage

	<< osc::BeginMessage( "/weapon" ) << currentClient.weapon << osc::EndMessage
	<< osc::BeginMessage( "/weaponstate" ) << currentClient.weaponstate << osc::EndMessage	 
	<< osc::BeginMessage( "/jumppad_ent" ) << currentClient.jumppad_ent << osc::EndMessage	 

	<< osc::BeginMessage( "/damageEvent" ) << currentClient.damageEvent << osc::EndMessage	 
	<< osc::BeginMessage( "/damageYaw" ) << currentClient.damageYaw << osc::EndMessage	 	 
	<< osc::BeginMessage( "/damagePitch" ) << currentClient.damagePitch << osc::EndMessage	 
	<< osc::BeginMessage( "/damageCount" ) << currentClient.damageCount << osc::EndMessage	 

	<< osc::BeginMessage( "/groundEntityNum" ) << currentClient.groundEntityNum << osc::EndMessage	 

/*	 
	 currentClient.velocity[0] = pm.ps->velocity[0];
	 currentClient.velocity[1] = pm.ps->velocity[1];
	 currentClient.velocity[2] = pm.ps->velocity[2];
	 currentClient.viewangles[0] = pm.ps->viewangles[0];
	 currentClient.viewangles[1] = pm.ps->viewangles[1];
	 currentClient.viewangles[2] = pm.ps->viewangles[2];
	 currentClient.delta_angles[0] = pm.ps->delta_angles[0];
	 currentClient.delta_angles[1] = pm.ps->delta_angles[1];
	 currentClient.delta_angles[2] = pm.ps->delta_angles[2];
	 currentClient.weapon = pm.ps->weapon;
	 currentClient.weaponstate = pm.ps->weaponstate;
	 currentClient.jumppad_ent = pm.ps->jumppad_ent;
	 currentClient.damageEvent = pm.ps->damageEvent;
	 currentClient.damageYaw = pm.ps->damageYaw;
	 currentClient.damagePitch = pm.ps->damagePitch;
	 currentClient.damageCount = pm.ps->damageCount;
	 currentClient.groundEntityNum = pm.ps->groundEntityNum;
	 //	currentClient.surfaceFlags = pm.surfaceFlags;
	 */	
	<< osc::EndBundle;

   if(p.IsReady()){ socket.Send( p.Data(), p.Size() );}
}

__declspec(dllexport) void initOSCReceiver()
{
//	receiveOSCmessage();

//	HANDLE hMyThread;
//	hMyThread = CreateThread(NULL, 0, 0, receiveOSCmessage, 0, 0);

// thread is now created and running the function, threadFunc

// Call some other function in main thread

// Do something else in main thread

// Wait for thread to terminate
//WaitForSingleObject(hMyThread, INFINITE);

double *myData = (double*)malloc(sizeof(double)* C_DATA_SIZE);

HANDLE handleT1;
unsigned int myThreadId;
handleT1 = (HANDLE)_beginthreadex(
                  NULL,                 // security
                  0,			// Stack size, 0 is usually fine.
                  receiveOSCmessage,		// This is the function that will be executed
                  (void*)myData,	// Argument list. In this case, a pointer to our data array
                  0,			// 0 will start thread immediately. See MSDN for more info
                  &myThreadId );	// Thread ID. This can be NULL, if you'd like.

printf("Waiting for workthread to complete...\n");

//	WaitForSingleObject( handleT1, INFINITE );
//	CloseHandle(handleT1);	// After you're done with a thread forever, close the handle.


	printf("Finished\n");
//	free(myData);		// Free up the memory we allocated.

}

//void receiveOSCmessage()
unsigned int __stdcall receiveOSCmessage(void *arg )
{

//BOOL bJobCompleted = FALSE;

//while (!bJobCompleted)
//{

    std::cout << "============================================ \n";
    std::cout << "============================================ \n";
    std::cout << "============================================ \n";
    std::cout << "RKH - TESTING receiveOSCmessage() in osc.cpp \n";
    std::cout << "============================================ \n";
    std::cout << "============================================ \n";
    std::cout << "============================================ \n";
    std::cout <<"Hello World" << std::endl;

    osc::PacketListener listener;

	std::cout <<"Before UdpListeningReceiveSocket" << std::endl;

    UdpListeningReceiveSocket s(
            IpEndpointName( IpEndpointName::ANY_ADDRESS, APORT ),
            &listener );

	std::cout <<"After UdpListeningReceiveSocket" << std::endl;
   //s.Break();
    s.RunUntilSigInt();

		
	// Do job
//	bJobCompleted = TRUE;
//}

 // ExitThread(0);
 // return;
	return 0;
}

//osc_input_vars getOSCmessage()
//{
	//osc_input_vars teststruct;
	//teststruct.testvar = 11;
	//gOSCvars.testvar = 12;
	//return gOSCvars;
//}
