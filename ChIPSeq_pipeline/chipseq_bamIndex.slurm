#!/bin/bash
#SBATCH --job-name=bamidx
#SBATCH --output=slurm.out
#SBATCH --error=slurm.err
#SBATCH --ntasks=8
#SBATCH --mem=60G
#SBATCH --partition=cpu-medium
#SBATCH --time=06:00:00
#SBATCH --mail-user="c.du@biology.leidenuniv.nl"
#SBATCH --mail-type="ALL"

# Adding [$SHELL] will give distinction between echo and script output
echo "[$SHELL] #### Starting Job"
# The SLURM_JOB_USER and SLURM_JOB_ID is automatically obtained from sbatch command
echo "[$SHELL] This is $SLURM_JOB_USER, job ID $SLURM_JOB_ID"

# Get start time
START_TIME=$(date +%s)
echo "[$SHELL] Started at: $(date)"

# Change language settings in case perl complains
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Assign CWD, not required for this task
export CWD=$(pwd)
echo "[$SHELL] CWD: "$CWD

source /home/duc/.bashrc

# Enter the designed environment
echo "[$SHELL] Activate SAMtools"
module load SAMtools/1.10-GCC-8.3.0

# SCRATCH = fast IO location in /scratchdata
# Copy between Scratch-shared to Local scratch (SCRATCH) is very fast.
# (seconds for 1 GB)
SCRATCH=/scratchdata/${SLURM_JOB_USER}/${SLURM_JOB_ID} # fresh for every job
echo "[$SHELL] Node scratch: "$SCRATCH
export RUNDIR=$SCRATCH/duc_chipanalysis
mkdir $RUNDIR
echo "[$SHELL] Run directory: "$RUNDIR

echo "[$SHELL] Copy file to run directory."
SOURCEDIR=/home/duc/data/sco1447_chipseq
INDIR=alignmentSAM
OUTDIR=alignmentBAM
cp -r $SOURCEDIR/$INDIR $RUNDIR/
cp $SOURCEDIR/processsSam2Bam.py $RUNDIR/
cd $RUNDIR
echo "[$SHELL] Time elaspsed: $(date -ud "@$(($(date +%s) - $START_TIME))" +%T) (HH:MM:SS)"

echo "[$SHELL] run indexing"
echo "[$SHELL] python processsSam2Bam.py -p $INDIR -o $OUTDIR -t 8" 
python processsSam2Bam.py -p $INDIR -o $OUTDIR -t 8

echo "[$SHELL] done"
echo "[$SHELL] Time elaspsed: $(date -ud "@$(($(date +%s) - $START_TIME))" +%T) (HH:MM:SS)"
echo "[$SHELL] copy result back"

cp -r $RUNDIR/$OUTDIR $SOURCEDIR/
echo "[$SHELL] done"
echo "[$SHELL] Time elaspsed: $(date -ud "@$(($(date +%s) - $START_TIME))" +%T) (HH:MM:SS)"

