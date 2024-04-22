#!/bin/bash

# set path
logPath=$1

# set target IP
kubectl get svc | grep nginx-thrift |  awk '/[[:space:]]/ {print $4}' > target_url.txt

numOfThreads=30
connections=50
testDuration=10
requestPerSecond=(
        100	    100	    100	    100	    100	    100	    #0
        120	    120	    140	    160	    180	    200	    #20
        200	    240	    280	    320	    360	    400	    #40
        400	    460	    520	    580	    640	    700	    #60
    )

#requestPerSecond=( 
#        100 100 100 100 100 100 
#        200 200 200 200 200 200 
#        400 400 400 400 400 400 
#        700 700 700 700 700 700
#)

targetIP=`cat target_url.txt`
hostPath="http://$targetIP:8080"

echo ====== Social Benchmark Start ======

timestamp=`date`k
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
    echo [Test ${testCnt}] $timestamp >> $logPath/output.log

    echo Threads: $numOfThreads
    echo "Test Duration(s)": $testDuration
    echo Connections: $connections
    echo Request per Second: $rps
    ../../wrk2/wrk -D fixed -t ${numOfThreads} -c ${connections} -d ${testDuration}s -R ${rps} -T 10s  -r -s ./../wrk2/scripts/social-network/mixed-workload.lua ${hostPath} --latency -H 'Connection: close' >> $logPath/output.log 

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
