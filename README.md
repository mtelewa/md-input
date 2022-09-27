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
* _header.LAMMPS_: contains unit conversions and constants, atomic data and simulation state parameters
* _system.in.groups_: contains solid and fluid group definitions (based on type) as well as the partitioning of the solid into upper and lower surfaces. It also contains a description of the dynamic pump group (in case of NEMD simulation)
* _system.in.init_: contains the initialization setup (`pair_style` and `atom_style` for LAMMPS)
* _system.in.loadUpper_: stores the forces on the upper and lower wall before loading, also performs the loading on the upper wall, with the barostat described here (Tribol Lett (2010) 39:49–61)
* _system.in.settings_: contains the force field parameters for the fluid as well as LJ parameters for the solid
* _system.in.run_: contains the simulation instructions (equilibration, NEMD, etc.) as well as writing the thermodynamic output and the NetCDF trajectory.
* _system.in.virial_: samples the virial pressure calculation (along with the Voronoi volumes) during the simulation.

# Workflow:

1. **Initialize**: Run the python module _initialize\_walls_ (located in `home/tools/md`) in `equilib/data/moltemp` with the positional arguments.

2. **Equilibrate**: The equilibration is performed by submitting as a batch job in the `equilib`.

3. **Load**: The output LAMMPS data file _data.nvt_ from the equilibration step `equilib/out` is copied to the input of the loading `load/blocks`.

4. **Flow**: Now the final part in the MD calculation is to induce a flow on the atoms/molecules. This is performed either by simulating a pressure gradient or shearing or both.

5. **Post Processing**: The trajectories file format is based on the NetCDF (Network Common Data Form) developed by [Unidata](http://www.unidata.ucar.edu/software/netcdf/). The **NetCDF** trajectories can be analysed at any stage of the simulation process by [netCDF4](https://unidata.github.io/netcdf4-python/) which is a Python interface to the netCDF C library.

6. **Plotting**
