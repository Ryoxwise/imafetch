#!/bin/bash

function ctrl_c(){
	echo -e "\n\n[!] Program has been terminated by the user\n"
	exit 2
}

trap ctrl_c INT

function fetch(){

}


