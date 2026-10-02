#!/bin/sh
# Lab 3 — show the exit code of several commands

true;                            echo "true                   -> $?"
false;                           echo "false                  -> $?"
ls / > /dev/null;                echo "ls /                   -> $?"
ls /nope 2> /dev/null;           echo "ls /nope               -> $?"
grep -q root /etc/passwd;        echo "grep root /etc/passwd  -> $?"
grep -q nobody-xyz /etc/passwd;  echo "grep nobody-xyz        -> $?"
