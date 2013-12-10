//Trigger test for subsynth
public class TrigTest{
    DataEvent pitch, gateOn, gateOff;
    1.0 => gateOn.f;
    1.0 => gateOff.f;
    float t;
    .18 => t;
    spork ~ play();
    300::ms => dur gateTime;
    int gated;
    
    //Functions
    
    fun void gateIt(){
        gateTime => now;
        gateOff.broadcast();
        0 => gated;
    }
    
    fun void play(){
        while(true){ step(43, 0);
            step(48, 0);
            step(45, 0);
            step(49, 1);
            step(48,0);
            step(46,0);
            step(45,0);
            step(44,0);
            step(43,0);
            step(47,0);
            //step(45,0);
            step(43,0);
            step(32,0);
            step(34,1);
            step(36,1);
            step(0,1);
            step(0,1);
            
        }
    }
    
    /*
            step(43, 0);
            step(48, 0);
            step(45, 0);
            step(49, 1);
            step(0, 1);
            step(0,1);
            step(43, 0);
            step(48, 0);
            step(45, 0);
            step(49, 1);
            step(0, 1);
            step(0,1);
            step(43, 0);
            step(48, 0);
            step(45, 0);
            step(49, 1);
            step(0, 1);
            step(0,1);
            step(43, 0);
            step(48, 0);
            step(45, 0);
            step(49, 0);
            step(51, 0);
            step(49,0);
            */
    
    
    fun void step(float p, int tie){
        if(!tie){ 
            spork ~ gateIt();
        }
        if(p>0){
            if(!gated){ 
                gateOn.broadcast();
                1 => gated;
            }
            p => pitch.f;
            pitch.broadcast();
        }
        t::second => now;
    }
}
