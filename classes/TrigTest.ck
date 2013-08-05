//Trigger test for subsynth
public class TrigTest{
    DataEvent pitch, gate;
    1.0 => gate.f;
    float t;
    .7 => t;
    spork ~ play();
    
    //Functions
    fun void play(){
        while(true){
            43.0 => pitch.f;
            pitch.broadcast();
            gate.broadcast();
            t::second=>now;
            
            48 => pitch.f;
            pitch.broadcast();
            gate.broadcast();
            t::second=>now;
            
            46 => pitch.f;
            pitch.broadcast();
            gate.broadcast();
            t::second=>now;
        }
    }
}