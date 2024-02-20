#!/bin/bash

# set path
logPath=$1

# set target IP
kubectl get svc | grep nginx-thrift |  awk '/[[:space:]]/ {print $4}' > target_url.txt

numOfThreads=10
connections=30
testDuration=60
requestPerSecond=( 100 200 300 400 )

targetIP=`cat target_url.txt`
hostPath="http://$targetIP:8080"

echo ====== Social Benchmark Start ======

timestamp=`date`
echo [Result] $timestamp >> $logPath/output.log
echo [Ratio] ${ratio[0]} ${ratio[1]} ${ratio[2]} >> $logPath/output.log
echo Current Pod Status >> $logPath/output.log
kubectl get pod >> $logPath/output.log

testCnt=0
for rps in ${requestPerSecond[@]}
do
    ((testCnt=testCnt+1))
    users=$((${rps}))
    echo
    echo \#Test ${testCnt}
    echo " " >> $logPath/output.log

    timestamp=`date`
    echo [Test ${i}] $timestamp >> $logPath/output.log

    echo Threads: $numOfThreads
    echo "Test Duration(s)": $testDuration
    echo Connections: $connections
    echo Request per Second: $rps
    ../../wrk2/wrk -D fixed -t ${numOfThreads} -c ${connections} -d ${testDuration}s -R ${rps} -r -s ./../wrk2/scripts/social-network/mixed-workload.lua ${hostPath} --latency -H 'Connection: close' >> $logPath/output.log 

    echo "///////////////////////////////////////////" >> $logPath/output.log
    kubectl top pod >> $logPath/output.log 

    echo "///////////////////////////////////////////" >> $logPath/output.log
    kubectl get horizontalpodautoscalers.autoscaling >> $logPath/output.log 

    echo "///////////////////////////////////////////" >> $logPath/output.log
    kubectl get pod >> $logPath/output.log
done

timestamp=`date`
echo
echo Test End $timestamp >> $logPath/output.log

echo ====== Social Benchmark Done ======
