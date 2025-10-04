SerialIO.list() @=> string list[];

for( int i; i < list.size(); i++ )
{
    chout <= i <= ": " <= list[i] <= IO.newline();
}

2 => int device;
if( me.args() ) me.arg(0) => Std.atoi => device;

SerialIO cereal;

if(!cereal.open( device, SerialIO.B9600, SerialIO.BINARY )) {
    <<< "Error: Unable to open serial device", device >>>;
    me.exit();
}
else {
    <<< "Serial device", device, "opened successfully." >>>;
}


while( true )
{

    cereal.onInts(1) => now;

    cereal.getInts() @=> int i[];

    if( i.size() > 0 ) {
        i[0] & 0xFF => int attention; 
                <<< "Attention: ", attention >>>;
    }
}

