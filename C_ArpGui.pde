import controlP5.*;
import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myPc;
ControlP5 cp5;
Button onOff;
Knob durationKnob;
Knob sustainKnob;
Numberbox pitch;
Knob pannerKnob;
Knob distortionKnob;
Knob timeKnob, feedbackKnob, mixKnob;

boolean isOn = false;
int pitchValue = 60;
float duration, sustain, panner, distortion;
float time, feedback, mix;
int green = color(0,255,68);
int red = color(235,0,0);
int ri = 0;
int mid = 0;
PFont font;

//--------------------------------------------------------------------

void setup() {
  size(200, 800);
  background(255);
  smooth();
  noStroke();
  
  oscP5 = new OscP5(this, 12000);
  myPc = new NetAddress("127.0.0.1", 57120); 
  cp5 = new ControlP5(this);
  font = createFont("aerial",13);
  
  onOff = cp5.addButton("arpcontrol")
    .setValue(0)
    .setPosition(10,10)
    .setSize(180,50)
    .setFont(font)

    .onClick(new CallbackListener() {
                      public void controlEvent(CallbackEvent event) {
                        toggleState();
                      }
                    });
   
  durationKnob = cp5.addKnob("duration")
    .setPosition(37,70)
    //setRadius(50)
    .setSize(125,125)
    .setRange(0.05,2)
    .setValue(0.17)
    .setColorForeground(color(0))
    .setColorBackground(green)
    .setColorActive(color(16,223,71))
    .setColorValue(color(20,20,20))
    .setFont(font)
    .setColorCaptionLabel(color(255));
    

    
  sustainKnob = cp5.addKnob("sustain")
    .setPosition(37,215)
    //setRadius(50)
    .setSize(125,125)
    .setRange(0.05,3)
    .setValue(0.17)
    .setColorForeground(color(0))
    .setColorBackground(green)
    .setColorActive(color(16,223,71))
    .setColorValue(color(20,20,20))
    .setFont(font)
    .setColorCaptionLabel(color(255));
    
  pitch = cp5.addNumberbox("pitchValue")
    .setRange(0,127)
    .setValue(pitchValue)
    .setPosition(10, 370)
    .setColorBackground(green)
    .setColorForeground(color(20,20,20))
    .setColorActive(color(16,223,71))
    .setColorValue(color(20,20,20))
    .setFont(font)
    .setSize(180,40);
    
  pannerKnob = cp5.addKnob("panner")
    .setPosition(10,450)
    //setRadius(50)
    .setSize(80,80)
    .setRange(0,1)
    .setValue(0.5)
    .setColorForeground(color(0))
    .setColorBackground(green)
    .setColorActive(color(16,223,71))
    .setColorValue(color(20,20,20))
    .setFont(font)
    .setColorCaptionLabel(color(255));
    
  distortionKnob = cp5.addKnob("distortion")
    .setPosition(110,450)
    .setSize(80,80)
    .setRange(0,1)
    .setValue(0)
    .setColorForeground(color(0))
    .setColorBackground(green)
    .setColorActive(color(16,223,71))
    .setColorValue(color(20,20,20))
    .setColorValue(color(20,20,20))
    .setFont(font)
    .setColorCaptionLabel(color(255));
    
  timeKnob = cp5.addKnob("time")
    .setPosition(60,575)
    
    .setSize(80,80)
    .setRange(0.01, 0.9)
    .setValue(0.5)
    .setColorForeground(color(0))
    .setColorBackground(green)
    .setColorActive(color(16,223,71))
    .setColorValue(color(20,20,20))
    .setFont(font)
    .setColorCaptionLabel(color(255));
    
  feedbackKnob = cp5.addKnob("feedback")
    .setPosition(10,680)
    
    .setSize(80,80)
    .setRange(0.01, 0.9)
    .setValue(0.5)
    .setColorForeground(color(0))
    .setColorBackground(green)
    .setColorActive(color(16,223,71))
    .setColorValue(color(20,20,20))
    .setFont(font)
    .setColorCaptionLabel(color(255));
    
  mixKnob = cp5.addKnob("mix")
    .setPosition(110,680)
    .setSize(80,80)
    .setRange(0, 1)
    .setValue(0)
    .setColorForeground(color(0))
    .setColorBackground(green)
    .setColorActive(color(16,223,71))
    .setColorValue(color(20,20,20))
    .setFont(font)
    .setColorCaptionLabel(color(255));
}

//--------------------------------------------------------------------

void toggleState() {
  isOn = !isOn;
  if (isOn) {
    onOff.setLabel("SynthOff");
  } else {
    onOff.setLabel("SynthOn");
  }
}

//--------------------------------------------------------------------

void draw() {
  background(0);
}

//--------------------------------------------------------------------
//Reciving OSC Messages from pyhon at different addresses

