//2 oscillators (oct/semitone/cent tuning)
//Oscillator Mixer 
//4 waveforms (sqr/saw bandlimited w/ adj harmonics)
//Portomento
//One filter (selectable LP, HP, Rez)
//Keyboard tracking
//AD for filter
//AD for amplitude
//OSC addressable (listens on port 12001)
//all synth parameter functions take 0.0-1.0
//Uses pitch and trig dataEvents to trigger notes
//
//By Bruce Lott & Mark Morris
//July/August 2013

public class SubSynth{
    //----------------Ugens----------------\\
    //Oscillators
    BlitSquare sqr[2]; BlitSaw saw[2];
    SinOsc sin[2];     TriOsc tri[2];
    Noise noi;
    //Waveshapers
    Osc ws[4];
    SqrOsc sqrWs @=> ws[0];  SawOsc sawWs @=> ws[1];
    SinOsc sinWs @=> ws[2];  TriOsc triWs @=> ws[3];
    //Busses
    Gain mix[2];
    Gain preWs, paraWs, postWs, preFilt, postFilt;
    Pan2 mstBus;
    //Envelopes
    ADSR ampEnv, filtEnv, noiEnv;
    //Filters
    FilterBasic filts[3];
    LPF lp @=> filts[0];  
    HPF hp @=> filts[1];  
    ResonZ rez @=> filts[2];
    //KasFilter kf; //3
    //Limiters
    Dyno limit1, limit2;
    
    //Objects
    DLP porto[2];
    Foldback fold;
    
    //Variables
    int cFilt, cWShaper;
    int cWForm[2]; 
    float cPitch, cut, track, fEnvAmt, portoAmt, oMix, wsMix;
    int oct[2]; int coarse[2]; float fine[2]; 
    OscRecv orec;
    
    //--------------------------------Initializer--------------------------------\\
    fun void init(){
        //Signal Routing
        for(int i; i<2; i++){
            sqr[i] => mix[i];   saw[i] => mix[i];  //waveforms to mixer
            sin[i] => mix[i];   tri[i] => mix[i];
            
            mix[i] => paraWs;    mix[i] => preWs;  //mixer to waveshaper busses
        }
        
        for(int i; i<ws.cap(); i++) preWs => ws[i]; 
        //shapers to postWs handled by waveshape()
        postWs => ampEnv; paraWs => ampEnv;
        
        ampEnv => preFilt;    
        noi => noiEnv => preFilt; //noise skips ampEnv (has its own)
        
        for(int i; i<filts.cap(); i++){
            preFilt => filts[i];    
        }                        //filts to postfil handled by filerType()
        
        postFilt => limit1 => fold => mstBus => limit2 => dac;
        
        filtEnv => blackhole;
        
        //Defaults
        for(int i; i<2 ; i++){ 
            waveform(i,0);
            porto[i].go(); //.init?
            200 => porto[i].freq;
        }
        for(int i; i<ws.cap(); i++) ws[i].sync(1);
        ampEnv.set  (20::ms,200::ms,0,0::ms);
        filtEnv.set (20::ms,200::ms,0,0::ms);
        noiEnv.set  (20::ms,200::ms,0,0::ms);
        waveshaper(0);
        filtType(0);
        noi.gain(0);
        waveshaperMix(0);
        oscMix(0);
        cutoff(1);
        .5 => postFilt.gain;
        limit1.limit();
        limit2.limit();
        1 => fold.thresh;
        .6 => fold.index;
        
        //------------------------------Sporks------------------------------\\
        //OSC
        12001 => orec.port;
        orec.listen();
        spork ~ waveformOSC();
        spork ~ oscMixOSC();
        spork ~ coarseTuneOSC(); spork ~ fineTuneOSC(); spork ~ octaveTuneOSC(); //tuning
        spork ~ harmonicsOSC();
        spork ~ waveshaperOSC(); spork ~ waveshaperMixOSC(); //waveshaping
        spork ~ ampAtkOSC();     spork ~ ampDecOSC(); //amp env
        spork ~ noiGainOSC();    spork ~ noiAtkOSC();   spork ~ noiDecOSC(); //noise
        spork ~ filtTypeOSC();   spork ~ cutoffOSC();   spork ~resonanceOSC(); //filter
        spork ~ filtEnvAmtOSC(); spork ~ filtAtkOSC();  spork ~ filtDecOSC(); //filter env
        spork ~ keyboTrackOSC();
        spork ~ portomentoOSC();
        spork ~ foldbackThreshOSC(); spork ~ foldbackIndexOSC();
        spork ~ panOSC();
        spork ~ mstGainOSC();            
        
        //Other
        spork ~ filtEnvLoop(); 
        spork ~ portoLoop();
    }
    
