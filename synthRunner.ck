//Connects class that triggers pitches for the SubSynth

TrigTest trig;
SubSynth syn;
syn.init();

spork ~ pitchLoop();
spork ~ gateLoop();

while(samp=>now);

//Functions
fun void pitchLoop(){
    while(trig.pitch => now) syn.pitchIt(trig.pitch.f);
}

fun void gateLoop(){
    while(trig.gate => now) syn.gateIt();
}