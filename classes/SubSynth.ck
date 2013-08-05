//2 oscillators (coarse/fine tuning)
//Mixer 
//2 waveforms
//Portomento
//One filter (selectable LP, HP, Rez)
//Keyboard tracking
//AD for filter
//AD for amplitude
//OSC addressable (listens on port 12001)

//Uses pitch and gate dataEvents to trigger notes

public class SubSynth{
    //Objects
    DLP porto[2];
    //Ugens
    BlitSquare sqr[2]; //waveform 0
    BlitSaw saw[2];    //1
    SinOsc sin[2];     //2
    TriOsc tri[2];     //3
    Noise noi;
    SqrOsc sqrWs; //waveshaper 0
    SawOsc sawWs; //1
    SinOsc sinWs; //2
    TriOsc triWs; //3
    Gain mix[2];
    Gain wsBus, dryBus, preWsBus;
    Pan2 mstBus;
    ADSR ampEnv, filtEnv, noiEnv;
    int cFilt, cShaper;
    int cWave[2];
    float coarse[2]; float fine[2]; float oct[2];
    //float fine[2];
    float cPitch; float tPitch[2]; //temp
    float q, cut, track, filtEnvAmt;
    LPF lp; //filter 0 
    HPF hp; //1
    ResonZ rez; //2
    //KasFilter kf;
    OscRecv orec;
    
    //------------Initializer--------------------------------
    fun void init(){
        //Signal Routing
        for(int i; i<2; i++){
            sqr[i] => mix[i];   saw[i] => mix[i]; //oscs to mixers
            sin[i] => mix[i];   tri[i] => mix[i];
            mix[i] => ampEnv;                   //mixers to amp env
        }
        noi => noiEnv;
        ampEnv => dryBus;    noiEnv => dryBus;
        ampEnv => preWsBus;  noiEnv => preWsBus;
        ampEnv => preWsBus;  noiEnv => preWsBus; 
        preWsBus => sqrWs => wsBus;   preWsBus => sawWs => wsBus; //envBus to waveshapers  
        preWsBus => sinWs => wsBus;   preWsBus => triWs => wsBus;
        sqrWs => wsBus; sawWs => wsBus; 
        sinWs => wsBus; triWs => wsBus; 
        wsBus => lp; wsBus => hp; wsBus => rez; //wsBus => kf;
        dryBus => lp; dryBus => hp; dryBus => rez; //dryBus => kf;
        lp => mstBus; hp => mstBus; rez => mstBus; //kf => mstBus;
        filtEnv => blackhole;
        mstBus => dac;
        
        //Defaults
        for(int i; i<2 ; i++){ 
            waveSel(i,0);
            porto[i].go(); //.init
            200 => porto[i].freq;
        }
        ampEnv.set (20::ms,200::ms,0,0::ms);
        filtEnv.set(20::ms,200::ms,0,0::ms);
        noiEnv.set(20::ms,200::ms,0,0::ms);
        noi.gain(0);
        filtSel(0);
        sqrWs.sync(1);  sawWs.sync(1); 
        sinWs.sync(1);  triWs.sync(1); 
        waveShapeSel(0);
        
        //OSC
        12001 => orec.port;
        orec.listen();
        spork ~ mstGainOSC();
        spork ~ oscMixOSC();
        spork ~ waveSelOSC();
        spork ~ waveShapeSelOSC(); spork ~ waveShapeMixOSC(); //waveshaping
        spork ~ coarseOSC(); spork ~ fineOSC(); spork ~ octOSC(); //tuning
        spork ~ portoLoop(); spork ~ portoOSC(); //porto
        spork ~ ampAtkOSC(); spork ~ ampDecOSC(); //amp env
        spork ~ filtSelOSC(); spork ~ filtCutOSC();  spork ~qOSC(); //filter
        spork ~ filtEnvAmtOSC(); spork ~ filtAtkOSC(); spork ~ filtDecOSC(); //filter env
        spork ~ filtEnvLoop(); 
        spork ~ keyboTrackOSC();
        spork ~ harmOSC();
        spork ~ noiGainOSC(); spork ~ noiAtkOSC(); spork ~ noiDecOSC(); //noise
    }
    