void oscEvent(OscMessage msg) {
  
  if (msg.checkAddrPattern("/note")) {
    pitchValue = msg.get(0).intValue();
    pitch.setValue(pitchValue);
    mid = msg.get(3).intValue();
    ri = msg.get(5).intValue();

    durationKnob.setColorBackground(red);
    sustainKnob.setColorBackground(red);
    pannerKnob.setColorBackground(red);
    distortionKnob.setColorBackground(red);
    timeKnob.setColorBackground(red);
    feedbackKnob.setColorBackground(red);
    mixKnob.setColorBackground(red);
    pitch.setColorBackground(green);

    println("note " );

  }
  
  if (msg.checkAddrPattern("/arp")) {
    duration = msg.get(1).floatValue();
    duration = map(duration, 0.03, 0.52, 0.05, 3);
    durationKnob.setValue(duration);
    sustain = msg.get(2).floatValue();
    sustain = map(sustain, 0.15, 0.47, 0.05, 3);
    sustainKnob.setValue(sustain);
    
    durationKnob.setColorBackground(green);
    sustainKnob.setColorBackground(green);
    pannerKnob.setColorBackground(red);
    distortionKnob.setColorBackground(red);
    timeKnob.setColorBackground(red);
    feedbackKnob.setColorBackground(red);
    mixKnob.setColorBackground(red);
    pitch.setColorBackground(red);
 
    println("arp " );

  }
  
  if (msg.checkAddrPattern("/plug1")) {
    panner = msg.get(8).floatValue();
    panner = map(panner, -0.09, 0.09, 0, 1);
    pannerKnob.setValue(panner);
    
    durationKnob.setColorBackground(red);
    sustainKnob.setColorBackground(red);
    pannerKnob.setColorBackground(green);
    distortionKnob.setColorBackground(red);
    timeKnob.setColorBackground(red);
    feedbackKnob.setColorBackground(red);
    mixKnob.setColorBackground(red);
    pitch.setColorBackground(red);
 
    println("pan " );
  }
  
  if (msg.checkAddrPattern("/plug2")) {
    distortion = msg.get(1).floatValue();
    distortion = map(distortion, 0.03, 0.52, 0, 1);
    distortionKnob.setValue(distortion);
    
    durationKnob.setColorBackground(red);
    sustainKnob.setColorBackground(red);
    pannerKnob.setColorBackground(red);
    distortionKnob.setColorBackground(green);
    timeKnob.setColorBackground(red);
    feedbackKnob.setColorBackground(red);
    mixKnob.setColorBackground(red);
    pitch.setColorBackground(red);
 
    println("dist " );
  }
  
  if (msg.checkAddrPattern("/plug3")) {
    mix = msg.get(1).floatValue();
    mix = map(mix, 0.03, 0.52, 0, 1);
    mixKnob.setValue(mix);
    feedback = msg.get(4).floatValue();
    feedback = map(feedback, 0.15, 0.52, 0.01, 0.9);
    feedbackKnob.setValue(feedback);
    
    durationKnob.setColorBackground(red);
    sustainKnob.setColorBackground(red);
    pannerKnob.setColorBackground(red);
    distortionKnob.setColorBackground(red);
    timeKnob.setColorBackground(green);
    feedbackKnob.setColorBackground(green);
    mixKnob.setColorBackground(green);
    pitch.setColorBackground(red);
    println("delay");
  }
}

//--------------------------------------------------------------------
//sending OSC Messages to SuperCollider at different addresses

void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom("arpcontrol")) {
    OscMessage msg1 = new OscMessage("/onoff");
    msg1.add(isOn ? "start" : "stop");
    oscP5.send(msg1, myPc);
    msg1.print();
  }
    if(theEvent.isFrom("pitchValue")) {
    OscMessage msg7 = new OscMessage("/pitch");
    msg7.add(pitchValue);
    msg7.add(mid);
    msg7.add(ri);
    oscP5.send(msg7, myPc);
    msg7.print();
  }
  if(theEvent.isFrom("duration")) {
    OscMessage msg2 = new OscMessage("/dur");
    msg2.add(duration);
    oscP5.send(msg2, myPc);
    msg2.print();
  }
  
  if (theEvent.isFrom("sustain")) {
    OscMessage msg3 = new OscMessage("/sus");
    msg3.add(sustain);
    oscP5.send(msg3, myPc);
    msg3.print();
  }
  
  if (theEvent.isFrom("panner")) {
    OscMessage msg4 = new OscMessage("/pan");
    msg4.add(panner);
    oscP5.send(msg4, myPc);
    msg4.print();
  }
  
  if (theEvent.isFrom("distortion")) {
    OscMessage msg5 = new OscMessage("/dist");
    msg5.add(distortion);
    oscP5.send(msg5, myPc);
    msg5.print();
  }
  
  if (theEvent.isFrom("time") || theEvent.isFrom("feedback") || theEvent.isFrom("mix")) {
    OscMessage msg6 = new OscMessage("/delay");
    msg6.add(time);
    msg6.add(feedback);
    msg6.add(mix);
    oscP5.send(msg6, myPc);
    msg6.print();
  }
}
