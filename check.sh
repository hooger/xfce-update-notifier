#!/usr/bin/env bash
# This script is an update-notifier
# Its intended use is with xfce4-genmon-plugin

size=48
style=dragon
notify_time=5000
notification=0

DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
lock="$DIR/lock"
numberofpkgs=0

( flock -x 200

  if [ $(uname -r | sed -E "s:([0-9]*[\.-])*(.*):\2:") == "ARCH" ]
  then
      checkupdates > $DIR/pkgs
      numberofpkgs=$(grep -c ".*" $DIR/pkgs)
      rm -f $DIR/pkgs
  elif [ $(uname -a | sed -E "s#.*(Debian).*#\1#") == "Debian" ]
  then
      sudo apt-get update
      numberofpkgs=$(apt-get dist-upgrade -s |grep -c "^Inst ")
  fi

  if [ $numberofpkgs -eq 0 ]
  then
      echo "<img>$DIR/icons/${style}_green_$size.png</img>"
      echo "<tool>No pending upgrades</tool>"
  else
      echo "<img>$DIR/icons/${style}_red_$size.png</img>"
      echo "<tool>There are $numberofpkgs pending upgrades</tool>"
      if [ $notification -eq 1 ]
      then
	 notify-send -t $notify_time -i "$DIR/icons/${style}_red_$size.png" "Update notifier" "There are $numberofpkgs pending upgrades"
      fi
  fi

) 200> "$lock"
