#!/bin/bash

source common-functions.sh

init_out qemu-i40e-bm-pair $1
run_i40e_bm a
run_i40e_bm b
sleep 0.5
run_wire ab a b
run_qemu a a build/qemu-pair-i40e-server.tar
run_qemu b b build/qemu-pair-i40e-client.tar
client_pid=$!
wait $client_pid
cleanup
