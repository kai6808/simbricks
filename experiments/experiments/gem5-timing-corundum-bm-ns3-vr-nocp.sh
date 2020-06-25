#!/bin/bash

source common-functions.sh

init_out gem5-timing-corundum-bm-ns3-vr-nocp $1

# first run to checkpoint with fast CPU
run_corundum_bm c0
run_corundum_bm r0
run_corundum_bm r1
run_corundum_bm r2
sleep 0.5
run_ns3_sequencer vr "c0" "r0 r1 r2"
run_gem5 r0 r0 build/gem5-vr-replica-0-cp.tar TimingSimpleCPU r0
sleep 60
run_gem5 r1 r1 build/gem5-vr-replica-1-cp.tar TimingSimpleCPU r1
run_gem5 r2 r2 build/gem5-vr-replica-2-cp.tar TimingSimpleCPU r2
sleep 60
run_gem5 c0 c0 build/gem5-vr-client-cp.tar TimingSimpleCPU c0
client_pid=$!
wait $client_pid
cleanup
