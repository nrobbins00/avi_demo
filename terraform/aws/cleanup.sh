#!/bin/bash

#check to see if API is responding
echo "checking API availability"
if `curl -s -k -u '${avi_username}:${avi_password}' https://localhost/api/systemconfiguration/ > /dev/null`; then

    #delete VS
    echo "Deleting virtual services"
    for i in `curl -s -k -u '${avi_username}:${avi_password}' https://localhost/api/virtualservice/ | json_pp | grep -i \"uuid\" | awk -F ':' '{print $2}' | sed 's/"//g' | sed 's/,//g'`; do
    curl -X DELETE -k -u '${avi_username}:${avi_password}' https://localhost/api/virtualservice/$i
    done

    #delete pools
    echo "Deleting pools"
    for i in `curl -s -k -u '${avi_username}:${avi_password}' https://localhost/api/pool/ | json_pp | grep -i \"uuid\" | awk -F ':' '{print $2}' | sed 's/"//g' | sed 's/,//g'`; do
    curl -X DELETE -k -u '${avi_username}:${avi_password}' https://localhost/api/pool/$i
    done

    #delete SEs
    echo "Deleting service engines"
    for i in `curl -s -k -u '${avi_username}:${avi_password}' https://localhost/api/serviceengine/ | json_pp | grep -i \"uuid\" | awk -F ':' '{print $2}' | sed 's/"//g' | sed 's/,//g'`; do
    curl -X DELETE -k -u '${avi_username}:${avi_password}' https://localhost/api/serviceengine/$i
    done

    ##sleep while SE cleanup happens
    #echo "Sleeping for SE cleanup"
    #sleep 4m

    #set cloud to no access
    echo "Deleting cloud"
    for i in `curl -s -k -u '${avi_username}:${avi_password}' https://localhost/api/cloud/?name=AWS-TerraformDemo | json_pp | grep -i \"uuid\" | awk -F ':' '{print $2}' | sed 's/"//g' | sed 's/,//g'`; do
    curl -X DELETE -k -u '${avi_username}:${avi_password}' https://localhost/api/cloud/$i
    done

    #sleep while cloud cleanup happens
    echo "Sleeping for cloud cleanup"
    sleep 4m
    exit 0

else
echo "API unavailable, exiting"
exit 0
fi



