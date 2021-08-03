# Pre-Processing PIRE Data

List of steps to take in raw fq files 


---

The purpose of this repo is to provide the steps for processing raw fq files for both [Shotgun Sequencing Libraries - SSL data](https://github.com/philippinespire/pire_ssl_data_processing) for probe development and the [Capture Shotgun Sequencing Libraries- CSSL data](https://github.com/philippinespire/pire_cssl_data_processing) 

Scripts with the `ssl` are designed for shotgun data

Scripts with the `cssl` are designed for capture-shotgun data

Scripts with no suffix in the name can be used for both types of data

---

**0. Make a copy of your data**
If you haven't done so, create a copy of your raw files unmodified in the longterm Carpenter RC dir
`/RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_<ssl|cssl>_data_processing/<species_name>/<ssl|cssl>_raw_fq`. Then, create your `species dir` and transfer your raw data. This will be your working copy. 
*(can take several hours)*

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

```sh
enable_lmod
module load parallel
module load container_env multiqc
module load container_env fastqc
sbatch scripts/Multi_FASTQC.sh "fq.gz" "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/shotgun_raw_fq"
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


**2. First trim. Execute `runFASTP_1st_trim.sbatch`**
```sh
sbatch runFASTP_1st_trim.sbatch <INDIR/full path to files> <OUTDIR/full path to desired outdir>
```

**3. Remove duplicates. Execute `runCLUMPIFY_r1r2_array.bash` on Wahab**

The max # of nodes to use at once should not exceed the number of pairs of r1-r2 files to be processed. If you have many sets of files, you might also limit the nodes to the current number of idle nodes to avoid waiting on the queue (run `sinfo` to find out # of nodes idle in the main partition)
```sh
#runCLUMPIFY_r1r2_array.bash <indir;fast1 files > <outdir> <tempdir> <max # of nodes to use at once>
# do not use trailing / in paths. Example:
bash runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmparray /scratch/YOURUSERNAME 20
```

After completion, run `checkClumpify.R` to see if any files failed
```
enable_lmod
module load container_env mapdamage2
crun R < checkClumpify.R --no-save
```
If all files were successful, `checkClumpify.R` will return "Clumpify Successfully worked on all samples". 

If some failed, the script will also let you know. Try raising "-c 20" to "-c 40" in `runCLUMPIFY_r1r2_array.bash` and run clumplify again

Also look for this error "OpenJDK 64-Bit Server VM warning:
INFO: os::commit_memory(0x00007fc08c000000, 204010946560, 0) failed; error='Not enough space' (errno=12)"

If the array set up doesn't work. Try running Clumpify on a turing himem node, see the [cssl repo](https://github.com/philippinespire/pire_cssl_data_processing/tree/main/scripts) for details

**4. Second trim. Execute `runFASTP_2.sbatch`**
```sh
#sbatch runFASTP_2.sbatch <INDIR/full path to cumplified files> <OUTDIR/full path to desired outdir>
# do not use trailing / in paths. Example:
sbatch runFASTP_2.sbatch fq_fp1_clmparray fq_fp1_clmparray_fp2
```

**5. Decontaminate files. Execute runFQSCRN_6.bash**

Check the number of available node `sinfo` (i.e. nodes in idle in the main partition).
 Try running one node per fq.gz file if possilbe or how many nodes are available.
 Yet, the number of nodes running simultaneously should not exceed that number of fq.gz files.
```sh
#runFQSCRN_6.bash <indir> <outdir> <number of nodes running simultaneously>
# do not use trailing / in paths. Example:
bash runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 20

#confirm that all files were successfully completed
# this will return any out files that had a problem, replace JOBID with your jobid
grep 'error' slurm-fqscrn.JOBID*out
grep 'No reads in' slurm-fqscrn.JOBID*out
# if you see missing indiviudals or categories in the multiqc output, there was likely a ram error.  I'm not sure if the "error" search term catches it.

# run the files that failed again.  This seems to work in most cases
#runFQSCRN_6.bash <indir> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
bash runFQSCRN_6.bash fq_fp1_clmparray_fp2 fq_fp1_clmparray_fp2_fqscrn 1 LlA01010*r1.fq.gz
...
bash runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01005*r2.fq.gz
```

**6. Execute `runREPAIR.sbatch`

```
#runREPAIR.sbatch <indir> <outdir> <threads>
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmparray_fp2_fqscrn fq_fp1_clmparray_fp2_fqscrn_r$
```
