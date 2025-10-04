
SndBuf2 perclooptex => NRev reverbLtex => Pan2 panL => dac.left;
SndBuf2 perclooptexR => NRev reverbRtex => Pan2 panR => dac.right;


0.0 => perclooptex.gain;
0.0 => perclooptexR.gain;
me.dir() + "/audio/fx3.wav" => perclooptex.read;
me.dir() + "/audio/fx3.wav" => perclooptexR.read;


0.007 => reverbLtex.mix;
0.015 => reverbRtex.mix;


0.094 :: second => dur tempo;
1 => float Mainrate;
Mainrate => perclooptex.rate;
Mainrate => perclooptexR.rate;


global float baseGain5;


0.0 => baseGain5; // Initial base gain


-0.4 => panL.pan; // Pan slightly left
0.4 => panR.pan;  // Pan slightly right


MidiIn min1;
7 => int port;

if (!min1.open(port))
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg1;


spork ~ handleMidiInputperctex();

// Function to handle MIDI input for volume control
fun void handleMidiInputperctex()
{
    while (true)
    {

        min1 => now;
        

        while (min1.recv(msg1))
        {
           
            <<< msg1.data1, msg1.data2, msg1.data3 >>>;
            
           
            if (msg1.data1 == 184)
            {
                // Extract controller number and value
                int controller;
                int value;
                msg1.data2 => controller;
                msg1.data3 => value;
              
                if (controller == 13)
                {
                                        
                     value / 100.0 => baseGain5;
                    
                    // Set gain for both channels
                    baseGain5 => perclooptex.gain;
                    baseGain5 => perclooptexR.gain;
                }
            }
        }
    }
}


while (true)
{
    
    0 => perclooptex.pos;
    0 => perclooptexR.pos;
    

    Math.random2f(0.2, 1.8) => perclooptex.rate;
    Math.random2f(0.2, 1.8) => perclooptexR.rate;
    

    Math.random2f(-1.0, 1.0) => float balance;
    (balance + 1) / 2.0 => float rightGain;
    1.0 - rightGain => float leftGain;
    leftGain => perclooptex.gain;
    rightGain => perclooptexR.gain;
    
 
    tempo * 128 => now;
}

