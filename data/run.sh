#!/usr/bin/with-contenv bashio
# ==============================================================================
# MPO: MQTT-Based Privacy Orchestrator
# ==============================================================================
ACLFILE=/share/mosquitto/accesscontrollist
SSLFILE=/ssl/ca.crt
PP2PUB=$(bashio::config 'pp_two_publish')
PP2SUB=$(bashio::config 'pp_two_subscribe')
PP3SUB=$(bashio::config 'pp_three_subscribe')
IOTPUB=$(bashio::config 'IoTDevices_Publish')
IOTSUB=$(bashio::config 'IoTDevices_Subscribe')
CONFIG=$(bashio::addon.options)
declare -a USERS
declare -a DelUsers
declare ACLTOPICS #this is for IoT devices given by the MPO's owner

Delivery_Agent="DAMQTT"
BrokerIP=$(bashio::api.supervisor GET /network/info) 
BrokerIP=$(echo "$BrokerIP" | jq -r '.interfaces[].ipv4.address[]' | sed 's/\/.*//')


MosquittoOptions=$(bashio::addon.options 'core_mosquitto')
activeOption='true'

certfileName=$(bashio::jq "${MosquittoOptions}" ".certfile")
keyfileName=$(bashio::jq "${MosquittoOptions}" ".keyfile")
cafileName=$(bashio::jq "${MosquittoOptions}" ".cafile")


function check_dup() {
    local Dup=$1

    if [[ "$Dup" != '' ]]; then
    bashio::log.notice "${Dup} already selected for another IoT device. Please select a different name"
    exit 0
    fi
}


