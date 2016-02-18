#!/bin/sh

BASE=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
LOG=$BASE/log/sstInit.log
WEBDIR=/afs/cern.ch/user/c/cmssst/www/sreadiness/SiteReadiness/
LINK=http://cms-site-readiness.web.cern.ch/cms-site-readiness
CSS=css/
INPUT=input/
SSTMAIL="cms-comp-ops-site-support-team@cern.ch"
cd $BASE

# create directory if not exists
if [ ! -d $WEBDIR/HTML/ ]; then
    mkdir -p $WEBDIR/HTML/
fi

# copy css files
cp $CSS/* $WEBDIR/HTML/

# Active links
echo "*** EnabledLinksFromPhEDExDataSrv.py ***"
python EnabledLinksFromPhEDExDataSrv.py -p $WEBDIR -u $LINK

# Site Readiness python
echo "*** SiteReadiness.py ***"
./SiteReadiness.py -p $WEBDIR -u $LINK -i $INPUT
# $link: address to use inside files for output links

# Usable sites for analysis
echo "*** UsableSites.py ***"
python UsableSites.py -p $WEBDIR -u $LINK
