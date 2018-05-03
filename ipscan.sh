#!/bin/bash
ip scan test
echo -n "input network segment:"
read ipsegment
echo -n "input test website:"
read wed
ipsegment="121.194.86"
wed="gw.cugb.edu.cn"
if [[ $ipsegment =~ ^([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\.([0-9]{1,2}|1[0-9][0-9]|2[0-4][0-9]|25[0-5])$ ]]
then
    for((count=1;count<=255;count++))
    do
	ip="${BASH_REMATCH[1]}.${BASH_REMATCH[2]}.${BASH_REMATCH[3]}.$count"
    nmcli connection modify "eno1" ipv4.addresses $ip > /dev/null
    nmcli connection up eno1 > /dev/null
	result=`curl -I -o /dev/null -s -w %{http_code} $wed`
	if [ $result -gt 200 ]
	then
        echo $ip
	    echo $ip >> ip.txt
	fi
    done
else
    echo "invalid ip"
fi
