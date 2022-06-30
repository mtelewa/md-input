# Molecular Dynamics simulation input files of either a fluid confined between solid walls or a bulk fluid

# Required packages:
* [Moltemplate](https://moltemplate.org/)
* [dtool](https://dtool.readthedocs.io/)
* [mpi4py](https://mpi4py.readthedocs.io/)
* [netCDF4](https://unidata.github.io/netcdf4-python/)
* [LAMMPS](https://www.lammps.org/)
* matplotlib
* numpy
* scipy

# Simulation template files:
* _header.LAMMPS_ contains unit conversions and constants, atomic data and simulation state parameters
* _system.in.groups_ contains solid and fluid group definitions (based on type) as well as the partitioning of the solid into upper and lower surfaces. It also contains a description of the dynamic pump group (in case of NEMD simulation)
* _system.in.init_ contains the initialization setup (`pair_style` and `atom_style` for LAMMPS)
* _system.in.loadUpper_ &rarr; stores the forces on the upper and lower wall before loading, also performs the loading on the upper wall, with the barostat described here (Tribol Lett (2010) 39:49–61)
* _system.in.settings_ contains the force field parameters for the fluid as well as LJ parameters for the solid
* _system.in.run_ contains the simulation instructions (equilibration, NEMD, etc.) as well as writing the thermodynamic output and the NetCDF trajectory.
* _system.in.virial_ samples the virial pressure calculation (along with the Voronoi volumes) during the simulation.

# Workflow:

1. **Initialize**: Run the python module _initialize\_walls_ (located in `home/tools/md`) in `equilib/data/moltemp` with the positional arguments. Usage:\
`initialize_walls.py nUnitsX nUnitsY nUnitsZ h density fluid code` \
Depending on the choice of code, the initialize_walls script will do either:
      * if `code` is `lammps` then the _init.LAMMPS_ file is modified according to the given parameters. It  will also create the _data.init_ file (LAMMPS data file) and move it to the `equilib\data\blocks` directory. The initialization is then performed by running LAMMPS.
      * if `code` is `moltemp` then a _geometry.lt_ file is created in the moltemp directory. This is the file with the system dimensions and topology, which is then imported by _system.lt_ in moltemplate.
      The _setup.sh_ bash script is then run and the initial atomic configuration is now created with all the simulation templates. It  will also create the _system.data_ file (LAMMPS data file) and move all the simulation files into `equilib\data\blocks`. \
      Inside the _setup_ script, the command used is \
      `moltemplate.sh -atomstyle full -overlay-bonds -overlay-angles -overlay-dihedrals -overlay-impropers system.lt` \
      The `-overlay-*` flags are required for cases where multiple bonded interactions involve the same atoms.\

The input files for equilibration are now ready and the `equilib` directory is to be rsynced to the cluster **NEMO**.

2. **Equilibrate**: The equilibration is performed by submitting as a batch job in the `equilib/data`. In this submission script, we run LAMMPS in parallel with the command \
`mpirun --bind-to core --map-by core -report-bindings lmp_mpi -in $(pwd)/equilib.LAMMPS `

3. **Load**: The output LAMMPS data file _data.nvt_ from the equilibration step `equilib/data/out` is copied to the input of the loading `load/data/blocks`. \
`cp equilib/data/out/data.force load/data/blocks` \
In the `load/data/blocks` directory, we have the `system.in.loadUpper` which loads the upper wall.
The main variable here is the `Pext` in the _header.LAMMPS_ file in the blocks.
A batch job can now be submitted to the cluster. The main content of the submission script is\
`mpirun --bind-to core --map-by core -report-bindings lmp_mpi -in $(pwd)/load.LAMMPS -v get_virial 1 -v Pext 100`
4. **Flow**: Now the final part in the MD calculation is to induce a flow on the atoms/molecules. This is performed either by simulating a pressure gradient or shearing.\
As for pressure gradient, we have the **Fixed Force(FF)** where we impose a fixed force field on a group of atoms or the **Fixed Current (FC)** where we impose a fixed center of mass velocity (or mass flux) field instead. The two ensembles are physically equivalent and they result in a Poiseuille flow.
For shearing the upper wall, fluid atoms flow due to the velocity gradient and we get a Couette flow.\
And indeed we want also want to simulate a Couette + Poiseuille flow.
    * Now we need to apply the flow on the already loaded structure data file _data.force_. We then copy the LAMMPS data file output from the loading simulation: \
    `cp load/data/out/data.force flow/data/blocks` \

    * We change the simulation parameters e.g. the applied pressure difference `pDiff` in the queue submission script, whether it is a FF or FC ensemble `ff 1` or `fc 1`. (Note that `ff 0` will not do a fc simulation and vice versa). If we simulate shearing then `couette 1`, in this case we need to specify a `vshear` variable. \
    An example of the command in the submission script is\
    `mpirun --bind-to core --map-by core -report-bindings lmp_mpi -in $(pwd)/flow.LAMMPS -v ff 1 -v pDiff 5e6`

5. **Post Processing**: The trajectories file format is based on the NetCDF (Network Common Data Form) developed by [Unidata](http://www.unidata.ucar.edu/software/netcdf/). The **NetCDF** trajectories can be analysed at any stage of the simulation process by [netCDF4](https://unidata.github.io/netcdf4-python/) which is a Python interface to the netCDF C library.

