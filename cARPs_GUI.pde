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

boolean isOn = false;
int pitchValue;
float duration, sustain, panner, distortion;
//------------------------------------------------------
void setup() {
  size(200, 900);
  background(255);
  smooth();
  noStroke();
  
  oscP5 = new OscP5(this, 12000);
  myPc = new NetAddress("127.0.0.1", 57120); 
  cp5 = new ControlP5(this);
  
  onOff = cp5.addButton("arpcontrol")
    .setValue(0)
    .setPosition(10,10)
    .setSize(180,50)
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
    .setColorBackground(color(0,255,68))
    .setColorActive(color(16,223,71))
    .setColorCaptionLabel(color(255));
    
  sustainKnob = cp5.addKnob("sustain")
    .setPosition(37,215)
    //setRadius(50)
    .setSize(125,125)
    .setRange(0.05,4)
    .setValue(0.17)
    .setColorForeground(color(0))
    .setColorBackground(color(0,255,68))
    .setColorActive(color(16,223,71))
    .setColorCaptionLabel(color(255));
    
  pitch = cp5.addNumberbox("pitchValue")
    .setRange(0,127)
    .setValue(pitchValue)
    .setPosition(10, 370)
    
    .setSize(180,150);
    
  pannerKnob = cp5.addKnob("panner")
    .setPosition(37,550)
    //setRadius(50)
    .setSize(125,125)
    .setRange(0,1)
    .setValue(0.5)
    .setColorForeground(color(0))
    .setColorBackground(color(0,255,68))
    .setColorActive(color(16,223,71))
    .setColorCaptionLabel(color(255));
    
  distortionKnob = cp5.addKnob("distortion")
    .setPosition(37,710)
    //setRadius(50)
    .setSize(125,125)
    .setRange(0,1)
    .setValue(0.5)
    .setColorForeground(color(0))
    .setColorBackground(color(0,255,68))
    .setColorActive(color(16,223,71))
    .setColorCaptionLabel(color(255));
}
//------------------------------------------
void toggleState() {
  isOn = !isOn;
  if (isOn) {
    onOff.setLabel("SynthOff");
  } else {
    onOff.setLabel("SynthOn");
  }
}
//------------------------------------------
void draw() {
  background(0);
}
//--------------------------------------------
void controlEvent(ControlEvent theEvent) {
  if (theEvent.isFrom("arpcontrol")) {
    OscMessage msg1 = new OscMessage("/onoff");
    msg1.add(isOn ? "start" : "stop");
    oscP5.send(msg1, myPc);
    msg1.print();
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
}
