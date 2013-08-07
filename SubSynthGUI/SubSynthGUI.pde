  //LIBS
  import controlP5.*;
  import oscP5.*;
  import netP5.*;
  
  //OSC
  OscP5 oscP5;
  NetAddress myRemoteLocation;
  ControlP5 cP5;
  DropdownList wf0, wf1; //waveform selector
  DropdownList fs; //filter selector
  DropdownList ws; //wave shape sel
  Textlabel ae, ng; //amp env label
  
  void setup(){
    size(600,350);
    noStroke();
    cP5 = new ControlP5(this);
    //---------------OSCILLATOR SECTION---------------\\
    //OSCILLATOR MIXER
    cP5.addSlider("osc_mix")
    .setRange(0,1)
    .setValue(0)
    .setSize(110,20)
    .setPosition(10,10)
    .setSliderMode(0)
    ;
    //FINE TUNING 1
    cP5.addSlider("fine_1")
    .setCaptionLabel("fine") 
    .setRange(0,1)
    .setValue(.5)
    .setSize(20,100)
    .setPosition(100, 50)
    .setSliderMode(0)
    .setHandleSize(5)
    ;
    //COURSE TUNING 1
    cP5.addSlider("course_1")
    .setCaptionLabel("cors") 
    .setRange(0,1)
    .setValue(.5)
    .setSize(20,100)
    .setPosition(70, 50)
    .setSliderMode(0)
    .setNumberOfTickMarks(25)
    .showTickMarks(false)
    .setHandleSize(5)
    .setDecimalPrecision(0)
    .setValue(1); //sets val to 0?
    ;
    //FINE TUNING 0
    cP5.addSlider("fine_0")
    .setCaptionLabel("fine") 
    .setRange(0,1)
    .setValue(.5)
    .setSize(20,100)
    .setPosition(40, 50)
    .setSliderMode(0)
    .setHandleSize(5)
    ;
    //COURSE TUNING 0
    cP5.addSlider("course_0")
    .setCaptionLabel("cors") 
    .setRange(0,1)
    .setValue(.5)
    .setSize(20,100)
    .setPosition(10, 50)
    .setSliderMode(0)
    .setNumberOfTickMarks(25)
    .showTickMarks(false)
    .setHandleSize(5)
    .setDecimalPrecision(0)
    .setValue(1)
    ; 
     
    //HARMONICS 0
    cP5.addNumberbox("harm_0")
    .setLabel("hrm")
    .setRange(0,1)
    .setValue(0)
    .setMultiplier(0.01)
    .setSize(20,20)
    .setPosition(10, 170)
    ; 
    //HARMONICS 1
    cP5.addNumberbox("harm_1")
    .setLabel("hrm")
    .setRange(0,1)
    .setValue(0)
    .setMultiplier(0.01)
    .setSize(20,20)
    .setPosition(70, 170)
    ;     
    //OCTAVE 0
    cP5.addNumberbox("oct_0")
    .setLabel("oct")
    .setRange(0,1)
    .setValue(.5)
    .setMultiplier(0.01)
    .setSize(20,20)
    .setPosition(40, 170)
    ; 
    //OCTAVE 1
    cP5.addNumberbox("oct_1")
    .setLabel("oct")
    .setRange(0,1)
    .setValue(.5)
    .setMultiplier(0.01)
    .setSize(20,20)
    .setPosition(100, 170)
    ; 
    
    
    
    
    
    
    //AMPLITUDE ENVELOPE LABEL
    ae = cP5.addTextlabel("amp_env")
    .setText("AMP")
    .setPosition(151, 37)
    ;
    ng = cP5.addTextlabel("noise_label")
    .setText("NOISE")
    .setPosition(150,155)
    ;
    //FILTER CUTOFF 
    cP5.addSlider("cutoff")
    .setLabel("cut")
    .setSize(20,100)
    .setRange(0,1)
    .setPosition(230,50)
    ;
    //FILTER RESONANCE  
    cP5.addSlider("q")
    .setSize(20,100)
    .setRange(0,1)
    .setPosition(260,50)
    ;
    //FILTER AMOUNT
    cP5.addSlider("filt_env_amt")
    .setLabel("amt")
    .setSize(50,20)
    .setRange(0,1)
    .setPosition(320,25)
    ;
    //FILTER ATTACK
    cP5.addSlider("filt_atk")
    .setLabel("atk")
    .setSize(20,100)
    .setRange(0, 1)
    .setPosition(320,50)
    ;
    //FILTER DECAY  
    cP5.addSlider("filt_dec")
    .setLabel("dec")
    .setSize(20,100)
    .setRange(0,1)
    .setPosition(350,50)
    ;
    //FILTER KEYBOARD TRACKING  
    cP5.addSlider("keybo_track")
    .setLabel("trk")
    .setSize(20,100)
    .setRange(0,1)
    .setPosition(290,50)
    ;
    //PORTOMENTO
    cP5.addSlider("porto")
    .setRange(0,1)
    .setSize(20,100)
    .setPosition(520,50)
    ;
    //MASTER GAIN
    cP5.addSlider("mst_gain")
    .setRange(0,1)
    .setValue(0.7)
    .setSize(20,100)
    .setPosition(560, 50)
    ;
    //NOISE GAIN
    cP5.addSlider("noi_gain")
    .setLabel("gain")
    .setRange(0,1)
    .setSize(50,20)
    .setPosition(140, 170)
    ; 
    //AMPLITUDE ATTACK
    cP5.addSlider("amp_atk")
    .setLabel(" atk")
    .setSize(20,42)
    .setRange(0,1)
    .setPosition(140,50)
    ;
    //AMPLITUDE DECAY
    cP5.addSlider("amp_dec")
    .setLabel("  dec")
    .setSize(20,42)
    .setRange(0,1)
    .setPosition(170,50)
    ;
    //NOISE ATTACK
    cP5.addSlider("noi_atk")
    .setLabel("")
    .setSize(20,41)
    .setRange(0,1)
    .setPosition(140,109)
    ;
    //NOISE DECAY
    cP5.addSlider("noi_dec")
    .setLabel("")
    .setSize(20,41)
    .setRange(0,1)
    .setPosition(170,109)
    ;
    
    //NOISE DECAY
    cP5.addSlider("ws_mix")
    .setLabel("mix")
    .setSize(20,100)
    .setRange(0, 1)
    .setPosition(10,220)
    ;
    //------------------DROP DOWNS------------------\\
    //WAVEFORM SELECTOR 0
    wf0 = cP5.addDropdownList("wave_0")
    .setPosition(10, 45)
    .setWidth(50);
    wf0.addItem("square", 0);
    wf0.addItem("saw", 1);  
    wf0.addItem("sine", 2);
    wf0.addItem("tri", 3);  
    //WAVEFORM SELECTOR 1 
    wf1 = cP5.addDropdownList("wave_1")
    .setPosition(70, 45)
    .setWidth(50);
    wf1.addItem("square", 0);
    wf1.addItem("saw", 1);
    wf1.addItem("sine", 2);
    wf1.addItem("tri", 3);
    //WAVESHAPE SELECT
    ws = cP5.addDropdownList("ws_sel")
    .setLabel("shape")
    .setPosition(40,250)
    .setWidth(50);
    ws.addItem("sqr", 0);
    ws.addItem("saw", 1);
    ws.addItem("sin", 2);
    ws.addItem("tri", 3);
    //FILTER TYPE SELECTOR
    fs = cP5.addDropdownList("filt_sel")
    .setLabel("filter")
    .setPosition(230, 45)
    .setWidth(50);
    fs.addItem("lp", 0);
    fs.addItem("hp", 1);
    fs.addItem("rez", 2);
    //fs.addItem("kf", 3);
    
    //OSC
    oscP5 = new OscP5(this, 12000);
    myRemoteLocation = new NetAddress("localHost", 12001); 
  }
  
  void draw(){ background(1); }  
  
  //FUNCTIONS
  String floatPrecision(String s, int p){
    int l = 0;
    for(int i = 0; i<s.length(); i++){
      if(s.charAt(i) == '.'){ 
        l = i+p+1;
        if(l>s.length()) l= s.length();
        break;
      }
    }
    return s.substring(0,l);
  }
  
  //OSC OUT
  void ws_mix(float val){
      OscMessage myMessage = new OscMessage("/wsmix");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  }
  void harm_0(float val){
      OscMessage myMessage = new OscMessage("/harm");
      myMessage.add(int(0));
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("harm_0").setValueLabel(str(int(val*100)));
  }  
  
  void harm_1(float val){
      OscMessage myMessage = new OscMessage("/harm");
      myMessage.add(int(1));
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("harm_1").setValueLabel(str(int(val*100)));
  }
  
  void oct_0(float val){
      OscMessage myMessage = new OscMessage("/oct");
      myMessage.add(int(0));
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("oct_0").setValueLabel(str(int(val*10 -5)));
  }
  
  void oct_1(float val){
      OscMessage myMessage = new OscMessage("/oct");
      myMessage.add(int(1));
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("oct_1").setValueLabel(str(int(val*10 -5)));
  }
  void keybo_track(float val){
      OscMessage myMessage = new OscMessage("/trk");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  }
  
  void q(float val){
      OscMessage myMessage = new OscMessage("/q");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("q").setValueLabel(floatPrecision(str(val * 11 + 1),1));
  }
  
  void cutoff(float val){
      OscMessage myMessage = new OscMessage("/cut");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("cutoff").setValueLabel(str(int(sq(val)* 19980 + 20)));
  }
  
  void amp_atk(float val){
      OscMessage myMessage = new OscMessage("/aatk");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("amp_atk").setValueLabel(str(int(sq(val) * 749 + 1)));
  }  
  
  void amp_dec(float val){
      OscMessage myMessage = new OscMessage("/adec");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("amp_dec").setValueLabel(str(int(sq(val) * 794 + 1)));
  }  
  
  void filt_atk(float val){
      OscMessage myMessage = new OscMessage("/fatk");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("filt_atk").setValueLabel(str(int(sq(val) * 749 + 1)));
  }  
  
  void filt_dec(float val){
      OscMessage myMessage = new OscMessage("/fdec");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("filt_dec").setValueLabel(str(int(sq(val) * 749 + 1)));
  }  
  
  void noi_gain(float val){
      OscMessage myMessage = new OscMessage("/ngain");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  }  
  
  void noi_atk(float val){
      OscMessage myMessage = new OscMessage("/natk");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("noi_atk").setValueLabel(str(int(sq(val) * 749 + 1)));
  }  
  
  void noi_dec(float val){
      OscMessage myMessage = new OscMessage("/ndec");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("noi_dec").setValueLabel(str(int(sq(val) * 749 + 1)));
  }
    void filt_env_amt(float val){
      OscMessage myMessage = new OscMessage("/feamt");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  }  
  
  void course_0(float val){
      OscMessage myMessage = new OscMessage("/cors");
      myMessage.add(0);
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("course_0").setValueLabel(str(int(val*24 - 12)));
  }  
  
  void course_1(float val){
      OscMessage myMessage = new OscMessage("/cors");
      myMessage.add(1);
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("course_1").setValueLabel(str(int(val*24 - 12)));
  }
  
  void fine_0(float val){
      OscMessage myMessage = new OscMessage("/fine");
      myMessage.add(0);
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("fine_0").setValueLabel(str(int(val*100 - 50)));
  }
  
  void fine_1(float val){
      OscMessage myMessage = new OscMessage("/fine");
      myMessage.add(1);
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("fine_1").setValueLabel(str(int(val*100 - 50)));
  }
  
  void mst_gain(float val){
      OscMessage myMessage = new OscMessage("/mgain");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation); 
  }
  
  void osc_mix(float val){
      OscMessage myMessage = new OscMessage("/omix");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation); 
  }
  
  void porto(float val){
      OscMessage myMessage = new OscMessage("/porto");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation); 
  }
  //Dropdown menu's OSC
  void controlEvent(ControlEvent theEvent){
    if(theEvent.isGroup()){
      if(theEvent.getGroup() == wf0){
        OscMessage myMessage = new OscMessage("/wf");
        myMessage.add(0);
        myMessage.add((int)wf0.getValue());
        oscP5.send(myMessage, myRemoteLocation); 
      }
      else if(theEvent.getGroup() == wf1){
        OscMessage myMessage = new OscMessage("/wf");
        myMessage.add(1);
        myMessage.add((int)wf1.getValue());
        oscP5.send(myMessage, myRemoteLocation);
      }
      else if(theEvent.getGroup() == fs){
        OscMessage myMessage = new OscMessage("/fsel");
        myMessage.add(int(fs.getValue()));
        oscP5.send(myMessage, myRemoteLocation);
      }
      else if(theEvent.getGroup() == ws){
        OscMessage myMessage = new OscMessage("/wssel");
        myMessage.add(int(ws.getValue()));
        oscP5.send(myMessage, myRemoteLocation);
      }
    }
  }
