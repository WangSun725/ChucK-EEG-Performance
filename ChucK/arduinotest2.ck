SerialIO serial;


if (!serial.open("/dev/tty.usbmodem1301", 57600)) {
    <<< "Error: Unable to open serial port" >>>;
    me.exit();
}


string buffer;


fun void readSerialData() {
    while (true) {
        if (serial.available()) {

            serial.getLine() => buffer;
            
            
            <<< "Received:", buffer >>>;
            
            // Convert the string to an integer
            int sensorValue;
            buffer => Std.atoi => sensorValue;
            

            <<< "Sensor Value:", sensorValue >>>;
        }
        

        100::ms => now;
    }
}


spork ~ readSerialData();


while (true) {
    1::second => now;
}
