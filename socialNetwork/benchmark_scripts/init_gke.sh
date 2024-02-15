#!/bin/bash

echo ====== Start ======
echo "Delete old objects"
echo "Wait for 10 minutes to scale in"
sleep 300
kubectl delete horizontalpodautoscalers.autoscaling --all=true --now=true --wait=true
helm uninstall social-network --wait


echo 1. Install helm package
helm install social-network --wait ./../helm-chart/socialnetwork/
echo "Wait for 10 minutes for initialization"
sleep 120

baseLogPath=./log
currentTime=`date +"%m-%d_%H%M%S"`
mkdir $baseLogPath/$currentTime
logPath=$baseLogPathPath/$currentTime

echo 2. Run Log
./log.sh $logPath & log=$!

echo 3. Run Benchmark
if [ "$1" = "c" ]; then
    python3 socialnetwork.py & p=$!
fi  
./run_social_benchmark.sh $logPath

kill -9 $log
echo ====== Done ======