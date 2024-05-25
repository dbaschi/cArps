import cv2
import mediapipe as mp
import math
import time
from pythonosc import udp_client
from pythonosc import osc_message_builder

swipe_x = pre_x = post_x = last_swipe_x = count_x = 0
swipe_y = pre_y = post_y = last_swipe_y = count_y = 0
current = swipe_cooldown = 1
address = "/note"


client = udp_client.SimpleUDPClient("127.0.0.1", 12000)

def get_distance (lm1, lm2):
    return math.sqrt((lm1.x - lm2.x) ** 2 + (lm1.y - lm2.y) ** 2)

def send_osc (client, pitch ,vel, dist_pi, mid, dist_mid, ri, swipe_x, swipe_y,rot_x, address):
    msg = osc_message_builder.OscMessageBuilder(address)
    msg.add_arg(pitch)
    msg.add_arg(vel)
    msg.add_arg(dist_pi)
    msg.add_arg(mid)
    msg.add_arg(dist_mid)
    msg.add_arg(ri)
    msg.add_arg(swipe_x)
    msg.add_arg(swipe_y)
    msg.add_arg(rot_x)
    msg = msg.build()

    client.send(msg)



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
            dist_mid_phx = get_distance(mid_phx_lm, low_lm)

            mid_tip_lm= hand_landmarks.landmark[12]
            dist_mid = get_distance (mid_tip_lm, low_lm)
           

            ri_phx_lm = hand_landmarks.landmark[15]
            dist_ri_phx = get_distance(ri_phx_lm, low_lm)
            

            ri_tip_lm = hand_landmarks.landmark[16]
            dist_ri = get_distance(ri_tip_lm, low_lm)
            

            pi_lm = hand_landmarks.landmark[20]
            dist_pi = get_distance(pi_lm, low_lm)

            rot_x = th_lm.x-pi_lm.x

            mid = 1 if dist_mid > dist_mid_phx else 0

            ri = 1 if dist_ri > dist_ri_phx else 0
    

            dist = get_distance(th_lm, in_lm)
            
            vel = dist
            pitch = int(low_lm.x * 50+40)
            post_y = low_lm.y
            post_x = low_lm.x

           
           
            if current > last_swipe_x + swipe_cooldown:
             if post_x < pre_x -0.08 :
                swipe_x = 1
             elif post_x > pre_x + 0.08:
                swipe_x = -1
             else:
                swipe_x = 0
          
         
        
            count_x += swipe_x
            if count_x == 2:
                count_x = 0
            if count_x == -1:
                count_x = 1
           
            if current > last_swipe_y + swipe_cooldown:
             if post_y < pre_y -0.08 :
                swipe_y = 1
             elif post_y > pre_y + 0.08:
                swipe_y = -1
             else:
                swipe_y = 0
          
            count_y += swipe_y
            if count_y == 3:
                count_y = 0
            if count_y == -1:
                count_y = 2
           
            current = time.time()

        
            if swipe_y == 1 or swipe_y == -1:
                last_swipe_y = current
                send_osc(client, pitch ,vel, dist_pi, mid, dist_mid, ri, swipe_x, swipe_y,rot_x, address)
            if current > last_swipe_y + swipe_cooldown:
                if count_y == 0 :
                    address = "/note"
                elif count_y == 1 :
                    address = "/arp"
                elif count_y == 2 :
                 if swipe_x == 1 or swipe_x == -1 :
                    last_swipe_x = current
                    send_osc(client, pitch ,vel, dist_pi, mid, dist_mid, ri, swipe_x, swipe_y,rot_x, address)
                 if current > last_swipe_x + swipe_cooldown :
                        if count_x == 0 :
                            address = "/plug1"
                        elif count_x == 1:
                            address = "/plug2"
                        elif count_x == 2 :
                            address = "/plug3"
                        elif count_x == 3 :
                           address = "/plug4"
                 
                send_osc(client, pitch ,vel, dist_pi, mid, dist_mid, ri, swipe_x, swipe_y,rot_x, address)
            

            pre_y=post_y
            swipe_y = 0
            print(count_y)
            
            
            pre_x=post_x
            swipe_x = 0
           
        

    cv2.imshow('cArps', img)

    if cv2.waitKey(5) & 0xFF == ord("q"):
        break
webcam.release()

cv2.destroyAllWindows()


