// launch with OSC_recv.ck

// host name and port
"localhost" => string hostname;
7001 => int port;

// get command line
if( me.args() ) me.arg(0) => hostname;
if( me.args() > 1 ) me.arg(1) => Std.atoi => port;

// send object
OscSend xmit;

// aim the transmitter
xmit.setHost( hostname, port );

//10.0 => float curryaw;

fun void a(int id)
{
  0.0 => float curryaw;
  
  while(true)
  {
    //xmit.startMsg("/udkosc/script/playermove/teleport", "f, f, f, f" );
    //xmit.startMsg("/udkosc/script/playermove/jump", "f, f");//, f, f, f, f, f, f, f");
    xmit.startMsg("/udkosc/script/playermove", "f, f, f, f, f, f, f, f, f");


    1.0 => float x => xmit.addFloat;
    0.0 => float y => xmit.addFloat;
    0.0 => float z => xmit.addFloat;

    0.0 => float jump => xmit.addFloat;

    1000.0 => float speed => xmit.addFloat;
    0.0 => float pitch => xmit.addFloat;
    
    (curryaw + 10.0)%360.0 => curryaw;
    //<<< curryaw, id >>>;
    curryaw => float yaw => xmit.addFloat;
    0.0 => float roll => xmit.addFloat;

    id => xmit.addFloat;
        
    .01::second => now;
  }
}

fun void jump(int id, int t)
{
    xmit.startMsg("/udkosc/script/playermove/jump", "f, f");
    100.0 => float jump => xmit.addFloat;
    id => xmit.addFloat;
    t::second => now;
}

fun void teleport(int id)
{
  while(true)
  {
    xmit.startMsg("/udkosc/script/playermove/teleport", "f, f, f, f" );
    0.0 => float x => xmit.addFloat;
    0.0 => float y => xmit.addFloat;
    (id*20) + 1000.0 => float z => xmit.addFloat;
    id => xmit.addFloat;
    10::second => now;
  }
}
// infinite time loop

for (0 => int i; i< 10; i++)
{
  spork ~ a(i);// @=> Shred @s_a;
  10::second => now;
}
2::day => now;
