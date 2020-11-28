#!/bin/sh -e

# Script is based on following Authors work:

# Title:         Retrieve Plex Token                                    #
# Author(s):     Werner Beroux (https://github.com/wernight)            #
# URL:           https://github.com/wernight/docker-plex-media-server   #
# Description:   Prompts for Plex login and prints Plex access token.   #
#########################################################################

clientid=1

echo "Plex Username"; read PLEX_LOGIN
echo "Plex password"; read PLEX_PASSWORD
echo "Registering device name"; read plexdevice

while [ -z "$PLEX_LOGIN" ]; do
    >&2 echo -n 'Your Plex login (e-mail or username): '
    read PLEX_LOGIN
done

while [ -z "$PLEX_PASSWORD" ]; do
    >&2 echo -n 'Your Plex password: '
    read PLEX_PASSWORD
done

>&2 echo 'Retrieving a X-Plex-Token using Plex login/password...'

curl -qu "${PLEX_LOGIN}":"${PLEX_PASSWORD}" 'https://plex.tv/users/sign_in.xml' \
    -X POST -H "X-Plex-Device-Name: $plexdevice" \
    -H 'X-Plex-Provides: server' \
    -H 'X-Plex-Version: 1.0' \
    -H 'X-Plex-Platform-Version: 1.0' \
    -H 'X-Plex-Platform: Plex Web' \
    -H 'X-Plex-Product: Plex Media Server'\
    -H 'X-Plex-Device: Linux'\
    -H "X-Plex-Client-Identifier: xxx-$clientid" --compressed >/tmp/plex_sign_in
X_PLEX_TOKEN=$(sed -n 's/.*<authentication-token>\(.*\)<\/authentication-token>.*/\1/p' /tmp/plex_sign_in)
if [ -z "$X_PLEX_TOKEN" ]; then
    cat /tmp/plex_sign_in
    rm -f /tmp/plex_sign_in
    >&2 echo 'Failed to retrieve the X-Plex-Token.'
    exit 1
fi
rm -f /tmp/plex_sign_in

>&2 echo "Your X_PLEX_TOKEN:"

echo $X_PLEX_TOKEN

#Increase clientid to ensure no overlaping clients\scripts
location="${BASH_SOURCE[0]}"
newclientid=$((clientid+1))
echo "Updating Next Client ID: $newclientid"
sed -i "/^clientid=/c\clientid=$newclientid" $location
