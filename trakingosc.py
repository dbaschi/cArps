import cv2
import mediapipe as mp
import math
from pythonosc import udp_client
from pythonosc import osc_message_builder

client = udp_client.SimpleUDPClient("127.0.0.1", 57120)




# midiout = rtmidi.MidiOut()
# # check and get the ports which are open
# available_ports = midiout.get_ports()

# # let's print the list of ports and see if ours is among them
# print(available_ports)
# if available_ports:
#     midiout.open_port(0)

mp_hands=mp.solutions.hands
mp_drawing=mp.solutions.drawing_utils

webcam = cv2.VideoCapture(0)
hands = mp_hands.Hands(max_num_hands=3,min_detection_confidence=0.7,min_tracking_confidence=0.6)
while webcam.isOpened():
    success, img = webcam.read()
    results = hands.process(img)

    # applying hand tracking model
    img=cv2.cvtColor(img,cv2.COLOR_BGR2RGB)
   

    # draw annotations on the image
    img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            mp_drawing.draw_landmarks(img,hand_landmarks,connections=mp_hands.HAND_CONNECTIONS)
            low_lm = hand_landmarks.landmark[0]
            th_lm = hand_landmarks.landmark[4]
            in_lm = hand_landmarks.landmark[8]
            
            #getting distances between finger tip and wrist and distance between the last phalanx and wrist

            mid_phx_lm = hand_landmarks.landmark[11]
            dist_mid_phx = math.sqrt((mid_phx_lm.x-low_lm.x)**2+(mid_phx_lm.y-low_lm.y)**2)

            mid_tip_lm= hand_landmarks.landmark[12]
            dist_mid = math.sqrt((mid_tip_lm.x-low_lm.x)**2+(mid_tip_lm.y-low_lm.y)**2)

            ri_phx_lm = hand_landmarks.landmark[15]
            dist_ri_phx = math.sqrt((ri_phx_lm.x-low_lm.x)**2+(ri_phx_lm.y-low_lm.y)**2)

            ri_tip_lm = hand_landmarks.landmark[16]
            dist_ri = math.sqrt((ri_tip_lm.x-low_lm.x)**2+(ri_tip_lm.y-low_lm.y)**2)

            pi_lm = hand_landmarks.landmark[20]
            dist_pi = math.sqrt((pi_lm.x-low_lm.x)**2+(pi_lm.y-low_lm.y)**2)

            if dist_mid > dist_mid_phx:
                mid = 1
            else:
                mid = 0 
            
            if dist_ri > dist_ri_phx:
                ri = 1
            else:
                ri = 0

            dist = math.sqrt((th_lm.x-in_lm.x)**2+(th_lm.y-in_lm.y)**2)
            vel = dist*100
            pitch = int(low_lm.x * 50+40)

            #building and sending the OSC message

            msg = osc_message_builder.OscMessageBuilder(address = '/params')

            msg.add_arg(pitch)
            msg.add_arg(vel)
            msg.add_arg(low_lm.y)
            msg.add_arg(mid)
            msg.add_arg(ri)
            msg.add_arg(dist_pi)
            msg.add_arg(low_lm.z)
            msg = msg.build()

            client.send(msg)

    cv2.imshow('cArps', img)
    if cv2.waitKey(5) & 0xFF == ord("q"):
        break
webcam.release()

cv2.destroyAllWindows()


