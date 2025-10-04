
SndBuf percloop => NRev reverbL => dac.left;
SndBuf percloopR => NRev reverbR => dac.right;


0.0 => percloop.gain;
0.0 => percloopR.gain;
me.dir() + "/audio/percussionloop1stereo.wav" => percloop.read;
me.dir() + "/audio/percussionloop1stereo.wav" => percloopR.read;


0.007 => reverbL.mix;
0.008 => reverbR.mix;


0.094 :: second => dur tempo;
tempo => dur beat;
1 => float Mainrate;
Mainrate => percloop.rate;
Mainrate => percloopR.rate;

// Set up MIDI input
MidiIn min;
7 => int port;

if (!min.open(port))
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg;

// Spork the function to handle MIDI input
spork ~ handleMidiInput();


global float baseGain;
global int attentionControlledBreak1;
global int attentionControlledBreak2;


0.0 => baseGain; 
16 => attentionControlledBreak1; 
12 => attentionControlledBreak2; 

fun void handleMidiInput()
{
    while (true)
    {

        min => now;
        

        while (min.recv(msg))
        {

            <<< msg.data1, msg.data2, msg.data3 >>>;
            

            if (msg.data1 == 184)
            {
      
                int controller;
                int value;
                msg.data2 => controller;
                msg.data3 => value;
                
                              if (controller == 81)
                {

                    value / 127.0 => baseGain;
                }
            }
        }
    }
}

fun void readSerialData() {
    2 => int device;
    if( me.args() ) me.arg(0) => Std.atoi => device;
    SerialIO cereal;
    if (!cereal.open(device, SerialIO.B9600, SerialIO.BINARY)) {
        <<< "Error: Unable to open serial port" >>>;
        me.exit();
    }
    else {
        <<< "Serial device", device, "opened successfully." >>>;
    }
    
    while (true) {

        cereal.onInts(1) => now;
        cereal.getInts() @=> int i[];
        if (i.size() > 0) {
            i[0] & 0xFF => float attention;
            <<< "Attention: ", attention >>>;             
            

            (attention / 100) * 31 => float attentionValueFloat; 
            
            <<< "attentionfloat: ", attentionValueFloat >>>;
            attentionValueFloat => Std.ftoi => int attentionValue;
            <<< "attentioncontrol: ", attentionValue >>>;
            

            attentionValue => attentionControlledBreak1;
            attentionValue => attentionControlledBreak2;
        }
    }
}

fun void cutBreak(int sliceChoice, dur duration)
{
    percloop.samples() / 32 => int slice;
    slice * sliceChoice => int position;
    percloop.pos(position);
    percloopR.pos(position);
    duration => now;
}


fun void volumeLFO()
{
    SqrOsc lfo => blackhole;
    tempo * 4 => lfo.period; 
    float lfoValue; 
    while (true)
    {

        0.5 + 0.6 * (1.0 - lfo.last()) => lfoValue; 
                (baseGain * lfoValue) => percloop.gain;
        (baseGain * lfoValue) => percloopR.gain;
        0.01 :: second => now; 
    }
}


spork ~ volumeLFO();

spork ~ readSerialData();


while (true)
{
    cutBreak(32, 4 * beat);
    cutBreak(32, 4 * beat);
    cutBreak(attentionControlledBreak1, 4 * beat); 
    cutBreak(32, 4 * beat);
    cutBreak(32, 4 * beat);
    cutBreak(attentionControlledBreak2, 4 * beat); 
    cutBreak(32, 4 * beat);
    cutBreak(32, 4 * beat);
}
