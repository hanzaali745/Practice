#!/bin/sh
# Lab 1 — greeter
printf "Your name: "
read -r name
printf "Your team [DevOps]: "
read -r team
team="${team:-DevOps}"
echo "Welcome ${name:-stranger} from the $team team! Today is $(date '+%A %d %B')."
