#!/bin/sh

# Run Moltemplate
moltemp='/home/mohamed/programs/moltemplate/moltemplate/scripts/moltemplate.sh'
$moltemp system.lt -atomstyle molecular -overlay-bonds -overlay-angles -overlay-dihedrals -overlay-impropers

rm -r output_ttree
mv system.in.* ../blocks
mv system.data ../blocks

# Move the files to blocks dir
sed -i "s/system/blocks\/system/g" system.in

# Swap the settings and group sections
printf '%s\n' 12m17 17-m12- w q | ed -s system.in
printf '%s\n' 14m19 19-m14- w q | ed -s system.in
# Swap the run and sample sections
printf '%s\n' 22m27 27-m22- w q | ed -s system.in
printf '%s\n' 24m29 29-m24- w q | ed -s system.in

# Comment the virial section (it is already included in the run section)
sed -i -e "/virial/s/^#*/#/" system.in

mv system.in ../equilib.LAMMPS