    //----------------------------FUNCTIONS-------------------------
    
    fun void waveShapeSel(int ws){
        sqrWs =< wsBus; sawWs =< wsBus; 
        sinWs =< wsBus; triWs =< wsBus;
        if(ws==0) sqrWs => wsBus;
        else if(ws==1) sawWs => wsBus;
        else if(ws==2) sinWs => wsBus;
        else if(ws==3) triWs => wsBus;
    }
    
    fun void harmonics(int os, int h){
        h => sqr[os].harmonics => saw[os].harmonics;
    }
    
    fun int filtSel() { return cFilt; }
    fun int filtSel(int fs){
        fs => cFilt;
        if(fs==0){ //selects lp
            lp  => mstBus;
            hp  =< mstBus;
            rez =< mstBus;
            //kf  =< mstBus;
            
        }
        else if(fs==1){ //selects hp
            lp  =< mstBus;
            hp  => mstBus;
            rez =< mstBus;
            //kf  =< mstBus;
        }
        else if(fs==2){ //selects rez
            lp  =< mstBus;
            hp  =< mstBus;
            rez => mstBus;
            //kf  =< mstBus; 
        } /*
        else if(fs==3){ //selects kf
            lp  =< mstBus;
            hp  =< mstBus;
            rez =< mstBus;
            kf  => mstBus; 
        } */
    }
    
    fun void waveSel(int os, int wv){
        sqr[os] =< mix[os];
        saw[os] =< mix[os];
        sin[os] =< mix[os];
        tri[os] =< mix[os];
        if(wv==0) sqr[os] => mix[os];
        else if(wv==1) saw[os] => mix[os];
        else if(wv==2) sin[os] => mix[os];
        else if(wv==3) tri[os] => mix[os];
        wv => cWave[os];
    }
    
    fun void pitchIt(float p){
        p => cPitch;
        for(int i; i<2; i++){
            cPitch + coarse[i] + fine[i] + (oct[i]*12) => tPitch[i];
            Std.mtof(tPitch[i]) => porto[i].data;
        }
    }
    
    fun void coarseUpdate(int os, float c){
        c=> coarse[os];
        pitchIt(cPitch);
    }
    
    fun void fineUpdate(int os, float f){
        f => fine[os];
        pitchIt(cPitch);
    }
    
    fun void octUpdate(int os, float f){
        f => oct[os];
        pitchIt(cPitch);
    }
    
    fun void gateIt(){
        filtEnv.keyOff();
        ampEnv.keyOff();
        noiEnv.keyOff();
        ampEnv.keyOn();
        filtEnv.keyOn();
        noiEnv.keyOn();
        //<<<cPitch>>>;
    }
    
