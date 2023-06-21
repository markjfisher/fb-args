#!/bin/bash

# Example script to build application to show args
# Specific to my own setup with an ALTIRRA hard drive directory,
# And fujinet atr file mounted on real 800XL.

# Delete this line. It's here to protect people randomly running the
# script before setting it up correctly.
exit 1

# set your own paths here
FB="/home/fenrock/dev/atari/fastbasic/compiler/fb"
ALTIRRA_H1H6="/mnt/c/atari/Emulator/disks/h1-h6"

# compile with the assembly for reading args
$FB main.bas getargs-sdx.asm

# Clean up old atr directory.
rm -rf atr
mkdir atr
cp main.xex atr/test.xex
cp main.xex $ALTIRRA_H1H6/test.xex

# Create an ATR file out of the built xex file
dir2atr -D test.atr atr

# fujinet mounted ATR that will make the application appear
# on physical Atari in real time without having to restart it.
cp test.atr /mnt/c/atari/tnfsd/test.atr

# more clean up of assets
rm *.lst *.o *.lbl main.asm test.atr
rm -rf atr
