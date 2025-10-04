
SndBuf2 perclooptex => LPF lpf => NRev reverb => Gain bal[2] => dac;


1.0 => perclooptex.gain;
me.dir() + "/audio/arploop2.wav" => perclooptex.read;


0.1 => reverb.mix; 



4000.0 => lpf.freq; 


0.094 :: second => dur tempo;
1 => float Mainrate;
Mainrate => perclooptex.rate;


global float baseGain3;


0.0 => baseGain3; 

MidiIn min1;
7 => int port;

if (!min1.open(port))
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg1;


spork ~ handleMidiInputperctex();


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
                
                int controller;
                int value;
                msg1.data2 => controller;
                msg1.data3 => value;
                
                
                if (controller == 29)
                {
                    
                    value / 80.0 => baseGain3;
                    

                    baseGain3 => bal[0].gain;
                    baseGain3 => bal[1].gain;
                }
            }
        }
    }
}


while (true)
{

    0 => perclooptex.pos;
    
    

    

    

    tempo * 32 => now;
}
