#!/bin/bash
#SBATCH --nodes=1 --ntasks-per-node=1 --mem-per-cpu=30000M
#SBATCH --mail-type=FAIL --partition=uag

## Can use Array command here OR outside directly currently using externally.
##SBATCH --array=0-1

## Do not start until this job has successfully finished
##SBATCH --dependency=afterok:JOBID
set -e

[[ $# -gt 0 ]] || { echo "sbatch --array=0-<NumBams> 4.platypus.sh /path/to/bams/"; exit 1; }


SAMTOOLS=/home/aeonsim/scripts/apps-damona-Oct13/samtools/samtools
REF=/home/aeonsim/refs/bosTau6.fasta
HTSCMD=/home/aeonsim/scripts/apps-damona-Oct13/htslib/htscmd
JAVA=/home/aeonsim/tools/jre1.7.0_25/bin/java
GATK=/home/aeonsim/scripts/apps-damona-Oct13/GenomeAnalysisTK-2.7-4-g6f46d11/GenomeAnalysisTK.jar
FREEBAYES=/home/aeonsim/scripts/apps-damona-Oct13/freebayes/bin/freebayes
INDELS=/home/aeonsim/refs/GATK-LIC-UG-indels.vcf.gz
DBSNP=/home/aeonsim/refs/BosTau6_dbSNP138_NCBI.vcf.gz
KNOWNSNP=/home/aeonsim/refs/GATK-497-UG.vcf.gz
CRAM=/home/aeonsim/scripts/apps-damona-Oct13/cramtools-2.0.jar
BGZIP=/home/aeonsim/tools/tabix-0.2.6/bgzip
TARGET=(chr1 chr2 chr3 chr4 chr5 chr6 chr7 chr8 chr9 chr10 chr11 chr12 chr13 chr14 chr15 chr16 chr17 chr18 chr19 chr20 chr21 chr22 chr23 chr24 chr25 chr26 chr27 chr28 chr29 chrX chrM)
VERSION=`date +%d-%b-%Y`
SAMBAM=/home/aeonsim/scripts/apps-damona-Oct13/sambamba_v0.4.0
CHIPTARGETS=/home/aeonsim/refs/11k_targets.intervals
PED=/home/aeonsim/refs/Damona-full.ped
DAMONA11K=/home/aeonsim/refs/Damona-11K.vcf.gz
PLATYPUS=/home/aeonsim/tools/Platypus_0.7.2/Platypus.py

find $1  -name '*.bam' > /scratch/aeonsim/tmp/${VERSION}.${SLURM_ARRAY_TASK_ID}.bams.list

echo " ARRAY ${SLURM_JOB_ID} or ${SLURM_JOBID}"
echo "ARRAY JOB: ${SLURM_ARRAY_TASK_ID}"

python ${PLATYPUS} callVariants --bamFiles=/scratch/aeonsim/tmp/${VERSION}.${SLURM_ARRAY_TASK_ID}.bams.list --regions=${TARGET[$SLURM_ARRAY_TASK_ID]} --output=${TARGET[$SLURM_ARRAY_TASK_ID]}-$VERSION.platypus.vcf --refFile=${REF} --assemble=1 --nCPU=$SLURM_JOB_CPUS_PER_NODE

bgzip ${TARGET[$SLURM_ARRAY_TASK_ID]}-$VERSION.platypus.vcf
tabix -p vcf ${TARGET[$SLURM_ARRAY_TASK_ID]}-$VERSION.platypus.vcf.gz

rm /scratch/aeonsim/tmp/${VERSION}.bams.list
#if [ -s "/scratch/aeonsim/vcfs/${TARGET[$SLURM_ARRAY_TASK_ID]}-$VERSION.vcf.gz" ]
#then
#  echo "VCF exists cleaning up"
#  rm /scratch/aeonsim/vcfs/${TARGET[$SLURM_ARRAY_TASK_ID]}-$VERSION.bam
#fi
