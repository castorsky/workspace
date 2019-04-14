#!/bin/bash
#
#
# Message of the Day filename
MOTD="/etc/motd"

# Text Color Variables
BLK="\033[00;30m"    # BLACK
R="\033[00;31m"      # RED
GRN="\033[00;32m"    # GREEN
BR="\033[00;33m"     # BROWN
BL="\033[00;34m"     # BLUW
P="\033[00;35m"      # PURPLE
C="\033[00;36m"      # CYAN
LtG="\033[00;37m"    # LIGHT GRAY

DkG="\033[01;30m"    # DARK GRAY
LtR="\033[01;31m"    # LIGHT RED
LtGRN="\033[01;32m"  # LIGHT GREEN
Y="\033[01;33m"      # YELLOW
LtBL="\033[01;34m"   # LIGHT BLUE
LtP="\033[01;35m"    # LIGHT PURPLE
LtC="\033[01;36m"    # LIGHT CYAN
W="\033[01;37m"      # WHITE

RESET="\033[0m"

clear > $MOTD        # removes all text from /etc/motd

echo -e "" >> $MOTD
echo -e "" >> $MOTD
echo -e "" >> $MOTD
echo -e "" >> $MOTD
echo -e $W '                           '"########################" >> $MOTD
echo -e $W '                           '"#"$R "I Corinthians 15:1-4" $W"#" >> $MOTD
echo -e $W '                           '"########################" >> $MOTD
echo -e "" >> $MOTD
echo -e $C '                                '"Midacts Mystery" $RESET >> $MOTD
