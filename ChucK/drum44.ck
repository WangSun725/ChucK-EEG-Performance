SndBuf kick => Gain kickvolume;
Gain drumfull => dac;

kickvolume => drumfull;



me.dir() + "/audio/kicksoft1.wav" => kick.read;

0.094 :: second => dur tempo; // the duration is 0.13s length about 160bpm

0.4 => kickvolume.gain;
0 => drumfull.gain; // drum overall gain controlled by MIDI

[1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0,
 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0] @=> int kickHits[];
 
 
 MidiIn min;
 7 => int port;
 
 if( !min.open(port) )
 {
     <<< "Error: MIDI port did not open on port: ", port >>>;
     me.exit();
 }
 
 MidiMsg msg;

spork ~ handleMidiInput();

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

                if (controller == 79)
                {
                     value / 80.0 => drumfull.gain;
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
        tempo => now;
        beat++;
    }
}

