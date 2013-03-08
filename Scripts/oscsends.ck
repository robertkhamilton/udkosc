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

fun void a(int id)
{
  while(true)
  {
    xmit.startMsg("/udkosc/script/playermove/teleport", "f, f, f, f" );

    id*100.0 => xmit.addFloat;
    0.0 => xmit.addFloat;
    2000.0 => xmit.addFloat;
    id => xmit.addFloat;
    
    //.5::second => dur d;
    //d*id + 2::second => now;
    
    2::second => now;
  }
}

// infinite time loop

for (0 => int i; i< 14; i++)
{
  spork ~ a(i);// @=> Shred @s_a;
  .2::second => now;
}
/*
spork ~ a(0);// @=> Shred @s_a;
.2::second => now;
spork ~ a(1);// @=> Shred @s_a;
.2::second => now;
spork ~ a(2);// @=> Shred @s_a;
.2::second => now;
spork ~ a(3);// @=> Shred @s_a;
*/
2::day => now;
/*
    // start the message...
    // the type string ',f' expects a single float argument
    xmit.startMsg( "/udkosc/script/playermove/teleport", "f, f, f, f" );

    // a message is kicked as soon as it is complete 
    // - type string is satisfied and bundles are closed
    //Math.random2f( .5, 2.0 ) => float temp => xmit.addFloat;
    
    0.0 => xmit.addFloat;
    0.0 => xmit.addFloat;
    2000.0 => xmit.addFloat;
    0.0 => xmit.addFloat;
    
//<<< "sent (via OSC):", temp >>>;

    // advance time
    2::second => now;
*/
//}
