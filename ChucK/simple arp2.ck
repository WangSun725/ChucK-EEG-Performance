// Set up the PulseOsc and SawOsc UGens
SawOsc vibrato1 => SqrOsc viol1 => ADSR env1 => LPF lp1 => Pan2 pan1 => NRev reverb1 => dac.left;
SawOsc vibrato2 => SqrOsc viol2 => ADSR env2 => LPF lp2 => Pan2 pan2 => NRev reverb2 => dac.right;

MidiIn min;
7 => int port;

if( !min.open(port) )
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg;

2 => viol1.sync;
2 => viol2.sync;

10.0 => vibrato1.freq;
26.0 => vibrato2.freq;

env1.set(0.0 :: second, 0.14 :: second, 0.0, 0.1 :: second);
env2.set(0.0 :: second, 0.05 :: second, 0.0, 0.1 :: second);

0.0 => float arpGain;
viol1.gain(arpGain);
viol2.gain(arpGain);

lp1.freq(3100.0);
lp2.freq(3500.0);

0.047 :: second => dur tempo;

[60, 64, 67, 71] @=> int scale[];
[59, 64, 67, 71] @=> int scale2[];
[55, 59, 62, 66] @=> int scale3[];
[55, 59, 62, 66] @=> int scale4[];

// Set reverb parameters
0.5 => reverb1.mix;
0.5 => reverb2.mix;


spork ~ handleMidiInput();

// Function to handle MIDI input
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
                
                // Check if the controller number is 78 (the knob you identified)
                if (controller == 14) {
                    // Map the value (0-127) to a gain range (0.0 - 1.0)
                    value / 540.0 => arpGain;
                    
                    arpGain => viol1.gain;
                    arpGain => viol2.gain;
                    
                    // Apply the new gain to both Gain units
                }
            }
        }
    }
}

while (true)
{
    for (0 => int j; j < 2; j++)
    {
        for (0 => int i; i < scale.cap(); i++)
        {
            Std.mtof(scale[i]) => viol1.freq;
            Std.mtof(scale[i]) => viol2.freq;
            1 => env1.keyOn;
            1 => env2.keyOn;
            tempo => now;  
            1 => env1.keyOff;
            1 => env2.keyOff;
            tempo => now;
        }
    }
    for (0 => int j; j < 2; j++)
    {
        for (0 => int i; i < scale2.cap(); i++)
        {
            Std.mtof(scale2[i]) => viol1.freq;
            Std.mtof(scale2[i]) => viol2.freq;
            1 => env1.keyOn;
            1 => env2.keyOn;
            tempo => now;  
            1 => env1.keyOff;
            1 => env2.keyOff;
            tempo => now;
        }
    }
    for (0 => int j; j < 2; j++)
    {
        for (0 => int i; i < scale3.cap(); i++)
        {
            Std.mtof(scale3[i]) => viol1.freq;
            Std.mtof(scale3[i]) => viol2.freq;
            1 => env1.keyOn;
            1 => env2.keyOn;
            tempo => now;  
            1 => env1.keyOff;
            1 => env2.keyOff;
            tempo => now;
        }
    }
    for (0 => int j; j < 2; j++)
    {
        for (0 => int i; i < scale4.cap(); i++)
        {
            Std.mtof(scale4[i]) => viol1.freq;
            Std.mtof(scale4[i]) => viol2.freq;
            1 => env1.keyOn;
            1 => env2.keyOn;
            tempo => now;  
            1 => env1.keyOff;
            1 => env2.keyOff;
            tempo => now;
        }
    }
}
