#!/bin/bash

path=`which python3`

python3 -m ensurepip --upgrade

pip3 install numpy

pip3 install pillow

echo "Enter Maya version (ValidationTool supports Maya2020 or later)"
read VERSION

usd=$USER
dir="/Users/"
dir+=$usd
dir+="/Library/Preferences/Autodesk/maya/"
dir+=$VERSION
dir+="/prefs/"



if [ -d $dir ] 
then
    parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
    dest=$dir"/scripts/ValidationTool"
    cp -R $parent_path"/scripts/" $dest
    echo -n $path >$dest"/pythonpath.txt"

    dest2=$dir"icons/robloxValidationTool.png"
    cp $parent_path"/icon/robloxValidationTool.png" $dest2

    echo "Scripts are installed." 

else
    echo "Error: Directory /path/to/dir does not exists."
fi