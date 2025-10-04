
SawOsc vibrato1 => PulseOsc viol1 => ADSR env1 => LPF lp1 => Pan2 pan1 => dac.left;
SawOsc vibrato2 => PulseOsc viol2 => ADSR env2 => LPF lp2 => Pan2 pan2 => dac.right;

// Set up the reverb effect
JCRev reverb => dac;
0.2 => reverb.mix; 
0.0 => pan1.gain; 
0.0 => pan2.gain; 


pan1 => reverb;
pan2 => reverb;

2 => viol1.sync;
2 => viol2.sync;

10.0 => vibrato1.freq;
26.0 => vibrato2.freq;

env1.set(0.0 :: second, 0.02 :: second, 0.0, 0.1 :: second);
env2.set(0.0 :: second, 0.01 :: second, 0.0, 0.1 :: second);

lp1.freq(2800.0);
lp2.freq(2000.0);

0.0235 :: second => dur tempo;

[36, 38, 40, 41, 43, 45, 47, 48, 50, 52, 53, 55, 57, 59, 60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79, 81, 83, 84, 86, 88, 89, 91, 93, 95, 96, 97, 99, 101, 102, 104, 106, 108] @=> int scale[];

// Declare the global variables
global float volume;
global int minNoteIndex;
global int maxNoteIndex;
global int attention;


0.0 => volume; 
0 => minNoteIndex;
scale.cap() - 1 => maxNoteIndex;

// Set up MIDI input
MidiIn min;
7 => int port;

if (!min.open(port))
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg;


spork ~ handleMidiInput();

spork ~ readSerialData();


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
                
                
                if (controller == 82)
                {
                    
                    value / 127.0 => volume;
                    
                    
                    volume => pan1.gain;
                    volume => pan2.gain;
                }
                
                
                if (controller == 54)
                {
                    
                    scale.cap() => int range;
                    (value / 127.0) * range => float indexRange;
                    minNoteIndex => maxNoteIndex;
                    maxNoteIndex + indexRange $ int => maxNoteIndex;
                    
                    
                    if (maxNoteIndex >= scale.cap())
                    {
                        scale.cap() - 1 => maxNoteIndex;
                    }
                }
            }
        }
    }
}


fun void readSerialData() {
    0 => int device;
    if( me.args() ) me.arg(0) => Std.atoi => device;
    SerialIO cereal;
    if (!cereal.open(device, SerialIO.B9600, SerialIO.BINARY)) {
        <<< "Error: Unable to open serial port" >>>;
        me.exit();
    }    
    while (true) {               
            cereal.onInts(1) => now;
            cereal.getInts() @=> int i[];
            if( i.size() > 0 ) {
                i[0] & 0xFF => int attention; 
                                <<< "Attention: ", attention >>>;
            }           
            (attention / 100.0) * 0.3 => float reverbMix;                     
            reverbMix => reverb.mix;                        
    }
}

while (true)
{
        for (0 => int j; j < 4; j++)
    {
        for (0 => int i; i < scale.cap(); i++)
        {
            
            Math.random2(minNoteIndex, maxNoteIndex) => int noteIndex;
            scale[noteIndex] => int note;
            
            Std.mtof(note) => viol1.freq;
            Std.mtof(note) => viol2.freq;
            
            1 => env1.keyOn;
            1 => env2.keyOn;
            tempo => now;  
            1 => env1.keyOff;
            1 => env2.keyOff;
            tempo => now;
        }
    }
}

