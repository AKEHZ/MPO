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
You can install MPO on your Home Assistant via (Supervisor &#8594; Add-on Store &#8594; Repositories). Then, copy the the MPO’s repositroy link and past it for installation to begin: 
```https://github.com/AKEHZ/MPO```

![one](https://user-images.githubusercontent.com/17085923/139114999-cc79e459-c7c8-4701-9529-50abdcefde0c.png)
![two](https://user-images.githubusercontent.com/17085923/139115054-09d76ca8-440f-4a81-a2a9-c09ba8029e81.png)

## Before using MPO for the first time
Create three user accounts on Home Assistant for the three privacy profiles (only required for the first time).  You can create these accounts by clicking "Configuration &#8594; users &#8594; ADD USER" .
![ConfigurationUsers](https://user-images.githubusercontent.com/17085923/139117262-e76e67d3-918f-40b2-bf41-eddf6b758fbb.png)
![AddUSERS](https://user-images.githubusercontent.com/17085923/139969447-e98f789d-0ba0-4076-8d9b-a56411f6c2e0.png)

> <span style="color:red">**_NOTES:_**</span>
 * This step allows for Home Assistant to authenticate the three privacy profiles. Once you create these user accounts, you can give the usernames and passwords of PrivacyProfile 2 and 3 to those you want to allow to access your MQTT data (e.g. partner, roomates, kids, guests). 
 * If you don't see "Users" option after you click on Configuration, then go to Your [Profile page](http://homeassistant.local:8123/profile) and enable "Advanced Mode".

See [documentation](DOCS.md) for more details. 