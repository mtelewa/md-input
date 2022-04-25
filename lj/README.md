
#Equilibration

One needs a **data.init** (LAMMPS data file) that is obtained from initializing the system with the python module initialize\_<>.py

* To initialize a system of confined fluid with walls run ```initialize_walls.py <args>```
* To initialize a bulk system with walls run ```initialize_bulk.py <args>```

Running the script will build the LAMMPS box with the required geometry.
Then Run LAMMPS (option in the python module) ```mpirun -np 8 lmp_mpi init.LAMMPS``` to create the data file in the blocks directory.
This can be also done from the python script, just type 'y' when asked to run LAMMPS.

# Loading the Upper wall

To preform the loading, one needs a **data.nvt** that is obtained from the previous equilibration step.

# NEMD simulaion

The final step in the simulation. Could be a simualtion of shear-driven, pressure-driven or both. One needs a **data.force** from the loading.

# General Notes

The fluid interact with the walls with the truncated LJ potential or the WCA potential. This defines a fluid slipping against the walls.
To change that, in 'system.in.settings', remove the 3.82 to simualte the full LJ potential or change the pair coeffs parameters.
