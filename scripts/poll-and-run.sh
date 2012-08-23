#!/bin/sh
java -Drunnerclass=JythonRunner -Duser.name=rdv -jar tzar.jar pollandrun \
    --dburl "jdbc:postgresql://rdv1:5432/tzar1?user=postgres&password=rdv_admin" \
    --svnurl="https://rdv-framework.svn.sourceforge.net/svnroot/rdv-framework/trunk/framework2/rdv" \
    --scpoutputhost=rdv4 \
    --scpoutputpath=output_global
