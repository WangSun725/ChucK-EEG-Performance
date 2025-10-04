SndBuf kick => Gain kickvolume;
SndBuf snare => Gain snarevolume;
SndBuf snareside => Gain snaresidevolume;
SndBuf hihat => Gain hihatvolume;
Gain drumfull => dac;

kickvolume => drumfull;
snarevolume => drumfull;
snaresidevolume => drumfull;
hihatvolume => drumfull;

MidiIn min;
7 => int port;

if( !min.open(port) )
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg;

me.dir()+"/audio/kick4 mono.wav" => kick.read;
me.dir()+"/audio/snare mono1.wav" => snare.read;
me.dir()+"/audio/snareside2.wav" => snareside.read;
me.dir()+"/audio/hat mono3.wav" => hihat.read;


0.094 :: second => dur tempo; 
0.4 => kickvolume.gain;
0.45 => snarevolume.gain;
0.15 => hihatvolume.gain;
0.25 => snaresidevolume.gain;
0 => drumfull.gain;

[1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,
 0,0,1,0,0,0,0,0,0,0,1,0,0,0,1,0] @=> int kickHits[];
[0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,
 0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0] @=> int snareHits[];
[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,
 1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0] @=> int hihatHits[];
[0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0] @=> int snaresideHits[];

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
                
                 if (controller == 84) {
                   
                    value / 127.0 => drumfull.gain;
                }
            }
        }
    }
}

0.01 :: second => now;
while (true)
{
    0 => int beat;
    while (beat < kickHits.cap())
    {
    
        if (kickHits[beat])
        {
            0 => kick.pos;
        }
        if (snareHits[beat])
        {
            0 => snare.pos;
        }
        if (snaresideHits[beat])
        {
            0 => snareside.pos;
        }
        if (hihatHits[beat])
        {
            (beat % 4 < 2 ? hihatHighVolume : hihatLowVolume) => hihatvolume.gain;
            0 => hihat.pos;
        }
        tempo => now;
        beat++;
    }  
    
}

