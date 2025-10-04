// Set up the SawOsc and other UGens for the primary bass sound
SawOsc osc1 => LPF filter1 => ADSR env1 => Gain gain1 => dac;
SinOsc lfo1 => blackhole;  // Use a sine wave as LFO for the wobble effect

// Set up the SquareOsc and other UGens for the secondary layer
SqrOsc osc2 => LPF filter2 => ADSR env2 => Gain gain2 => dac;
SinOsc lfo2 => blackhole;  // Use a sine wave as LFO for the wobble effect

// Set initial parameters for primary sound
0.5 => osc1.gain;      // Set initial oscillator gain
100 => filter1.freq;   // Set initial filter frequency
0.5 => filter1.Q;      // Set filter resonance
2.65 => lfo1.freq;     // Set LFO frequency for wobble
0.0 => gain1.gain;     // Initial gain set to 0, will be controlled by MIDI

// Set initial parameters for secondary layer
0.3 => osc2.gain;      // Set initial oscillator gain
150 => filter2.freq;   // Set initial filter frequency
0.7 => filter2.Q;      // Set filter resonance
2.65 => lfo2.freq;     // Set LFO frequency for wobble
0.0 => gain2.gain;     // Initial gain set to 0, will be controlled by MIDI

// Set up ADSR envelopes
0.01::second => env1.attackTime;
0.13::second => env1.decayTime;
0.0 => env1.sustainLevel;
0.1::second => env1.releaseTime;

0.01::second => env2.attackTime;
0.15::second => env2.decayTime;
0.0 => env2.sustainLevel;
0.1::second => env2.releaseTime;

// MIDI setup
MidiIn min;
7 => int port;

if (!min.open(port))
{
    <<< "Error: MIDI port did not open on port: ", port >>>;
    me.exit();
}

MidiMsg msg;

// Spork the function to handle MIDI input
spork ~ handleMidiInput();
// Spork the function to read serial data
spork ~ readSerialData();

// Function to handle MIDI input
fun void handleMidiInput() {
    while (true) {
        // Wait on the event 'min'
        min => now;
        
        // Get the message(s)
        while (min.recv(msg)) {
            // Print out MIDI message for debugging
            <<< msg.data1, msg.data2, msg.data3 >>>;
            
            // If it's a Control Change message (status byte 176-191)
            if (msg.data1 >= 176 && msg.data1 <= 191) {
                // Control change message with controller number and value
                int controller;
                int value;
                msg.data2 => controller;
                msg.data3 => value;
                
                // Assume the fader is sending CC 83 (volume control)
                if (controller == 83) {
                    // Map the value (0-127) to a gain range (0.0 - 1.0)
                    value / 127.0 => float volume;
                    volume => gain1.gain;
                    volume => gain2.gain;
                    <<< "Volume set to:", gain1.gain(), gain2.gain() >>>;
                }
            }
        }
    }
}

// Function to read data from the serial port and update LFO frequencies
fun void readSerialData() {
    0 => int device;
    if( me.args() ) me.arg(0) => Std.atoi => device;
    SerialIO cereal;
    if (!cereal.open(device, SerialIO.B9600, SerialIO.BINARY)) {
        <<< "Error: Unable to open serial port" >>>;
        me.exit();
    }
    else {
        <<< "Serial device", device, "opened successfully." >>>;
    }
    
    while (true) {
        // Read an integer value from the serial port
        cereal.onInts(1) => now;
        cereal.getInts() @=> int i[];
        if (i.size() > 0) {
            i[0] & 0xFF => int attention; // Ensure we get the lower 8 bits
            <<< "Attention: ", attention >>>;
            
            // Map the attention value (0-100) to the LFO frequency range (0-5 Hz)
            (attention / 100.0) * 5.0 => float lfoFreq;
            
            // Apply the mapped value to the LFO frequencies
            lfoFreq => lfo1.freq;
            lfoFreq => lfo2.freq;
            
            // Print the received data and the LFO frequencies for debugging
            <<< "LFO Frequency: ", lfoFreq >>>;
        }
    }
}

// Function to modulate the filter cutoff frequency with the LFO for the wobble effect (primary sound)
fun void modulateFilter1() {
    while (true) {
        // Calculate LFO value (0.0 to 1.0) and modulate the filter frequency
        100 + 400 * (lfo1.last() + 1.0) => filter1.freq;
        1::samp => now;
    }
}

// Function to modulate the filter cutoff frequency with the LFO for the wobble effect (secondary layer)
fun void modulateFilter2() {
    while (true) {
        // Calculate LFO value (0.0 to 1.0) and modulate the filter frequency
        150 + 350 * (lfo2.last() + 1.0) => filter2.freq;
        1::samp => now;
    }
}

// Start the modulation functions in separate shreds
spork ~ modulateFilter1();
spork ~ modulateFilter2();

// Define the tempo
0.094 :: second => dur tempo;

// Function to play a note for a given duration
fun void playNoteAtMIDI(int midiNote, dur duration) {
    Std.mtof(midiNote) => osc1.freq;
    Std.mtof(midiNote) => osc2.freq;
    env1.keyOn();  // Trigger the ADSR envelope
    env2.keyOn();  // Trigger the ADSR envelope
    duration => now;
    env1.keyOff(); // Release the ADSR envelope
    env2.keyOff(); // Release the ADSR envelope
}

// Infinite loop to play the notes in sequence
while (true) {
    // E1 for 16 * tempo
    playNoteAtMIDI(33, 2 * tempo);
    playNoteAtMIDI(33, 2 * tempo); 
    playNoteAtMIDI(33, 2 * tempo); 
    playNoteAtMIDI(33, 2 * tempo);   // A1 for 16 * tempo
    playNoteAtMIDI(35, 2 * tempo);
    playNoteAtMIDI(35, 2 * tempo);
    playNoteAtMIDI(35, 2 * tempo);
    playNoteAtMIDI(35, 2 * tempo);
    playNoteAtMIDI(28, 2 * tempo);
    playNoteAtMIDI(28, 2 * tempo);
    playNoteAtMIDI(28, 2 * tempo);
    playNoteAtMIDI(28, 2 * tempo);
    playNoteAtMIDI(28, 2 * tempo);
    playNoteAtMIDI(28, 2 * tempo);
    playNoteAtMIDI(28, 2 * tempo);
    playNoteAtMIDI(28, 2 * tempo);
   // B1 for 32 * tempo
}

