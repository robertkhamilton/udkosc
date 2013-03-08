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

fun void teleport(int id)
{
    xmit.startMsg("/udkosc/script/playermove/teleport", "f, f, f, f" );
    0.0 => float x => xmit.addFloat;
    0.0 => float y => xmit.addFloat;
    (id*20) + 1000.0 => float z => xmit.addFloat;
    id => xmit.addFloat;
    1::second => now;
}

fun void jump(int id, int t)
{
    xmit.startMsg("/udkosc/script/playermove/jump", "f, f");
    100.0 => float jump => xmit.addFloat;
    id => xmit.addFloat;
    t::second => now;
}

// infinite time loop
for (0 => int i; i< 10; i++)
{
  spork ~ teleport(i);// @=> Shred @s_a;
  4::second => now;
}

2::day => now;
