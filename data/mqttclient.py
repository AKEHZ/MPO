import paho.mqtt.client as mqtt
import paho.mqtt.subscribe as subscribePP2
import paho.mqtt.publish as publishPP2
import sys
import threading
import time


#Information about the Broker 
broker = sys.argv[6]
port = 8883
topic = ""
payload = ""

#The following sleep timer is needed because MPO script restarts Mosquitto just before it runs this python script and so we need mosquitto to be up and working when this python script is running
waitTime= float(sys.argv[7]) / 1.50
if waitTime < 5:
    waitTime = 5
time.sleep(waitTime)

#The following lines are for topics of pp2 and pp3
TopicPP2Pub = sys.argv[1]
TopicPP2Pub = TopicPP2Pub.split(",")

TopicPP2Sub = sys.argv[2]
TopicPP2Sub = TopicPP2Sub.split(",")

TopicPP3Sub = sys.argv[3]
TopicPP3Sub = TopicPP3Sub.split(",")

#The following lines are for getting the credentials of the Delivery agents
DA_username= sys.argv[4] 
DA_pass= sys.argv[5] 


#This function is creating a deivery agent to take messages sent on pp2/# topics and publish them on the original topics (w/o pp2 prefix)
def on_messageForPP2Pub(client, userdata, msg):
    payload= msg.payload
    #the following two lines convert msg.topic from unicode to str and then remove pp2 or pp3 from topics
    topic= str(msg.topic)
    topic= msg.topic[4:]
    publishPP2.single(topic,payload=payload,hostname= broker, port= 8883, auth={'username':DA_username,'password':DA_pass}, tls={'ca_certs':"/ssl/ca.crt"})
#This function is creating a delivery agent that takes data sent to original topics and publish it on the pp2 respected topics
def on_messageForPP2Sub(client, userdata, msg):
    payload= msg.payload
    topic= str(msg.topic)
    topic= "pp2/"+ topic
    publishPP2.single(topic,payload=payload,hostname= broker, port= 8883, auth={'username':DA_username,'password':DA_pass}, tls={'ca_certs':"/ssl/ca.crt"})
#This function is creating a delivery agent that takes data sent to original topics and publish it on the pp3 respected topics
def on_messageForPP3Sub(client, userdata, msg):
    payload= msg.payload
    topic= str(msg.topic)
    topic= "pp3/"+ topic
    publishPP2.single(topic,payload=payload,hostname= broker, port= 8883, auth={'username':DA_username,'password':DA_pass}, tls={'ca_certs':"/ssl/ca.crt"})


def sub(i,mode):
    if mode ==0:
        subscribePP2.callback(on_messageForPP2Pub,i, hostname=broker, auth={'username':DA_username,'password':DA_pass}, port=8883, tls={'ca_certs':"/ssl/ca.crt"})
    elif mode ==1:
        subscribePP2.callback(on_messageForPP2Sub,i, hostname=broker, auth={'username':DA_username,'password':DA_pass}, port=8883, tls={'ca_certs':"/ssl/ca.crt"})
    elif mode ==2:
        subscribePP2.callback(on_messageForPP3Sub,i, hostname=broker, auth={'username':DA_username,'password':DA_pass}, port=8883, tls={'ca_certs':"/ssl/ca.crt"})
    else:
        raise Exception("Oooops something happened please try again")

PP2pub = threading.Thread(target=sub, args=(TopicPP2Pub,0)) 
PP2pub.start()

PP2sub = threading.Thread(target=sub, args=(TopicPP2Sub,1)) 
PP2sub.start()

sub(TopicPP3Sub,2)