    //----------------------------FUNCTIONS-------------------------
    //Setters and Getters   
    //Oscillators
    fun int waveform(int os) { return cWForm[os]; }
    fun int waveform(int os, int wv){
        sqr[os] =< mix[os];   saw[os] =< mix[os];
        sin[os] =< mix[os];   tri[os] =< mix[os];
        if(wv==0) sqr[os] => mix[os];
        else if(wv==1) saw[os] => mix[os];
        else if(wv==2) sin[os] => mix[os];
        else if(wv==3) tri[os] => mix[os];
        wv => cWForm[os];
        return cWForm[os];
    }
    
    fun float oscMix(){ return oMix; }
    fun float oscMix(float m){
        sanityCheck(m) => oMix;
        crossfade(mix[0], mix[1], oMix);
        return oMix;
    }      
    
    fun int coarseTune(int os){ return coarse[os]; }
    fun int coarseTune(int os, float c){
        (sanityCheck(c)*24 - 12) $ int => coarse[os]; //convert to semitones
        pitchIt(cPitch);
        return coarse[os];
    }
    
    fun float fineTune(int os){ return fine[os]; }
    fun float fineTune(int os, float f){
        sanityCheck(f) - 0.5 => fine[os]; //convert to cents
        pitchIt(cPitch);
        return fine[os];
    }
    
    fun int octaveTune(int os){ return oct[os]; }
    fun int octaveTune(int os, float o){
        (sanityCheck(o)*10 - 5) $ int => oct[os];  //convert to # octaves
        pitchIt(cPitch);
        return oct[os];
    }
    
    fun int harmonics(int os) { return sqr[os].harmonics(); }
    fun int harmonics(int os, float h){
        if(os>=0 & os<2){
            (sanityCheck(h)*100) $ int => sqr[os].harmonics => saw[os].harmonics;
        }
        return sqr[os].harmonics();
    }
    
    //Waveshaper
    fun int waveshaper() { return cWShaper; }
    fun int waveshaper(int s){
        if(s>=0 & s<ws.cap()){
            for(int i; i<ws.cap(); i++) ws[i] =< postWs;
            ws[s] => postWs;
            s => cWShaper;
        }
        return cWShaper;
    }    
    
    fun float waveshaperMix() { return wsMix; }
    fun float waveshaperMix(float m){
        sanityCheck(m) => wsMix;
        crossfade(paraWs, postWs, wsMix);
        return wsMix;
    }
    
    //Amplitude Envelope
    fun dur ampAtk() { return ampEnv.attackTime(); }    
    fun dur ampAtk(float a){
        calcEnvTime(sanityCheck(a)) => ampEnv.attackTime;
        return ampEnv.attackTime();
    }
    
    fun dur ampDec() { return ampEnv.decayTime(); }
    fun dur ampDec(float d){
        calcEnvTime(sanityCheck(d)) => ampEnv.decayTime;
        return ampEnv.decayTime();
    }    
    
    //Noise Section
    fun float noiGain() { return noi.gain(); }
    fun float noiGain(float g){
        sanityCheck(g)*0.5 => noi.gain;
    }    
    
    fun dur noiAtk() { return noiEnv.attackTime(); }    
    fun dur noiAtk(float a){
        calcEnvTime(sanityCheck(a)) => noiEnv.attackTime;
        return noiEnv.attackTime();
    }
    
    fun dur noiDec() { return noiEnv.decayTime(); }
    fun dur noiDec(float d){
        calcEnvTime(sanityCheck(d)) => noiEnv.decayTime;
        return noiEnv.decayTime();
    }
    
    //Filter    
    fun int filtType() { return cFilt; }
    fun int filtType(int fs){
        if(fs>=0 & fs<filts.cap()){
            for(int i; i<filts.cap(); i++) filts[i] =< postFilt;
            filts[fs] => postFilt;
            fs => cFilt;
        }
        return cFilt;
    }
    
