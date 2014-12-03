#!/bin/bash

webdir=$HOME/www/readiness
# create output directory
mkdir -p $webdir
# copy css files
cp -r css/* $webdir/HTML 
./SiteReadiness.py -p $webdir -u $HOME/www -i input/ -x false #--oneSite T2_US_Caltech
