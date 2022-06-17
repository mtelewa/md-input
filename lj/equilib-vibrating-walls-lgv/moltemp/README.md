# For gold:

* The _PDB_ file is output of [atomsk](https://atomsk.univ-lille.fr/) by running the command:
`atomsk --create fcc 4.08 Au orient [-12-1] [-101] [111] gold.pdb`

* The coordinates from _gold.pdb_ are then copied into _gold.lt_

# For pentane:

* The _pentane.lt_ file topology data comes from _pentane.mol_ file

# For the whole system:

* Both lt files are imported in _system.lt_. The _LAMMPS data_ file is obtained with:
	* For pentane `moltemp -atomstyle molecular system.lt`
	* For LJ `moltemp -atomstyle atomic system.lt`
