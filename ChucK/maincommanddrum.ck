12.032 :: second => dur eightbar;
Machine.add(me.dir() + "/drum.ck") => int drumID;
eightbar => now;
Machine.remove(drumID);
Machine.add(me.dir() + "/drum2.ck") => int drum2ID;
eightbar => now;
Machine.remove(drum2ID);

eightbar => now;

Machine.add(me.dir() + "/drum2.ck") => int drum4ID;
eightbar => now;
Machine.remove(drum4ID);

