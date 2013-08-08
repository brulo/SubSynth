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
              // 0,  1,  2,   3,  
  int[] col = { 10, 40, 70, 100, 150, 200, 230, 280, 310, 340, 370, 420, 450, 500 };
  int[] row = { 10, 45, 50, 109, 170, 200 };
  float envMin=0.01; 
  float envLen=4999.99;
  
  void setup(){
    size(550,210);
    noStroke();
    cP5 = new ControlP5(this);
    //---------------OSCILLATOR SECTION---------------\\
    //OSCILLATOR MIXER
    cP5.addSlider("osc_mix")
    .setRange(0,1)
    .setSize(110,20)
    .setPosition(col[0],row[0])
    .setSliderMode(0)
    .setValue(0)
    ;
    //FINE TUNING 1
    cP5.addSlider("fine_1")
    .setCaptionLabel("fine") 
    .setRange(0,1)
    .setSize(20,100)
    .setPosition(col[3], row[2])
    .setSliderMode(0)
    .setHandleSize(5)
    .setValue(.5)
    ;
    //COURSE TUNING 1
    cP5.addSlider("course_1")
    .setCaptionLabel("cors") 
    .setRange(0,1)
    .setSize(20,100)
    .setPosition(col[2], row[2])
    .setSliderMode(0)
    .setHandleSize(5)
    .setValue(.5)
    ;
    //FINE TUNING 0
    cP5.addSlider("fine_0")
    .setCaptionLabel("fine") 
    .setRange(0,1)
    .setSize(20,100)
    .setPosition(col[1], row[2])
    .setSliderMode(0)
    .setHandleSize(5)
    .setValue(.5)
    ;
    //COURSE TUNING 0
    cP5.addSlider("course_0")
    .setCaptionLabel("cors") 
    .setRange(0,1)
    .setSize(20,100)
    .setPosition(col[0], row[2])
    .setSliderMode(0)
    .setHandleSize(5)
    .setValue(.5)
    ; 
     
    //HARMONICS 0
    cP5.addNumberbox("harm_0")
    .setLabel("hrm")
    .setRange(0,1)
    .setValue(0)
    .setMultiplier(0.01)
    .setSize(20,20)
    .setPosition(col[0], row[4])
    ; 
    //HARMONICS 1
    cP5.addNumberbox("harm_1")
    .setLabel("hrm")
    .setRange(0,1)
    .setValue(0)
    .setMultiplier(0.01)
    .setSize(20,20)
    .setPosition(col[2], row[4])
    ;     
    //OCTAVE 0
    cP5.addNumberbox("oct_0")
    .setLabel("oct")
    .setRange(0,1)
    .setValue(.5)
    .setMultiplier(0.01)
    .setSize(20,20)
    .setPosition(col[1], row[4])
    ; 
    //OCTAVE 1
    cP5.addNumberbox("oct_1")
    .setLabel("oct")
    .setRange(0,1)
    .setValue(.5)
    .setMultiplier(0.01)
    .setSize(20,20)
    .setPosition(col[3], row[4])
    ; 
    
    //WAVESHAPE MIX
    cP5.addSlider("ws_mix")
    .setLabel("mix")
    .setSize(20,100)
    .setRange(0, 1)
    .setRange(0,1)
    .setPosition(col[4],row[2])
    ;       
    //PORTOMENTO
    cP5.addSlider("porto")
    .setLabel("")
    .setRange(0,1)
    .setSize(50,20)
    .setPosition(col[4]-15,row[4])
    ;
    
    //---------------------FILTER---------------------\\
    //FILTER DECAY  
    cP5.addSlider("filt_dec")
    .setLabel("dec")
    .setSize(20,100)
    .setRange(0,1)
    .setPosition(col[10],row[2])
    ;
    //FILTER ATTACK
    cP5.addSlider("filt_atk")
    .setLabel("atk")
    .setSize(20,100)
    .setRange(0, 1)
    .setPosition(col[9],row[2])
    ;
    //FILTER RESONANCE  
    cP5.addSlider("q")
    .setSize(20,100)
    .setRange(0,1)
    .setPosition(col[8],row[2])
    ;
    //FILTER CUTOFF 
    cP5.addSlider("cutoff")
    .setLabel("cut")
    .setSize(20,100)
    .setRange(0,1)
    .setPosition(col[7],row[2])
    .setValue(1)
    ;
    //FILTER AMOUNT
    cP5.addSlider("filt_env_amt")
    .setLabel("")
    .setSize(50,20)
    .setRange(0,1)
    .setPosition(col[9],row[1]-20)
    ;
    //FILTER KEYBOARD TRACKING  
    cP5.addSlider("keybo_track")
    .setLabel("")
    .setSize(110,20)
    .setRange(0,1)
    .setPosition(col[7],row[4])
    ;

    //NOISE GAIN
    cP5.addSlider("noi_gain")
    .setLabel("")
    .setRange(0,1)
    .setSize(50,20)
    .setPosition(col[5], row[4])
    ; 
    //---------------------ENVELOPES------------------------\\
    //AMPLITUDE DECAY
    cP5.addSlider("amp_dec")
    .setLabel("  dec")
    .setSize(20,42)
    .setRange(0,1)
    .setPosition(col[6],row[2])
    ;
    //AMPLITUDE ATTACK
    cP5.addSlider("amp_atk")
    .setLabel(" atk")
    .setSize(20,42)
    .setRange(0,1)
    .setPosition(col[5],row[2])
    ;
    //NOISE DECAY
    cP5.addSlider("noi_dec")
    .setLabel("")
    .setSize(20,41)
    .setRange(0,1)
    .setPosition(col[6],row[3])
    ;
    //NOISE ATTACK
    cP5.addSlider("noi_atk")
    .setLabel("")
    .setSize(20,41)
    .setRange(0,1)
    .setPosition(col[5],row[3])
    ; 

    //-------------------END STAGE-----------------\\
    //MASTER GAIN
    cP5.addSlider("mst_gain")
    .setRange(0,1)
    .setValue(0.7)
    .setSize(20,100)
    .setPosition(col[13], row[2])
    ;
    //FOLDBACK THRESH
    cP5.addSlider("fb_thresh")
    .setLabel("thresh")
    .setSize(20,100)
    .setRange(0, 1)
    .setPosition(col[12],row[2])
    ;    
    //FOLDBACK INDEX
    cP5.addSlider("fb_index")
    .setLabel("AMT")
    .setSize(20,100)
    .setRange(0, 1)
    .setPosition(col[11],row[2])
    ; 
    //PANNING
    cP5.addSlider("pan")
    .setLabel("")
    .setSize(100,20)
    .setRange(0,1)
    .setPosition(col[11],row[4])
    .setSliderMode(0)
    .setHandleSize(5)
    .setValue(.5)
    ;
    
    //--------------------------LABELS--------------------------\\
    //AMPLITUDE ENVELOPE LABEL
    cP5.addTextlabel("amp_env")
    .setText("AMP")
    .setPosition(col[5]+11, row[1]-8)
    ;
    //NOISE LABEL
    cP5.addTextlabel("noise_label")
    .setText("NOISE")
    .setPosition(col[5]+10,row[4]-15)
    ;
    //NOISE GAIN LABEL
    cP5.addTextlabel("noi_gain_label")
    .setText("GAIN")
    .setPosition(col[5]+12,row[5]-5)
    ;
    //KEYBO TRACK LABEL
    cP5.addTextlabel("track_label")
    .setText("TRACKING")
    .setPosition(col[8],row[5]-5)
    ;
    //FILTER ENV AMT LABEL
    cP5.addTextlabel("filt_env_label")
    .setText("AMT")
    .setPosition(col[9]+10,row[0]+2)
    ;
    //PORTO LABEL
    cP5.addTextlabel("porto_label")
    .setText("PORTO")
    .setPosition(col[4]-9,row[4]+25)
    ;
    //FOLDBACK LABEL
    cP5.addTextlabel("fb_label")
    .setText("FOLDBACK")
    .setPosition(col[11], row[1]-8)
    ;
    //PAN LABEL
    cP5.addTextlabel("pan_label")
    .setText("PAN")
    .setPosition(col[12]+8,row[5]-5)
    ;
    //---------------------------DROP DOWNS---------------------------\\
    //WAVEFORM SEL 0
    wf0 = cP5.addDropdownList("wave_0")
    .setPosition(col[0], row[1])
    .setWidth(50);
    wf0.addItem("square", 0);
    wf0.addItem("saw", 1);  
    wf0.addItem("sine", 2);
    wf0.addItem("tri", 3);  
    
    //WAVEFORM SEL 1 
    wf1 = cP5.addDropdownList("wave_1")
    .setPosition(col[2], row[1])
    .setWidth(50);
    wf1.addItem("square", 0);
    wf1.addItem("saw", 1);
    wf1.addItem("sine", 2);
    wf1.addItem("tri", 3);
    
    //WAVESHAPE SEL
    ws = cP5.addDropdownList("ws_sel")
    .setLabel("shp")
    .setPosition(col[4],row[1])
    .setWidth(30);
    ws.addItem("sqr", 0);
    ws.addItem("saw", 1);
    ws.addItem("sin", 2);
    ws.addItem("tri", 3);
    
    //FILTER TYPE SEL
    fs = cP5.addDropdownList("filt_sel")
    .setLabel("filter")
    .setPosition(col[7], row[1])
    .setWidth(50);
    fs.addItem("lp", 0);
    fs.addItem("hp", 1);
    fs.addItem("rez", 2);
    //fs.addItem("kf", 3);
    
    //----------------------------OSC------------------------\\
    oscP5 = new OscP5(this, 12000);
    myRemoteLocation = new NetAddress("localHost", 12001); 
  }
  
  void draw(){ background(1); }  
  
  //------------------------------FUNCTIONS-----------------------------\\
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
  //
  void osc_mix(float val){
      OscMessage myMessage = new OscMessage("/omix");
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
  
  void ws_mix(float val){
      OscMessage myMessage = new OscMessage("/wsmix");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  }
    
  void porto(float val){
      OscMessage myMessage = new OscMessage("/porto");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation); 
  }

  void amp_atk(float val){
      OscMessage myMessage = new OscMessage("/aatk");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("amp_atk").setValueLabel(str(int(sq(val) * 749 + 1)));
      cP5.getController("amp_atk").setValueLabel(str(int(sq(val) * envLen + envMin)));
  }  
  
  void amp_dec(float val){
      OscMessage myMessage = new OscMessage("/adec");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("amp_dec").setValueLabel(str(int(sq(val) * 794 + 1)));
      cP5.getController("amp_dec").setValueLabel(str(int(sq(val) * envLen + envMin)));
  }    
  
  void noi_atk(float val){
      OscMessage myMessage = new OscMessage("/natk");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("noi_atk").setValueLabel(str(int(sq(val) * 749 + 1)));
      cP5.getController("noi_atk").setValueLabel(str(int(sq(val) * envLen + envMin)));
  }  
  
  void noi_dec(float val){
      OscMessage myMessage = new OscMessage("/ndec");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("noi_dec").setValueLabel(str(int(sq(val) * 749 + 1)));
      cP5.getController("noi_dec").setValueLabel(str(int(sq(val) * envLen + envMin)));
  }  
  
  void noi_gain(float val){
      OscMessage myMessage = new OscMessage("/ngain");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  }  
  
  void cutoff(float val){
      OscMessage myMessage = new OscMessage("/cut");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("cutoff").setValueLabel(str(int(sq(val)* 19980 + 20)));
  }
    
  void q(float val){
      OscMessage myMessage = new OscMessage("/q");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("q").setValueLabel(floatPrecision(str(val * 11 + 1),1));
  }
  
  void filt_atk(float val){
      OscMessage myMessage = new OscMessage("/fatk");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("filt_atk").setValueLabel(str(int(sq(val) * 749 + 1)));
      cP5.getController("filt_atk").setValueLabel(str(int(sq(val) * envLen + envMin)));
  }  
  
  void filt_dec(float val){
      OscMessage myMessage = new OscMessage("/fdec");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
      cP5.getController("filt_dec").setValueLabel(str(int(sq(val) * 749 + 1)));
      cP5.getController("filt_dec").setValueLabel(str(int(sq(val) * envLen + envMin)));
  }
  
  void filt_env_amt(float val){
      OscMessage myMessage = new OscMessage("/feamt");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  } 
  
  void keybo_track(float val){
      OscMessage myMessage = new OscMessage("/trk");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  } 
    
  void fb_index(float val){
      OscMessage myMessage = new OscMessage("/fbi");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  }
  
  void fb_thresh(float val){
      OscMessage myMessage = new OscMessage("/fbt");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  }
  
  void pan(float val){
      OscMessage myMessage = new OscMessage("/pan");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation);
  }
  
  void mst_gain(float val){
      OscMessage myMessage = new OscMessage("/mgain");
      myMessage.add(val);
      oscP5.send(myMessage, myRemoteLocation); 
  }

  //------------------------------DROPDOWN MENUS OSC------------------------------\\
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
