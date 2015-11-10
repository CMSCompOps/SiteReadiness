#!/bin/sh

BASE=$(dirname $(readlink -f "${BASH_SOURCE[0]}"))
LOG=$BASE/log/sstInit.log
WEBDIR=/afs/cern.ch/user/c/cmssst/www/sreadiness
LINK=http://cms-site-readiness.web.cern.ch/cms-site-readiness
CSS=css/
INPUT=input/
SSTMAIL="cms-comp-ops-site-support-team@cern.ch"

echo "Checking Kerberos ticket/AFS token:"
/bin/rm ${LOG} 1>/dev/null 2>&1
/usr/bin/klist 2> ${LOG}
RC=$?
if [ ${RC} -ne 0 ]; then
   MSG="no valid Kerberos ticket, klist=${RC}"
   echo "   ${MSG}"
   if [ -t 0 ]; then
      # attached terminal, prompt user to kinit for 25 hours
      /usr/bin/kinit -l 25h cmssst@CERN.CH
      if [ $? -ne 0 ]; then
         exit ${RC}
      fi
   else
      /usr/bin/Mail -s "$0 ${MSG}" ${SSTMAIL} < ${LOG}
      exit ${RC}
   fi
fi
/bin/rm ${LOG} 1>/dev/null 2>&1
/usr/bin/aklog 2> ${LOG}
RC=$?
if [ ${RC} -ne 0 ]; then
   MSG="unable to acquire AFS token, aklog=${RC}"
   echo "   ${MSG}"
   /usr/bin/Mail -s "$0 ${MSG}" ${SSTMAIL} < ${LOG}
   exit ${RC}
fi

# now, you can generate the report
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
