
SndBuf percloop => JCRev reverb => Pan2 pan => dac;


0.0 => percloop.gain;
me.dir() + "/audio/rap1 stereo.wav" => percloop.read;


0.05 => reverb.mix;


0.094 :: second => dur tempo;
tempo => dur beat;
0.94 => float Mainrate;
Mainrate => percloop.rate;


MidiIn min;
7 => int port;

if (!min.open(port))
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
                
                 if (controller == 80)
                {
                     value / 127.0 => float gain;
                    

                    gain => percloop.gain;
                }
            }
        }
    }
}


function void cutBreak(int sliceChoice, dur duration)
{
    percloop.samples() / 32 => int slice;
    slice * sliceChoice => int position;
    percloop.pos(position);
    duration => now;
}


while (true)
{
    cutBreak(16, 4 * beat);
    cutBreak(32, 2 * beat);
    cutBreak(32, 2 * beat);
    cutBreak(12, 2 * beat);
    cutBreak(32, 1 * beat);
    cutBreak(31, 1 * beat);
    cutBreak(32, 2 * beat); // new
    cutBreak(32, 2 * beat);
    cutBreak(20, 4 * beat);
    cutBreak(32, 2 * beat);
    cutBreak(32, 2 * beat);
    cutBreak(12, 2 * beat);
    cutBreak(32, 2 * beat);
    cutBreak(32, 2 * beat);
    cutBreak(32, 2 * beat);
}
