## CARPS

**PROJECT AIM** 
   
The main idea is to create an arpeggiator that can be managed by using one hand  
Arpeggiator is developed in SuperCollider  
Effects are developed in JUCE  
Hand Tracking is handled by Python with external google library [mediapipe](https://pypi.org/project/mediapipe/) and [cv2](https://pypi.org/project/opencv-python/) and [osc](https://pypi.org/project/python-osc/)  

**CONTROL LEGEND**  
* Note Window:
   * Pitch: horizontal movement
   * Scale: middel and pinky
      * middle extended and pinky extedned: Major
      * middle bent and pinky extedned: Minor
      * middle extended pinky bent: Egyptian
      * middle bent pinky bent: Whole tone
* Arp Window:
   * Duration: thumb tip and index tip distance
   * Sustain: pinky bend
* Panner Window:
   * Panner: hand rotation on vertical axe
* Distortion:
  * Distortion: thumb tip and index tip distance
* Delay:
   * Time: use GUI
   * Feedback: middle bend
   * Mix: thumb tip and index tip distance


 