    fun float cutoff(){ return cut; }
    fun float cutoff(float c){
        Math.pow(sanityCheck(c),2)*19980 + 20 => cut;
        return cut;
    }
    
    fun float resonance(){ return filts[0].Q(); }
    fun float resonance(float r){
        sanityCheck(r)*11 + 1 => r;
        for(int i; i<filts.cap(); i++){
            r => filts[i].Q;
        }
        return filts[0].Q();
    }
    
    fun float filtEnvAmt() { return fEnvAmt; }
    fun float filtEnvAmt(float a) {
        sanityCheck(a) => fEnvAmt;
        return fEnvAmt;
    }
    
    fun dur filtAtk() { return filtEnv.attackTime(); }    
    fun dur filtAtk(float a){
        calcEnvTime(sanityCheck(a)) => filtEnv.attackTime;
        return filtEnv.attackTime();
    }
    
    fun dur filtDec() { return filtEnv.decayTime(); }
    fun dur filtDec(float d){
        calcEnvTime(sanityCheck(d)) => filtEnv.decayTime;
        return filtEnv.decayTime();
    }
    
    fun float keyboTrack() { return track; }
    fun float keyboTrack(float k){
        sanityCheck(k) => track;
        return track;
    }
    
    //End Stage
    fun float portomento(){ return portoAmt; }
    fun float portomento(float p){
        sanityCheck(p) => portoAmt;
        Math.pow(1 - portoAmt, 2)*150 + 5 => p;
        for(int i; i<2; i++) p => porto[i].freq;
        return portoAmt;
    }
    
    fun float foldbackThresh() { return fold.thresh; }
    fun float foldbackThresh(float t){
        sanityCheck(t) + .01 => fold.thresh;
        return fold.thresh;
    }   
    
    fun float foldbackIndex() { return fold.index; }
    fun float foldbackIndex(float ind){
        sanityCheck(ind)*4 + 0.6 => fold.index;
        return fold.index;
    }
    
    fun float pan(){ return mstBus.pan(); }
    fun float pan(float p){
        sanityCheck(p)*2 - 1 => mstBus.pan;
    }
    
    fun float mstGain() { return mstBus.gain(); }
    fun float mstGain(float g){
        sanityCheck(g) => mstBus.gain;
        return mstBus.gain();
    }
    
    //Synth Triggers
    fun void pitchIt(float p){
        p => cPitch;
        for(int i; i<2; i++){
            Std.mtof(cPitch + coarse[i] + fine[i] + oct[i]*12) => porto[i].data;
        }
    }
    
    fun void trigIt(){
        filtEnv.keyOff();
        ampEnv.keyOff();
        noiEnv.keyOff();
        
        ampEnv.keyOn();
        filtEnv.keyOn();
        noiEnv.keyOn();
        //<<<cPitch>>>;
    }
    
    fun void keyOn(){
        ampEnv.keyOn();
        filtEnv.keyOn();
        noiEnv.keyOn();
    }
    
    fun void keyOff(){
        filtEnv.keyOff();
        ampEnv.keyOff();
        noiEnv.keyOff();
    }
    
    //Utility Functions
    fun void crossfade(UGen one, UGen two, float m){
        sanityCheck(m) => m;
        Math.cos(m*pi)*0.5 + 0.5 => one.gain;
        Math.cos((m+1)*pi)*0.5 + 0.5 => two.gain;
    }
    
    fun dur calcEnvTime(float l){
        return Math.pow(l,2)*4999.99::ms + 0.01::ms;
    }
    
    
    fun float sanityCheck(float f){
        if(f<0) return 0.0;
        else if(f>1) return 1.0;
        else return f;
    }
    
