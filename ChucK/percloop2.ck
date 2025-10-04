
SndBuf percloop => NRev reverbL => dac.left;
SndBuf percloopR => NRev reverbR => dac.right;


0.0 => percloop.gain;
0.0 => percloopR.gain;
me.dir() + "/audio/percussionloop2stereo.wav" => percloop.read;
me.dir() + "/audio/percussionloop2stereo.wav" => percloopR.read;


0.007 => reverbL.mix;
0.008 => reverbR.mix;


0.094 :: second => dur tempo;
tempo => dur beat;
1 => float Mainrate;
Mainrate => percloop.rate;
Mainrate => percloopR.rate;


global int sliceChoice;
global float baseGain;


31 => sliceChoice;
0 => baseGain; 


MidiIn min;
7 => int port;

if (!min.open(port))
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg;


spork ~ handleMidiInput2();


fun void handleMidiInput2()
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
                
                
                if (controller == 53)
                {
                    // Map the value (0-127) to a slice choice range (0 - 31)
                    (value / 127.0) * 31 => float tempSliceChoice;
                    tempSliceChoice $ int => sliceChoice;  
                }
                
                
                if (controller == 81)
                {
                    
                    value / 127.0 => baseGain;
                }
            }
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
    tempo * 4 => lfo.period; // LFO period is one beat
    while (true)
    {
        
        0.7 * (1.0 - lfo.last()) => float lfoValue; 
        (baseGain * lfoValue) => percloop.gain;
        (baseGain * lfoValue) => percloopR.gain;
        0.01 :: second => now; 
    }
}


spork ~ volumeLFO();

while (true)
{
    cutBreak(sliceChoice, 2 * beat);
    cutBreak(sliceChoice, 2 * beat);
    cutBreak(sliceChoice, 4 * beat);
    cutBreak(sliceChoice, 2 * beat);
    cutBreak(sliceChoice, 2 * beat);
    cutBreak(sliceChoice, 2 * beat);
    cutBreak(sliceChoice, 2 * beat);
}

