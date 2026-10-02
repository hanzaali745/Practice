#!/usr/bin/env bash
# Lab 1 — greeter
read -r -p "Your name: " name
read -r -p "Your team [DevOps]: " team
team="${team:-DevOps}"
echo "Welcome ${name:-stranger} from the ${team} team! Today is $(date +%A\ %d\ %B)."