    //------------------------------OSC loops-------------------------------- 
    //Waveshape
    fun void waveShapeSelOSC(){
        orec.event("/wssel, i") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                waveShapeSel(ev.getInt());
            }
        }
    }
    fun void waveShapeMixOSC(){
        orec.event("/wsmix, f") @=> OscEvent ev;
        float f;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                ev.getFloat() => f;
                Math.cos(f*pi)*0.5+0.5 => dryBus.gain; //PUT THIS IN A oscMix function
                Math.cos((f+1)*pi)*0.5+0.5 => preWsBus.gain;
            }
        }
    }
    
    //Filter
    fun void filtEnvAmtOSC(){
        orec.event("/feamt, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                <<<"filt env amt">>>;
                ev.getFloat() => filtEnvAmt;
            }
        }
    }    
    
    fun void filtAtkOSC(){
        orec.event("/fatk, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                Math.pow(ev.getFloat(),2) * 749::ms+ 1::ms => filtEnv.attackTime;
            }
        }
    }
    
    fun void filtDecOSC(){
        orec.event("/fdec, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                Math.pow(ev.getFloat(), 2) * 749::ms + 1::ms => filtEnv.decayTime;
            }
        }
    }
    fun void keyboTrackOSC(){
        orec.event("/trk, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                ev.getFloat() => track;
            }
        }
    } 
    
    fun void qOSC(){
        orec.event("/q, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                ev.getFloat() => q;
                //q => kf.resonance;
                q*11 + 1 => q;
                q => rez.Q => lp.Q => hp.Q;
            }
        }
    }
    
    fun void filtCutOSC(){
        orec.event("/cut, f") @=> OscEvent ev;
        float f;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                Math.pow(ev.getFloat(), 2) * 19980 + 20 => cut;
                cut => rez.freq => lp.freq => hp.freq; //=> kf.freq;
            }
        }
    }
    
    //Amplitude
    fun void mstGainOSC(){
        orec.event("/mgain, f") @=> OscEvent ev;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                ev.getFloat() => mstBus.gain;
            }
        }
    }
    
    fun void oscMixOSC(){
        orec.event("/omix, f") @=> OscEvent ev;
        float f;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                ev.getFloat() => f;
                Math.cos((f)*pi)*0.5+0.5 => mix[0].gain; //PUT THIS IN A oscMix function
                Math.cos((f+1)*pi)*0.5+0.5 => mix[1].gain;
            }
        }
    }
    
    fun void ampAtkOSC(){
        orec.event("/aatk, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                Math.pow(ev.getFloat(),2) * 749::ms+ 1::ms => ampEnv.attackTime;
            }
        }
    }
    
    fun void ampDecOSC(){
        orec.event("/adec, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                Math.pow(ev.getFloat(), 2) * 749::ms + 1::ms => ampEnv.decayTime;
            }
        }
    }
    //Noise
    fun void noiGainOSC(){
        orec.event("/ngain, f") @=> OscEvent ev;
        float f;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                ev.getFloat() => f;
                if(f>=0 | f<=1) f * 0.5 => noi.gain;
            }
        }
    }
    
    fun void noiAtkOSC(){
        orec.event("/natk, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                Math.pow(ev.getFloat(), 2) * 749::ms + 1::ms => noiEnv.attackTime;
            }
        }
    }
    
    fun void noiDecOSC(){
        orec.event("/ndec, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                Math.pow(ev.getFloat(), 2) * 749::ms + 1::ms => noiEnv.decayTime;
            }
        }
    }
    
    //Selectors
    fun void filtSelOSC(){
        orec.event("/fsel, i") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                filtSel(ev.getInt());
            }
        }
    }
    
    fun void waveSelOSC(){
        orec.event("/wf, i, i") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                waveSel(ev.getInt(), ev.getInt());
            }
        }
    }
    //Tuning
    fun void coarseOSC(){ //i = osc, f = coarse pitch
        orec.event("/cors, i, f") @=> OscEvent ev;
        int i;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                coarseUpdate(ev.getInt(), ev.getFloat());
            }
        }
    }
    
    fun void fineOSC(){
        orec.event("/fine, i, f") @=> OscEvent ev;
        int i;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                fineUpdate(ev.getInt(), ev.getFloat());
            }
        }
    } 
    
    fun void octOSC(){
        orec.event("/oct, i, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                octUpdate(ev.getInt(), ev.getFloat());
            }
        }
    }
    
    fun void portoOSC(){
        orec.event("/porto, f") @=> OscEvent ev;
        float f;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                Math.pow(1 - ev.getFloat(), 2) * 150 + 1 => f;
                for(int i; i<2; i++) f => porto[i].freq;
            }
        }
    }
    
    fun void harmOSC(){
        orec.event("/harm, i, i") @=> OscEvent ev;  
        int wf, h, l;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                ev.getInt() => wf;
                ev.getInt() => h;
                if(h != l) harmonics(wf,h);
                h => l;
            }
        }
    }
    
    //-------------------------Other Loops-------------------------
    fun void filtEnvLoop(){
        float f;
        while(samp => now){
            Std.mtof(filtEnv.value() * filtEnvAmt * 127 + Std.ftom(cut)+(track*cPitch)) => f;
            if(f>20000)20000=>f;
            f => rez.freq => lp.freq => hp.freq; // => kf.freq;
        }
    }
    
    fun void portoLoop(){
        while(samp => now){
            for(int i; i<2; i++){
                porto[i].val => sqr[i].freq;
                porto[i].val => saw[i].freq;
                porto[i].val => sin[i].freq;
                porto[i].val => tri[i].freq;
                
            }
        }
    }
}