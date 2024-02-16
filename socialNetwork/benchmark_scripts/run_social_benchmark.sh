#!/bin/bash

# set path
logPath=$1

# set target IP
kubectl get svc | grep nginx-thrift |  awk '/[[:space:]]/ {print $4}' > target_url.txt

numOfThreads=5
requestPerSecond=10
testDuration=60
connections=( 10 20 30 40 )

targetIP=`cat target_url.txt`
# testAPI="http://$ip:8080/wrk2-api/post/compose"
# compose_url="http://$ip:8080/wrk2-api/post/compose"
# home_url="http://$ip:8080/wrk2-api/home-timeline/read"
# user_url="http://$ip:8080/wrk2-api/user-timeline/read"

# echo TEST APIs
# echo $home_url
# echo $user_url
# echo $compose_url
# echo " "

echo ====== Social Benchmark Start ======

timestamp=`date`
echo [Result] $timestamp >> $logPath/output.log
echo [Ratio] ${ratio[0]} ${ratio[1]} ${ratio[2]} >> $logPath/output.log
echo Current Pod Status >> $logPath/output.log
kubectl get pod >> $logPath/output.log

testCnt=0
for conn in ${connections[@]}
do
    ((testCnt=testCnt+1))
    users=$((${conn}))
    echo Test ${testCnt}
    echo " " >> $logPath/output.log

    conn_compose=$((${conn} * ${ratio[0]}))
    conn_user=$((${conn} * ${ratio[1]}))
    conn_home=$((${conn} * ${ratio[2]}))
    reuqest_compose=$((${conn} * ${ratio[0]} * 2))
    reuqest_user=$((${conn} * ${ratio[1]} * 2))
    reuqest_home=$((${conn} * ${ratio[2]} * 2))
    echo Requests of Compose: $((${reuqest_compose})) 
    echo Requests of User: $((${reuqest_user}))
    echo Requests of Home: $((${reuqest_home}))

    timestamp=`date`
    echo [Test ${i}] $timestamp >> $logPath/output.log

    ../../wrk2/wrk -D fixed -t${numOfThreads} -c${conn} -d${testDuration} -R${conn} -r -s ./../wrk2/scripts/social-network/mixed-workload.lua --latency -H 'Connection: close' >> $logPath/output.log 

    kubectl top pod >> echo "///////////////////////////////////////////"
    kubectl top pod >> $logPath/output.log 
    kubectl top pod >> echo "///////////////////////////////////////////"
    kubectl get horizontalpodautoscalers.autoscaling >> $logPath/output.log 
    kubectl top pod >> echo "///////////////////////////////////////////"
    kubectl get pod >> $logPath/output.log 

done

timestamp=`date`
echo Test End $timestamp >> $logPath/output.log
echo ====== Social Benchmark Done ======
