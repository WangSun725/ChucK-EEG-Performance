// Chord Setup
SndBuf chord1 => Pan2 pan1 => dac;
SndBuf chord2 => Pan2 pan2 => dac;
SndBuf chord3 => Pan2 pan3 => dac;


me.dir() + "/audio/chord1.wav" => chord1.read;
me.dir() + "/audio/chord2.wav" => chord2.read;
me.dir() + "/audio/chord3.wav" => chord3.read;


0.5 => chord1.gain;
0.5 => chord2.gain;
0.5 => chord3.gain;


0.094 :: second => dur tempo;

-0.5 => pan1.pan; // Slightly left
0.0 => pan2.pan;  // Center
0.5 => pan3.pan;  // Slightly right
0.0 => float arpGain;
chord1.gain(arpGain);
chord2.gain(arpGain);
chord3.gain(arpGain);
MidiIn min;
7 => int port;

if( !min.open(port) )
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg;
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
                
                  if (controller == 78) {
                     value / 127.0 => arpGain;
                    
                    arpGain => chord1.gain;
                    arpGain => chord2.gain;
                    arpGain => chord3.gain;
                    

                    
                }
            }
        }
    }
}



while (true) {

    0 => chord1.pos;
    8 * tempo => now; 
    

    0 => chord2.pos; 
    8 * tempo => now; 
    

    0 => chord3.pos; 
    12 * tempo => now; 
    
    0 => chord3.pos; 
    4 * tempo => now; 
}
