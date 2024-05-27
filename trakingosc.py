import cv2
import mediapipe as mp
import math
import time
from pythonosc import udp_client
from pythonosc import osc_message_builder

#seting up swipe related variables 
swipe_x = pre_x = post_x = last_swipe_x = count_x = 0
swipe_y = pre_y = post_y = last_swipe_y = count_y = 0
current = swipe_cooldown = 1
swipe_limit = 0.06


#client to send, starting address and osc message and message builder
client = udp_client.SimpleUDPClient("127.0.0.1", 12000)
address = "/note"

def send_osc (client, pitch ,Distance_Thumb_Index, Distance_Pinky_Tip, Middle_Bend, Distance_Middle_Tip, Ring_Bend, swipe_x, swipe_y,Rotation_x, address):
    msg = osc_message_builder.OscMessageBuilder(address)
    msg.add_arg(pitch)
    msg.add_arg(Distance_Thumb_Index)
    msg.add_arg(Distance_Pinky_Tip)
    msg.add_arg(Middle_Bend)
    msg.add_arg(Distance_Middle_Tip)
    msg.add_arg(Ring_Bend)
    msg.add_arg(swipe_x)
    msg.add_arg(swipe_y)
    msg.add_arg(Rotation_x)
    msg = msg.build()

    client.send(msg)

#funcion to get distance between landmarks
def get_distance (lm1, lm2):
    return math.sqrt((lm1.x - lm2.x) ** 2 + (lm1.y - lm2.y) ** 2)

#setting up hands for the recognition
mp_hands=mp.solutions.hands

hands = mp_hands.Hands(max_num_hands=3,min_detection_confidence=0.7,min_tracking_confidence=0.6)

#defining webcam and creating a loop to get the immage and draw on it
webcam = cv2.VideoCapture(0)

while webcam.isOpened():
    success, img = webcam.read()
    results = hands.process(img)

    # applying hand tracking model
    img=cv2.cvtColor(img,cv2.COLOR_BGR2RGB)
    results = hands.process(img)

    # setting the image back to the right color profile
    img = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)

   #loop for when hands are detected 
    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:

            #drawing the hand
            mp_drawing=mp.solutions.drawing_utils
            mp_drawing.draw_landmarks(img,hand_landmarks,connections=mp_hands.HAND_CONNECTIONS)

            #defining all the landmarks we need
            Wrist = hand_landmarks.landmark[0]
            Thumb_Tip = hand_landmarks.landmark[4]
            Index_MCP = hand_landmarks.landmark [5]
            Index_Tip = hand_landmarks.landmark[8]
            Middle_DIP = hand_landmarks.landmark[11]
            Middle_Tip= hand_landmarks.landmark[12]
            Ring_DIP = hand_landmarks.landmark[15]
            Ring_Tip = hand_landmarks.landmark[16]
            Pinky_MCP = hand_landmarks.landmark [17]
            Pinky_Tip = hand_landmarks.landmark[20]
            
            #calculating distances
            Distance_Middle_DIP = get_distance(Middle_DIP, Wrist)
            Distance_Middle_Tip = get_distance (Middle_Tip, Wrist)
            Distance_Ring_DIP = get_distance(Ring_DIP, Wrist)
            Distance_Ring_Tip = get_distance(Ring_Tip, Wrist)
            Distance_Pinky_Tip = get_distance(Pinky_Tip, Wrist)
            Distance_Thumb_Index = get_distance(Thumb_Tip, Index_Tip)
            Rotation_x = Index_MCP.x-Pinky_MCP.x

            #on-off mesasges to check if middle finger and pinky are bent
            Middle_Bend = 1 if Distance_Middle_Tip > Distance_Middle_DIP else 0
            Ring_Bend = 1 if Distance_Ring_Tip > Distance_Ring_DIP else 0

            #converting the position of the hand to get a value we can use as pitch
            pitch = int(Wrist.x * 50+40)

            #creating a way to get a swipe motion detection in both x and y directions
            post_y = Wrist.y
            post_x = Wrist.x
            
            if current > last_swipe_x + swipe_cooldown:
             if post_x < pre_x - swipe_limit :
                swipe_x = 1
             elif post_x > pre_x + swipe_limit:
                swipe_x = -1
             else:
                swipe_x = 0
                
            count_x += swipe_x
            if count_x == 3:
                count_x = 0
            if count_x == -1:
                count_x = 2
           
            if current > last_swipe_y + swipe_cooldown:
             if post_y < pre_y -0.07 :
                swipe_y = 1
             elif post_y > pre_y + 0.07:
                swipe_y = -1
             else:
                swipe_y = 0
          
            count_y += swipe_y
            if count_y == 3:
                count_y = 0
            if count_y == -1:
                count_y = 2
           
            current = time.time()
            
            #setting different address for the osc message that depend on the swipe in direction y
            if swipe_y == 1 or swipe_y == -1:
                last_swipe_y = current
                send_osc(client, pitch ,Distance_Thumb_Index, Distance_Pinky_Tip, Middle_Bend, Distance_Middle_Tip, Ring_Bend, swipe_x, swipe_y,Rotation_x, address)
            if current > last_swipe_y + swipe_cooldown:
                if count_y == 0 :
                    address = "/note"
                elif count_y == 1 :
                    address = "/arp"
                elif count_y == 2 :
                 #setting different address for the osc message that depend on the swipe in direction x 
                 if swipe_x == 1 or swipe_x == -1 :
                    last_swipe_x = current
                    send_osc(client, pitch , Distance_Thumb_Index, Distance_Pinky_Tip, Middle_Bend, Distance_Middle_Tip, Ring_Bend, swipe_x, swipe_y,Rotation_x, address)
                 if current > last_swipe_x + swipe_cooldown :
                        if count_x == 0 :
                            address = "/plug1"
                            swipe_limit = 0.025
                        elif count_x == 1 :
                            address = "/plug2"
                            swipe_limit = 0.06
                        elif count_x == 2 :
                            address = "/plug3"
                            swipe_limit = 0.06
                 
                send_osc(client, pitch , Distance_Thumb_Index, Distance_Pinky_Tip, Middle_Bend, Distance_Middle_Tip, Ring_Bend, swipe_x, swipe_y,Rotation_x, address)
           
            #preparing swipe related variables for next cycle
            pre_y=post_y
            swipe_y = 0

            pre_x=post_x
            swipe_x = 0

    #show the immgage     
    cv2.imshow('cArps', img)

    #close webcam when user press the key "n"
    if cv2.waitKey(5) & 0xFF == ord("n"):
        break
webcam.release()

cv2.destroyAllWindows()


