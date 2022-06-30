#!/bin/bash
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=20
#SBATCH --time=72:00:00
#SBATCH --partition=multiple
#SBATCH --output=cluster.out
#SBATCH --error=cluster.err
#SBATCH --job-name=Pump
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=mohamed.hassan@kit.edu

export KMP_AFFINITY=compact,1,0

module load compiler/intel/19.1
module load mpi/openmpi/4.0

mpirun --bind-to core --map-by core singularity run --bind /scratch --bind /tmp --pwd=$PWD $HOME/programs/lammps.sif -i $(pwd)/flow.LAMMPS
