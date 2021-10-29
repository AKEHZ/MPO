# MQTT-Based Privacy Orchestrator (MPO)

## How to use
### Before using MPO for the first time
Create three user accounts on Home Assistant for the three privacy profiles (only required for the first time).  You can create these accounts by clicking "Configuration &#8594; users &#8594; ADD USER" .
![ConfigurationUsers](https://user-images.githubusercontent.com/17085923/139117262-e76e67d3-918f-40b2-bf41-eddf6b758fbb.png)
![AddUSERS](https://user-images.githubusercontent.com/17085923/139161862-35d7bef3-455e-4517-9b56-aa0fd30c1c9e.png)

> <span style="color:red">**_NOTE:_**</span> This step allows for Home Assistant to authenticate the three privacy profiles. Once you create these user accounts, you can give PrivacyProfile 2 and 3 usernames and passwords to those you want to allow to access your MQTT data (e.g. partner, roomates, kids, guests). 

### Configuration
```yaml
pp_two_publish:
pp_two_subscribe:
pp_three_subscribe:
IoTDevices_Publish:
IoTDevices_Subscribe:
Device_Credentials:
```
* **pp_two_publish** (**Optional**):
This option allows PrivacyProfile2 (pp2) users to control some of your MQTT devices by publishing MQTT messages.

```yaml
Example:
pp_two_publish:
 - camera/scan
 - bulb/set
```

* **pp_two_subscribe** (**Optional**):
This option allows PrivacyProfile2 (pp2) users to subscribe to some of your MQTT devices' topics.

```yaml
Example:
pp_two_subscribe:
 - bulb/status
 - lock/status
```

* **pp_three_subscribe** (**Optional**):
This option allows PrivacyProfile3 (pp3) users to subscribe to some of your MQTT devices' topics.

```yaml
Example:
pp_three_subscribe:
 - lock/status
```

* **IoTDevices_Publish** & **IoTDevices_Subscribe**:
Each new IoT device has to be added into MPO. These two options will be used to specify the publish and subscribe topics for the new device. For example, you give a name for an IoT device (lock),  then you provide the publish and subscribe topics of the lock.

```yaml
Example:
IoTDevices_Publish:
 - name: lock
 topic1: lock/status
 topic2: lock/battery
```
```yaml
Example:
IoTDevices_Subscribe:
 - name: lock
 topic1: lock/set
```

> <span style="color:red">**_NOTE:_**</span>   The name for each IoT device has to be unique. For example, you can't add a new device with a name "lock" if you have used it before for another device. 

* **Device_Credentials**:
MPO generates and maintaines a username and password for all of your IoT devices so you can connect them to your broker using these credentials. You don't have to remember the credentials. You type the device's name in the "Device_Credentials" and then check MPO's log to see the credentials. See example below:

```yaml
Example:
Device_Credentials: lock
```
![lockpass](https://user-images.githubusercontent.com/17085923/139291357-c5786697-0d1a-4b2a-99ab-9b2bd9d156f4.png)

---
---

 <span style="color:red">**_FINAL NOTES:_** </span> 
 
 * PrivacyProfile2 users have to use pp2 at the begining of MQTT topics. For example, if a PrivacyProfile2 user was allowed to turn the bulb on/off on "bulb/power" topic, Then this user will send the on/off message to "pp2/bulb/power" topic. The same applies for privacy profile 3 user, which has to use pp3 at the begining of each topic.

| Profile      |  | Example        |
| :----------- | ----------- | :-----------:        |
| PrivacyProfile2:      | It has to use pp2/ before each topic they want to publish/subscribe to.       | pp2/lock/set        |
| PrivacyProfile3:   | It has to use pp3/ before each topic they want to subscribe to.       | pp3/bulb/status        |
*  We built the **IoTDevices_Publish** & **IoTDevices_Subscribe** options to prevent the possbility of __a malicious__ IoT device subscribing to topics it should not access or publishing on another device's topic. 

*  In MPO's log, You may notice "user DAMQTT added" or "user DAMQTT exists" messages. MPO generates this user and mostly uses it to deliver MQTT messages to pp2/# and pp3/# topics. We refer to it as " MPO's Delivery agent". 