    //------------------------------OSC Loops--------------------------------\\
    //Oscillators    
    fun void waveformOSC(){
        orec.event("/wf, i, i") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                waveform(ev.getInt(), ev.getInt());
            }
        }
    }
    
    fun void oscMixOSC(){
        orec.event("/omix, f") @=> OscEvent ev;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                oscMix(ev.getFloat());
            }
        }
    }
    
    fun void coarseTuneOSC(){ //i = osc, f = coarse pitch
        orec.event("/cors, i, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                coarseTune(ev.getInt(), ev.getFloat());
            }
        }
    }
    
    fun void fineTuneOSC(){ //i = osc, f = coarse pitch
        orec.event("/fine, i, f") @=> OscEvent ev;
        int i;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                fineTune(ev.getInt(), ev.getFloat());
            }
        }
    } 
    
    fun void octaveTuneOSC(){ //i = osc, f = coarse pitch
        orec.event("/oct, i, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                octaveTune(ev.getInt(), ev.getFloat());
            }
        }
    }
    
    fun void harmonicsOSC(){
        orec.event("/harm, i, f") @=> OscEvent ev;  
        while(ev=>now){
            while(ev.nextMsg() != 0){
                harmonics(ev.getInt(), ev.getFloat());
            }
        }
    }
    
    //Waveshaper
    fun void waveshaperOSC(){
        orec.event("/wssel, i") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                waveshaper(ev.getInt());
            }
        }
    }
    
    fun void waveshaperMixOSC(){
        orec.event("/wsmix, f") @=> OscEvent ev;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                waveshaperMix(ev.getFloat());
            }
        }
    }
    
    //Amplitude Envelope
    fun void ampAtkOSC(){
        orec.event("/aatk, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                ampAtk(ev.getFloat());
            }
        }
    }
    
    fun void ampDecOSC(){
        orec.event("/adec, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                ampDec(ev.getFloat());
            }
        }
    }
    
    //Noise Stage
    fun void noiGainOSC(){
        orec.event("/ngain, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                noiGain(ev.getFloat());
            }
        }
    }
    
    fun void noiAtkOSC(){
        orec.event("/natk, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                noiAtk(ev.getFloat());
            }
        }
    }
    
    fun void noiDecOSC(){
        orec.event("/ndec, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                noiDec(ev.getFloat());
            }
        }
    }
    
    //Filter    
    fun void filtTypeOSC(){
        orec.event("/fsel, i") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                filtType(ev.getInt());
            }
        }
    }
    
    fun void cutoffOSC(){
        orec.event("/cut, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                cutoff(ev.getFloat());
            }
        }
    }
    
    fun void resonanceOSC(){
        orec.event("/q, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                resonance(ev.getFloat());
            }
        }
    }
    
    fun void filtEnvAmtOSC(){
        orec.event("/feamt, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                filtEnvAmt(ev.getFloat());
            }
        }
    }    
    
    fun void filtAtkOSC(){
        orec.event("/fatk, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                filtAtk(ev.getFloat());
            }
        }
    }
    
    fun void filtDecOSC(){
        orec.event("/fdec, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                filtDec(ev.getFloat());
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
    
    //End Stage
    fun void portomentoOSC(){
        orec.event("/porto, f") @=> OscEvent ev;
        while(ev=>now){
            while(ev.nextMsg() != 0){
                portomento(ev.getFloat());
            }
        }
    }
    
    fun void foldbackThreshOSC(){
        orec.event("/fbt, f") @=> OscEvent ev;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                foldbackThresh(ev.getFloat());
            }
        }
    }    
    
    fun void foldbackIndexOSC(){
        orec.event("/fbi, f") @=> OscEvent ev;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                foldbackIndex(ev.getFloat());
            }
        }
    }
    
    fun void panOSC(){
        orec.event("/pan, f") @=> OscEvent ev;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                pan(ev.getFloat());
            }
        }
    }
    
    fun void mstGainOSC(){
        orec.event("/mgain, f") @=> OscEvent ev;
        while(ev=>now){ 
            while(ev.nextMsg() != 0){
                mstGain(ev.getFloat());
            }
        }
    }
    
    //-------------------------Other Loops-------------------------
    fun void filtEnvLoop(){
        float f;
        while(samp => now){
            Std.mtof(filtEnv.value() * (fEnvAmt*100) + Std.ftom(cut)+(track*cPitch)) => f;
            if(f>20000) 20000=>f;
            for(int i; i<filts.cap(); i++) f => filts[i].freq;
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
    
    fun void volumeLoop(){
        float l;
        while(20::ms => now){
            <<<"\n\n\n\n\n\n\n\n\n\n\n\n\n\n">>>;
            <<<"current:", Math.fabs(mstBus.last())>>>;
            if(mstBus.last() > l) mstBus.last() => l;
            <<<"peak:", l>>>;
        }
    }
    
}