function add_users() {
    local -a users=("$@")
    local length=${#users[@]}
    for (( i=0; i < "$length"; i++ )); do
        user=${users[i]}
        pass="$(pwgen -s 16)"
        NewUser='.logins[.logins | length] |= . + {"username": "'"$user"'", "password": "'"$pass"'"}'
        if  bashio::jq "${MosquittoOptions}" ".logins[].username" | grep -qiF "${users[i]}"; then
             bashio::log.notice "user ${users[i]} exists"
        else
            if bashio::jq.exists "${MosquittoOptions}" ".logins"; then
                MosquittoOptions=$(bashio::jq "${MosquittoOptions}" "${NewUser}")
            else
                bashio::log.error "Oooops something went wrong. Cant add a new user to Mosquitto"
            fi
                MosquittoOptions=$(bashio::jq "${MosquittoOptions}" ".customize.active=${activeOption}")
                bashio::api.supervisor POST "/addons/core_mosquitto/options" "$(bashio::var.json options "^${MosquittoOptions}")"

            bashio::log.info "user ${users[i]} added"
        fi  
    done
}

function Del_users() {
    local -a users=("$@")
    local length=${#users[@]}
    for (( i=0; i < "$length"; i++ )); do
        user=${users[i]}
        DelUser='del(.logins[] | select(.username=='\"$user\"'))'
        MosquittoOptions=$(bashio::jq "${MosquittoOptions}" "${DelUser}")
    done
    bashio::api.supervisor POST "/addons/core_mosquitto/options" "$(bashio::var.json options "^${MosquittoOptions}")"
}

#The following lines are for creating the ACL files for the Mosquitto Broker on Home Assistant if it doesnt exist
if ! bashio::fs.file_exists "${ACLFILE}"; then
    bashio::log.info "Creating ACL file on Mosquitto"
    mkdir /share/mosquitto
    cd /share/mosquitto
    touch acl.conf
    echo "acl_file /share/mosquitto/accesscontrollist" > acl.conf
    touch accesscontrollist
    echo "topic readwrite #" > accesscontrollist
    bashio::log.info "ACL Successfully created"
    cd ../.. 
else
    bashio::log.info "Mosquitto has an active access control list"
fi

#Check wehther accounts for privacy profile1,2,3 exist on Home Assistant
HA_Accounts=/config/.storage/auth_provider.homeassistant
Accounts=$(jq -r --raw-output '.data.users[].username' $HA_Accounts)
if echo "$Accounts" | grep -qiF privacyPrOFilE1; then 
  bashio::log.info "Found PrivacyProfile1 on Home Assistant"
    if echo "$Accounts" | grep -qiF privacyPrOFilE2; then
        bashio::log.info "Found PrivacyProfile2 on Home Assistant"
    else
        bashio::log.error "please create an account for Privacy Profile2 on Home Assistant"
        exit 0
    fi
    if echo "$Accounts" | grep -qiF privacyPrOFilE3; then
        bashio::log.info "Found PrivacyProfile3 on Home Assistant"
    else
        bashio::log.error "please create an account for privacyprofile3 on Home Assistant"
        exit 0
    fi
else
    bashio::log.error "Please create an account for privacyprofile1 on Home Assistant"
    exit 0
fi

#The following lines set up MQTT with TLS in The configuration. yaml file for users to use.
if ! grep -q "port: 8883" /config/configuration.yaml; then      #This if statement is used to prevent MPO from duplicating MQTT-TLS lines in the Configuration.yaml file
    echo -e "\nmqtt:" >> /config/configuration.yaml
    echo -e "    certificate: /ssl/ca.crt" >> /config/configuration.yaml
    echo -e "    broker: ${BrokerIP}" >> /config/configuration.yaml
    echo -e "    port: 8883" >> /config/configuration.yaml
    echo -e "    username: PrivacyProfile1" >> /config/configuration.yaml
    echo -e "    password: YourPP1pass" >> /config/configuration.yaml
fi


#The following lines write prefectly to the ACL file in Mosquitto in Home Assistant
echo -e "user PrivacyProfile1\ntopic readwrite #" > /share/mosquitto/accesscontrollist
echo -e "\nuser PrivacyProfile2\ntopic readwrite pp2/#" >> /share/mosquitto/accesscontrollist
echo -e "\nuser PrivacyProfile3\ntopic read pp3/#" >> /share/mosquitto/accesscontrollist
echo -e "\nuser ${Delivery_Agent}\ntopic readwrite #" >> /share/mosquitto/accesscontrollist

#Extract the name of IoT devices provided by the user and Check For duplicate Names
PubName=$(echo "$CONFIG" | jq --raw-output '.IoTDevices_Publish[].name')
SubName=$(echo "$CONFIG" | jq --raw-output '.IoTDevices_Subscribe[].name') 

DupPub=$(echo "$PubName" | grep -wo "[_[:alnum:]]\+" | sort -f | uniq -id)
DupSub=$(echo "$SubName" | grep -wo "[_[:alnum:]]\+" | sort -f | uniq -id)

#Check for duplicates
check_dup "${DupPub}"
check_dup "${DupSub}"


#the following lines combine users from IoTdevice publish and subscribe and then filter them
#To only add unique usernames on Mosquitto database
IoTNames=$(echo "$PubName" | grep -wo "[_[:alnum:]]\+" | sort | uniq),$(echo "$SubName" | grep -wo "[_[:alnum:]]\+" | sort | uniq) 
USERS=( $(echo "$IoTNames" | grep -wo "[_[:alnum:]]\+" | sort | uniq -iu) )
USERS+=( $(echo "$IoTNames" | grep -wo "[_[:alnum:]]\+" | sort -f | uniq -id ) )
USERS+=(${Delivery_Agent}) #To add delivery agent as a user in Mosquitto

#The following three lines extract current users from Mosquitto's Local database and delete any unused users
Mosusers=$(echo "$MosquittoOptions" | jq -r '.logins[].username')
DelUsers=( $(echo ${USERS[@]} ${Mosusers} | sed 's/\s/\n/g' | sort | uniq -iu ) )


Del_users "${DelUsers[@]}"
add_users "${USERS[@]}"

#The following lines are for TLS Implementation:
#List of states
declare -a city
declare -a state

city=(Alabama Alaska Arizona California Colorado Connecticut Delaware Florida Georgia Hawaii Idaho Illinois Indiana Kansas Kentucky  Maine Maryland Massachusetts Michigan Mississippi Montana Nebraska Ohio Oregon Pennsylvania Tennessee Texas Vermont Virginia Washington Wisconsin Wyoming)
state=(Montgomery Juneau Phoenix Sacramento Denver Hartford Dover Tallahassee Atlanta Honolulu Boise Springfield Indianapolis Topeka Frankfort Augusta Annapolis Boston Lansing Jackson Helena Lincoln Columbus Salem Harrisburg Nashville Austin Montpelier Richmond Olympia Madison Cheyenne)

#List of cities
#Pick 2 cities randomly
randCitSta1=$((0 + $RANDOM % 31))
randCitSta2=$((0 + $RANDOM % 30))
PassKey="$(pwgen 5)" #password for key encryption 
RandCom="$(pwgen 4)" #Random organizationl unit name for TLS


#The Following line enforces TLS communication on the Mosquitto Broker
if ! bashio::fs.file_exists "${SSLFILE}"; then
    { echo "$PassKey"; echo "$PassKey"; } | openssl genrsa -des3 -out ca.key 2048 >/dev/null 2>&1
    {  echo "$PassKey"; echo "US"; echo "${state[randCitSta1]}"; echo "${city[randCitSta1]}"; echo "'.'"; echo "$RandCom"; echo "$BrokerIP"; echo "'.'";} | openssl req -new -x509 -days 1096 -key ca.key -out ca.crt >/dev/null 2>&1

    unset city[randCitSta1] #To delete the chosen city so it cannot be selected anymore
    unset state[randCitSta1] #To delete the chosen state so it cannot be selected anymore
    RandCom="$(pwgen 4)"

    openssl genrsa -out server.key 2048 >/dev/null 2>&1
    {  echo "US"; echo "${state[randCitSta2]}"; echo "${city[randCitSta2]}"; echo "'.'"; echo "$RandCom"; echo "$BrokerIP"; echo "'.'";echo ""; echo "'.'"; } |openssl req -new -key server.key -out server.csr >/dev/null 2>&1   
    { echo "$PassKey";} |openssl x509 -req -in server.csr -extfile <(printf "subjectAltName=IP:$BrokerIP") -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 360 >/dev/null 2>&1
    cp /ca.crt /ssl
    cp /server.crt /ssl
    cp /server.key /ssl

    #The following lines change the names of the ssl files on the options of the Mosquitto Add-on
    if  bashio::jq "${MosquittoOptions}" | grep -qiF 'cafile'; then
        echo "cafile exists in Mosquitto options"
    else
        MosquittoOptions=$(echo "$MosquittoOptions" | sed 's/.$/ ,"cafile":"ca.crt"}/')
    fi
        MosquittoOptions=$(echo "$MosquittoOptions" | sed -e "s/$certfileName/server.crt/g" -e "s/$keyfileName/server.key/g" -e "s/$cafileName/ca.crt/g")
        bashio::api.supervisor POST "/addons/core_mosquitto/options" "$(bashio::var.json options "^${MosquittoOptions}")"
else
    bashio::log.info "SSL Files exist"
fi


#The following line is used to disable the port 1883
curl -X POST -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/addons/core_mosquitto/options  -H "Content-Type: application/json" -d '{"network":{"1883/tcp":null,"1884/tcp":1884,"8883/tcp":8883,"8884/tcp":8884}}' >/dev/null 2>&1


 ACLTOPICS=( $(echo "$IOTSUB" | jq -r 'walk( if type == "object"
      then with_entries( if .key != "name" then (.value |= "topic read " + .) else (.value |= "user " + .) end ) 
      else . end)') )
ACLTOPICS+=( $(echo "$IOTPUB" | jq -r 'walk( if type == "object"
      then with_entries( if .key != "name" then (.value |= "topic write " + .) else (.value |= "user " + .) end ) 
      else . end)') )    

#The following lines extract the ACL for the IoT devices, which are porvided by the user
ACLDevices=$(echo "${ACLTOPICS[@]}" | jq -rs 'group_by(.name) | .[][] | values[]' | awk '!(/^(user [_[:alnum:]]*)/ && seen[$0]++)')
echo -e "\n${ACLDevices}" >> /share/mosquitto/accesscontrollist
bashio::api.supervisor POST "/addons/core_mosquitto/restart"



###############################################################
#The following lines are for retreiving the credentials of an IoT device

RetUserActual=$(echo "$CONFIG" | jq --raw-output '.Device_Credentials')
if [[ "${RetUserActual}" != '' ]]; then
    CheckUser=$(echo "$MosquittoOptions" | jq '.logins' | jq '.[] | select(.username=='\"$RetUserActual\"')')
    if [[ "${CheckUser}" != '' ]]; then
        bashio::log.notice "the requested device credentials are: \n ${CheckUser}"
    else
        bashio::log.notice "${RetUserActual} is not registered. Please register this device in the IoTDevice_publish/Subscribe sections above"
    fi
else
    bashio::log.info "#####################################################"
fi

###############################################
#The following lines are used to send the proper variables to the python script of MPO which is utilized mainly for MPO's delivery agents
PP2ACLPub=$(echo "$PP2PUB" | sed 's/^/pp2\//' | sed 's/.*/&,/' | sed '$s/,//' | tr -d '\n')
PP2ACLSub=$(echo "$PP2SUB" | sed 's/.*/&,/' | sed '$s/,//' | tr -d '\n')
PP3ACLSub=$(echo "$PP3SUB" | sed 's/.*/&,/' | sed '$s/,//' | tr -d '\n')

DeliveryAgent_Pass=$(echo "$MosquittoOptions" | jq '.logins' | jq -r '.[] | select(.username=='\"$Delivery_Agent\"') | .password')

python3 mqttclient.py "$PP2ACLPub" "$PP2ACLSub" "$PP3ACLSub" "$Delivery_Agent" "$DeliveryAgent_Pass" "$BrokerIP" "${#USERS[@]}"

