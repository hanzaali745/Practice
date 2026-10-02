#!/bin/sh
# Lab 1 — UNSAFE on purpose. Run it and notice it carries on after every failure.
# (It only works inside a temp directory, so it's harmless.)

workdir=$(mktemp -d)
cd "$workdir" || exit 1
touch keep-me.txt

cd ./releases/old                      # fails: the directory doesn't exist
echo "Now in: $(pwd)  <- still in workdir, NOT releases/old!"
echo "Imagine 'rm -rf ./*' here... it would delete keep-me.txt"

echo "Using $UNDEFINED_VAR"            # typo'd variable → silently empty
grep "x" /nope | sort                  # pipeline fails, but the exit code comes from sort
echo "Script finished 'successfully' with exit code $?"
rm -rf "$workdir"
