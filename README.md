# Pre-Processing PIRE Data

List of steps to take in raw fq files from shotgun and capture-shotgun


---

The purpose of this repo is to provide the steps for processing raw fq files for both [Shotgun Sequencing Libraries - SSL data](https://github.com/philippinespire/pire_ssl_data_processing) for probe development and the [Capture Shotgun Sequencing Libraries- CSSL data](https://github.com/philippinespire/pire_cssl_data_processing) 

Scripts with the `ssl` are designed for shotgun data

Scripts with the `cssl` are designed for capture-shotgun data

Scripts with no suffix in the name can be used for both types of data

To run scripts, you can either 
1. Clone this repo in your working dir AND use relative paths to the scripts
```sh
git clone https://github.com/philippinespire/pire_fq_gz_processing.git
```
OR

2. Add the full path (to the directory which already includes all of them) before the script's name. **RECOMMENDED**
```sh
#add this path when running scripts
/home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/<script's name>

#Example:
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh <script arguments>
```

---

**0. Make a copy of your data and rename**

If you haven't done so, create a copy of your raw files unmodified in the longterm Carpenter RC dir
`/RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_<ssl|cssl>_data_processing/<species_name>/<ssl|cssl>_raw_fq`. Then, create your `species dir` and transfer your raw data. This will be your working copy. 
*(can take several hours)*

Then use the decode file to rename your raw `fq.gz` files. If you make a mistake here, it could be catastrophic for downstream analyses.  `renameFQGZ.bash` allows you to view what the files will be named before renaming them and also stores the original and new file names in files that could be used to restore the original file names.

```bash
renameFQGZ.bash NAMEOFDECODEFILE.tsv 
```

After you are satisfied that the orginal and new file names are correct, then you can change the names.  This script will ask you twice whether you want to proceed with renaming.

```bash
renameFQGZ.bash NAMEOFDECODEFILE.tsv rename
```

---

**1. Check the quality of your data. Run `fastqc`**
*(can take several hours)*
    * review results with `multiqc` output

Fastqc and Multiqc can be run simultaneously using the [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) script in this repo

Execute `Multi_FASTQC.sh` while providing, in quotations and in this order, 
(1) a suffix that will identify the files to be processed, and (2) the FULL path to these files. 

Example:
```sh
sbatch Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq"  
```

If you get a message about not finding "crun" then load the containers in your current session and run `Multi_FASTQC.sh` again

```bash
enable_lmod
module load parallel
module load container_env multiqc
module load container_env fastqc
sbatch Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq"
```

***Trim, deduplicate, decontaminate, and repair the raw `fq.gz` files***
*(few hours for each of the 2 trims and deduplication, decontamination can take 1-2 days; reparing is done in 1-2 hrs)*

Scripts to run

* [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
* [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash)
* [runFASTP_2_ssl.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_ssl.sbatch) | [runFASTP_2_cssl.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_cssl.sbatch)
* [runFQSCRN_6.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFQSCRN_6.bash)
* [runREPAIR.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runREPAIR.sbatch)

	* open scripts for usage instructions
	* review the outputs from `fastp` and `fastq_screen` with `multiqc` output, which is already set to run after these steps

---

**2. First trim. Execute `runFASTP_1st_trim.sbatch`**
```bash
sbatch runFASTP_1st_trim.sbatch <INDIR/full path to files> <OUTDIR/full path to desired outdir>
```

---

**3. Remove duplicates. Execute `runCLUMPIFY_r1r2_array.bash` on Wahab**

The max # of nodes to use at once should not exceed the number of pairs of r1-r2 files to be processed. If you have many sets of files, you might also limit the nodes to the current number of idle nodes to avoid waiting on the queue (run `sinfo` to find out # of nodes idle in the main partition)
```bash
#runCLUMPIFY_r1r2_array.bash <indir;fast1 files > <outdir> <tempdir> <max # of nodes to use at once>
# do not use trailing / in paths. Example:
bash runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/YOURUSERNAME 20
```

After completion, run `checkClumpify.R` to see if any files failed
```bash
enable_lmod
module load container_env mapdamage2
crun R < checkClumpify_EG.R --no-save
```
If all files were successful, `checkClumpify_EG.R` will return "Clumpify Successfully worked on all samples". 

If some failed, the script will also let you know. Try raising "-c 20" to "-c 40" in `runCLUMPIFY_r1r2_array.bash` and run clumplify again

Also look for this error "OpenJDK 64-Bit Server VM warning:
INFO: os::commit_memory(0x00007fc08c000000, 204010946560, 0) failed; error='Not enough space' (errno=12)"

If the array set up doesn't work. Try running Clumpify on a turing himem node, see the [cssl repo](https://github.com/philippinespire/pire_cssl_data_processing/tree/main/scripts) for details

---

**4. Second trim. Execute `runFASTP_2.sbatch`**
```bash
#sbatch runFASTP_2.sbatch <INDIR/full path to cumplified files> <OUTDIR/full path to desired outdir>
# do not use trailing / in paths. Example:
sbatch runFASTP_2.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2
```

We've noticed that the GC content can be problematic in the first n nucleotides of the reads (see the multiqc output from fp1 to determine how many nt to trim). You can optionally specify the number of nt to remove from the left sides of the reads prior to any sliding window trimming as follows:

```bash
# example where 15 nt are trimmed from the left (beginning) side of each read
sbatch runFASTP_2.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2 15
```

**5. Decontaminate files. Execute `runFQSCRN_6.bash`**

Check the number of available nodes `sinfo` (i.e. nodes in idle in the main partition).
 Try running one node per fq.gz file if possilbe or how many nodes are available.
 Yet, the number of nodes running simultaneously should not exceed that number of fq.gz files.
* ***NOTE: you are executing the bash not the sbatch script***
* ***This can take up to several days depending on the size of your dataset. Plan accordingly***
```sh
#runFQSCRN_6.bash <indir> <outdir> <number of nodes running simultaneously>
# do not use trailing / in paths. Example:
bash runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 20
```
Confirm that all files were successfully completed
```sh
# Fastqc Screen generates 5 files (*tagged.fastq.gz, *tagged_filter.fastq.gz, *screen.txt, *screen.png, *screen.html) for each input fq.gz file
#check that all 5 files were created for each file: 
ls fq_fp1_clmparray_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmparray_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmparray_fp2_fqscrn/*screen.html | wc -l

# for each, you should have the same number as the number of input files

#You should also check for errors in the *out files:
# this will return any out files that had a problem

#do all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

# or check individuals files <replace JOBID with your actual job ID>
grep 'error' slurm-fqscrn.JOBID*out
grep 'No reads in' slurm-fqscrn.JOBID*out
```
If you see missing indiviudals or categories in the multiqc output, there was likely a ram error. I'm not sure if the "error" search term catches it.

Run the files that failed again. This seems to work in most cases
```sh
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
bash runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 1 LlA01010*r1.fq.gz
...
bash runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01005*r2.fq.gz
```


**6. Execute `runREPAIR.sbatch`**

```
#runREPAIR.sbatch <indir> <outdir> <threads>
sbatch runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_repaired 40
```

---

**Calculate the percent of reads lost in each step**

Execute [read_calculator_ssl.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/read_calculator_ssl.sh)
```sh
#read_calculator_ssl.sh <Species home dir> 
# do not use trailing / in paths. Example:
sbatch read_calculator_ssl.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis"
```

`read_calculator_ssl.sh` counts the number of reads before and after each step in the pre-process of ssl data and creates the dir `reprocess_read_change` with the following 2 tables:
1. `readLoss_table.tsv` which reporsts the step-specific percent of read loss and final accumulative read loss
2. `readsRemaining_table.tsv` which reports the step-specific percent of read loss and final accumulative read loss

Inspect these tables and revisit steps if too much data was lost

