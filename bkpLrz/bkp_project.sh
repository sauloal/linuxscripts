#!/bin/bash
DIA=`date '+%Y-%m-%d'`
mkdir $DIA
echo "BACKING UP /VAR/PROJECTS/GENOME  ON $DIA"
tar -cvpjf $DIA/$DIA\_var_projects_Genome.tar.bz2 /var/projects/Genome

echo "BACKING UP /home/saulo/Desktop/blast  ON $DIA"
tar -cvpjf $DIA/$DIA\_home_saulo_desktop_blast.tar.bz2 /home/saulo/Desktop/blast

echo "BACKING UP /home/saulo/Desktop/Microarray  ON $DIA"
tar -cvpjf $DIA/$DIA\_home_saulo_desktop_microarray.tar.bz2 /home/saulo/Desktop/Microarray

echo "BACKING UP /home/saulo/Desktop  ON $DIA"
tar -cvpjf $DIA/$DIA\_home_saulo_desktop.tar.bz2 /home/saulo/Desktop --exclude /home/saulo/Desktop/Genome  --exclude /home/saulo/Desktop/blast  --exclude /home/saulo/Desktop/Microarray  --exclude /home/saulo/Desktop/debian 

#tar -ztvpf home.tar.gz --directory /home