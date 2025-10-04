SndBuf plucke4 => Gain plucke4volume;
SndBuf pluckc5 => Gain pluckc5volume;
SndBuf pluckb4 => Gain pluckb4volume;
SndBuf pluckg4 => Gain pluckg4volume;
Gain pluckfull => dac;


plucke4volume => pluckfull;
pluckc5volume => pluckfull;
pluckb4volume => pluckfull;
pluckg4volume => pluckfull;

MidiIn min;
7 => int port;

if( !min.open(port) )
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg;

me.dir()+"/audio/plucke4.wav" => plucke4.read;
me.dir()+"/audio/pluckc5.wav" => pluckc5.read;
me.dir()+"/audio/pluckb4.wav" => pluckb4.read;
me.dir()+"/audio/pluckg4.wav" => pluckg4.read;





0.094 :: second => dur tempo; //the duration is 0.13s length about 160bpm

0.4 => plucke4volume.gain;
0.45 => pluckc5volume.gain;
0.15 => pluckb4volume.gain;
0.25 => pluckg4volume.gain;
0 => pluckfull.gain;//drum overall gain controlled by midi




[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int e4Hits[];
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int c5Hits[];
[0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int b4Hits[];
[0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int g4Hits[];

0.15 => float hihatHighVolume;
0.02 => float hihatLowVolume;


spork ~ handleMidiInput();

fun void handleMidiInput() {
    while (true) {
        // Wait on the event 'min'
        min => now;
        
        // Get the message(s)
        while (min.recv(msg)) {
            // Print out MIDI message for debugging
            <<< msg.data1, msg.data2, msg.data3 >>>;
            
            // If it's a Control Change message (status byte 176)
            if (msg.data1 == 184) {
                // Extract controller number and value
                int controller;
                int value;
                msg.data2 => controller;
                msg.data3 => value;
                
                // Check if the controller number is 20 (the knob you identified)
                if (controller == 49) {
                    // Map the value (0-127) to a gain range (0.0 - 1.0)
                    value / 23.0 => pluckfull.gain;
                }
            }
        }
    }
}





0.01 :: second => now;
while (true)
{
    0 => int beat;
    while (beat < e4Hits.cap())
    {
        // play kick drum based on array value
        if (e4Hits[beat])
        {
            0 => plucke4.pos;
        }
        if (c5Hits[beat])
        {
            0 => pluckc5.pos;
        }
        if (b4Hits[beat])
        {
            0 => pluckb4.pos;
        }
        if (g4Hits[beat])
        {
            0 => pluckg4.pos;
        }
        tempo => now;
        beat++;
    }
    
    
    
    
    
    
    
    
}
