# Initialization of an n-alkane fluid confined between solid walls with Moltemplate

## Initialize the atom/molecule:

* **For gold walls**: The _PDB_ file is the output of [atomsk](https://atomsk.univ-lille.fr/) by running the command:\
`atomsk --create fcc 4.08 Au orient [-12-1] [-101] [111] gold.pdb`
The coordinates from _gold.pdb_ are then written into _gold.lt_. Now we have **one unit cell** of gold at the desired orientation.

* **For n-alkane fluid:**: The _\<alkane>.lt_ file contains the atomic coordinates and topological information needed to build **one molecule**.
The file is also written by hand from the _\<alkane>.mol_ file.


## Few notes on moltemplate syntax

* An explanation of the commands used in the _lt_ files is in chapter 5 in the [documentation](https://moltemplate.org/doc/moltemplate_manual.pdf). This will clear the `write()` and `write_once` commands as well as the counter variables `@` and `$`.

* On writing _lt_ files by hand, Andrew Jewett responded to some questions regarding that, [here](https://sourceforge.net/p/lammps/mailman/message/36098237/) and [here](https://sourceforge.net/p/lammps/mailman/message/36049205/).

## Initialize the whole system:

* Individual molecules are now in the separte _lt_ files and can be grouped together by importing them in the _geometry.lt_. In this file we replicate the atoms/molecules and set an offset between them with the `move` command i.e. get the initial atomic configuration.
Note that for solids, the correct distance distance would be the unit length of the lattice vector in the corresponding direction.

Technically, this is the file that will write the LAMMPS data file. So, you can add some required arguments like bond, angle and dihedral coefficients to your individual _lt_ files (uncomment the commented lines in the separate lt files) and that would be the full toplogical information. Just run
`moltemplate.sh -overlay-bonds -overlay-angles -overlay-dihedrals -overlay-impropers -atomstyle moelcular geometry.lt`

This will generate the LAMMPS datafile, then you can run LAMMPS normally by writing your script as usual, just prepend it with `read_data <data file>` command. **OR**

* You can generate the whole input within moltemplate and this is where _system.lt_ file is needed. This file imports the geometry and adds the simulation settings needed for the LAMMPS MD simulation so that moltemplate writes it for you. This is the route i took here, for less exhausting trouble-shooting.


## Usage:

1. Run the python module _initialize\_Moltemp\_walls_ (from `tools` dir) inside the `moltemp` dir with the positional arguments.
`initialize_moltemp_walls.py nUnitsX nUnitsY nUnitsZ h mFluid density` \
The main variables here are number of gold unit cells `nUnits`, gap height `h`, fluid's molecular mass `mFluid` and `density`\
This will create the _geometry.lt_ file with the system dimensions and topology.

2. Run the `setup.sh` bash script. \
Inside the _setup_ bash script, the command used is \
`moltemplate.sh -atomstyle full -overlay-bonds -overlay-angles -overlay-dihedrals -overlay-impropers system.lt` \
The `-overlay-*` flags are required for cases where multiple bonded interactions involve the same atoms.
This will create the input files needed to run a LAMMPS simulation:
    * _system.in.init_ &rarr; initialization setup (BC, atom_style, pair_style, etc.)
    * _system.in.settings_ &rarr; force field parameters (pair, bond & dihedral coefficients)
    * _system.in.groups_ &rarr; regions and groups within the MD box
    * _system.in.run_ &rarr; simulation conditions (NVT/NVE, timestep, fixes, etc.)  
    * _system.in.virial_ &rarr; computes the virial expression
    * _system.data_; LAMMPS data file

    The _setup_ script will also modify the simulation header file and will copy all the simulation files (including LAMMPS data file _system.data_) into `equilib\data\blocks`. The input files for equilibration are now ready and the `equilib` directory is to be rsynced to the cluster **NEMO**.
