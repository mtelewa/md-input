#!/bin/bash
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=20
#SBATCH --time=2:00:00
#SBATCH --partition=multiple
#SBATCH --output=cluster.out
#SBATCH --error=cluster.err
#SBATCH --job-name=Pump
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mohamed.hassan@kit.edu

export KMP_AFFINITY=compact,1,0

module load compiler/intel/19.1
module load mpi/openmpi/4.0

# Attention:
# Do NOT add mpirun options -n <number_of_processes> or any other option defining processes or nodes, since MOAB instructs mpirun about number of processes and node hostnames. Moreover, replace <placeholder_for_version> with the wished version of Intel MPI to enable the MPI environment. 

mpirun --bind-to core --map-by core -report-bindings lmp_mpi -in $(pwd)/equilib.LAMMPS -v npt_fix 1 -v press 285
