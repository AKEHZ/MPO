# MQTT-Based Privacy Orchestrator (MPO)
## About
This add-on uses three privacy profiles to limit the access to your MQTT data for the smart devices you are using at your smart home. 
## Features
* Assists users in enforcing their privacy preferences through three privacy profiles

| Profile       | Access Level     | Who can use this profile? |
| :------------- | :----------: | :----------: |
|  PrivacyProfile1 | Full Access   | You as an owner of MPO and Home Assistant |
| PrivacyProfile2   | <ul><li>Subscribe to a few topics</li><li>Publish to a few topics</li></ul> | Someone you want to allow to control a few of your MQTT devices |
| PrivacyProfile3   | **Only** subscribe to a few topics | Someone you want to allow to **only** subscribe to MQTT topics |
* Implements and manages the Access Control List (ACL) for the Mosquitto’s broker
* Automatically enforces TLS communication between the broker and MQTT clients. Clients Can **only** connect via ___TLS___.
* Generates and maintains the credentials (username and password) of all IoT devices that will connect to the Mosquitto broker.
* Stores the credentials of IoT devices in the Mosquitto’s local database to allow the broker to authenticate the IoT devices.
* You as an **owner** of MPO and PrivacyProfile1 can update the topics for PrivacyProfile2 and PrivacyProfile3 at any time via MPO's configuration section.

## Installation
You can install MPO on your Home Assistant via (Configuration &#8594; Add-ons, Backups & Supervisor &#8594; Add-on Store &#8594; Repositories). Then, copy the the MPO’s repositroy link and past it for installation to begin: 
```https://github.com/AKEHZ/MPO```

![installMPO1](https://user-images.githubusercontent.com/17085923/148317269-15c5edbe-c8f7-4a47-aa00-42d70f30f135.png)
![installMPO2](https://user-images.githubusercontent.com/17085923/148317274-7ad77b85-564b-4727-811e-3e2421c63f55.png)
![installMPO3](https://user-images.githubusercontent.com/17085923/148477150-09f5b331-7820-4bb5-9810-72a97bfe463e.png)
![two](https://user-images.githubusercontent.com/17085923/139115054-09d76ca8-440f-4a81-a2a9-c09ba8029e81.png)

## Before using MPO for the first time
Create three user accounts on Home Assistant for the three privacy profiles (only required for the first time).  You can create these accounts by clicking "Configuration &#8594; People & Zones &#8594; Users &#8594; ADD USER" .
![ConfigurationUsers_New](https://user-images.githubusercontent.com/17085923/148314927-f414bfc7-97dd-4da0-8b93-b3b951f0ccca.png)
![AddUSERS](https://user-images.githubusercontent.com/17085923/139969447-e98f789d-0ba0-4076-8d9b-a56411f6c2e0.png)

> <span style="color:red">**_NOTES:_**</span>
 * This step allows for Home Assistant to authenticate the three privacy profiles. Once you create these user accounts, you can give the usernames and passwords of PrivacyProfile 2 and 3 to those you want to allow to access your MQTT data (e.g. partner, roomates, kids, guests). 
 * If you don't see "Users" option after you click on Configuration, then go to Your [Profile page](http://homeassistant.local:8123/profile) and enable "Advanced Mode".

See Documentation for more details. 