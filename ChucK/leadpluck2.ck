SndBuf plucke4 => Gain plucke4volume;
SndBuf pluckc5 => Gain pluckc5volume;
SndBuf pluckb4 => Gain pluckb4volume;
SndBuf pluckg4 => Gain pluckg4volume;
Gain pluckfull2 => dac;


plucke4volume => pluckfull2;
pluckc5volume => pluckfull2;
pluckb4volume => pluckfull2;
pluckg4volume => pluckfull2;

MidiIn min;
7 => int port;

if( !min.open(port) )
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg;

me.dir()+"/audio/pluckd5.wav" => plucke4.read;
me.dir()+"/audio/pluckc5.wav" => pluckc5.read;
me.dir()+"/audio/pluckb4.wav" => pluckb4.read;
me.dir()+"/audio/pluckfsharp4.wav" => pluckg4.read;





0.094 :: second => dur tempo; //the duration is 0.13s length about 160bpm

0.4 => plucke4volume.gain;
0.45 => pluckc5volume.gain;
0.15 => pluckb4volume.gain;
0.25 => pluckg4volume.gain;
0 => pluckfull2.gain;//drum overall gain controlled by midi




[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int e4Hits[];
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int c5Hits[];
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0] @=> int b4Hits[];
[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,1] @=> int g4Hits[];

0.15 => float hihatHighVolume;
0.02 => float hihatLowVolume;


spork ~ handleMidiInput();

fun void handleMidiInput() {
    while (true) {

        min => now;
        

        while (min.recv(msg)) {

            <<< msg.data1, msg.data2, msg.data3 >>>;
            

            if (msg.data1 == 184) {

                int controller;
                int value;
                msg.data2 => controller;
                msg.data3 => value;
                
                 if (controller == 50) {
                      value / 23.0 => pluckfull2.gain;
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