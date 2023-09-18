

# check to see if fastq files are formatted correctly

enable_lmod
module load container_env fastq_utils
export SINGULARITY_BIND=/home/e1garcia

fqPATTERN=$1

ls $fqPATTERN | \
  parallel --no-notice crun.fastq_utils "fastq_info {} > {}.validation"
