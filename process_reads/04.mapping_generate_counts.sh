#!/bin/bash
#SBATCH --partition=popgenom,cas,kamiak         ### Partition
#SBATCH --job-name=map2               ### Job name
#SBATCH --output=/data/cornejo/projects/vagina/stringtie2-%a.out      ### File in which to store job output
#SBATCH --error=/data/cornejo/projects/vagina/stringtie2-%a.err       ### File in which to store job error messages
#SBATCH --workdir=/data/cornejo/projects/vagina/
#SBATCH --array=1-24                   ### Submit separate jobs for each sample in the array
#SBATCH --time=7-00:00:00       ### Wall clock time limit in Days-HH:MM:SS
#SBATCH --nodes=1               ### Node count required for the job
#SBATCH --ntasks-per-node=1     ### Number of tasks to be launched per Node (MPI processes)
#SBATCH --mem=100G


SampleName=$(sed -n ''$SLURM_ARRAY_TASK_ID'p' list_samples | awk '{print $2}')
#FileName=$(sed -n ''$SLURM_ARRAY_TASK_ID'p' list_samples | awk '{print $1}')

module load java/oracle_1.8.0_92
module load picard/2.21.4
module load samtools/1.9
module load gcc/7.3.0
module load cutadapt/2.10
module load hisat2/2.2.1

ref="/data/cornejo/projects/reference_genomes/h_sapiens/hg19.fa"

myStringtie="/data/cornejo/projects/programs/stringtie-2.1.6.Linux_x86_64/stringtie"

mkdir stringtie_out1
mkdir stringtie_out_work

$myStringtie mapped_reads/$SampleName.sorted.fixed.bam -o stringtie_out1/$SampleName -m 100 --rf -c 2 -p 2 \
        -G /data/cornejo/projects/reference_genomes/h_sapiens/Homo_sapiens.GRCh38.84.gtf \
        -A stringtie_out/$SampleName.abundance

$myStringtie mapped_reads/$SampleName.sorted.fixed.bam -o stringtie_out_work/$SampleName -m 100 --rf -e -B -c 2 -p 2 \
        -G /data/cornejo/projects/reference_genomes/h_sapiens/Homo_sapiens.GRCh38.84.gtf

cp prepDE.py stringtie_out_work/
cd stringtie_out_work
python prepDE.py -i sample_list.txt -g gene_count_matrix.csv -t transcript_count_matrix.csv
