#!/bin/sh

#===================================================================================================================================================================
# This script is used to get some data for the homey app where xmlHttpRequest is not possible
# The app is started from the TSC script
#
# Version: 1.0  - oepi-loepi - 29-3-2023
#
#===================================================================================================================================================================

#VERSION-1#

# Start

echo "$(date '+%d/%m/%Y %H:%M:%S') TSC script instructed me to do some homey"
	if [ -s /var/tmp/homey_log.txt ]
	then
		if [ ! -d "/qmf/www/homey" ]
		then
			mkdir /qmf/www/homey
		fi
		
		cp /var/tmp/homey_log.txt  /qmf/www/homey/homey.download
		rm -f /var/tmp/homey_log.txt

	fi











