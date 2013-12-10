//Connects class that triggers pitches for the SubSynth

TrigTest trig;
SubSynth syn;
syn.init();

spork ~ pitchLoop();
spork ~ gateOnLoop();
spork ~ gateOffLoop();

while(samp=>now);

//Functions
fun void pitchLoop(){
    while(trig.pitch => now){
        syn.pitchIt(trig.pitch.f);
        <<<trig.pitch.f>>>;
    }
}

fun void gateOnLoop(){
    while(trig.gateOn => now) syn.gateOn();
}

fun void gateOffLoop(){
    while(trig.gateOff => now) syn.gateOff();
}