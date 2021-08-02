# Pre-Processing PIRE Data

List of steps to take in raw fq files 


---

The purpose of this repo is to provide the steps for processing raw fq files for both [Shotgun Sequencing Libraries - SSL data](https://github.com/philippinespire/pire_ssl_data_processing) for probe development and the [Capture Shotgun Sequencing Libraries- CSSL data](https://github.com/philippinespire/pire_cssl_data_processing) 

Scripts with the `ssl` are designed for shotgun data

Scripts with the `cssl` are designed for capture-shotgun data

Scripts with no suffix in the name can be used for both types of data

---

0. If you haven't done so, create a copy of your raw files unmodified in the longterm Carpenter RC dir
`/RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_<ssl|cssl>_data_processing/<species_name>/<ssl|cssl>_raw_fq`. Then, create your `species dir` and transfer your raw data. This will be your working copy. 
*(can take several hours)*

1. Run `fastqc`
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

2. Trim, deduplicate, decontaminate, and repair the raw `fq.gz` files
*(few hours for each of the 2 trims and deduplication, decontamination can take 1-2 days; reparing is done in 1-2 hrs)*

Scripts to run

* [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
* [cumplify.sbatch]()
* [runFASTP_2st_trim.sbatch]()
* [repair.sbatch]()

	* open scripts for usage instructions
	* review the outputs from `fastp` and `fastq_screen` with `multiqc` output, which is already set to run after these steps


Execute runFASTP_1st_trim.sbatch
```sh
sbatch runFASTP_1st_trim.sbatch <INDIR/full path to files> <OUTDIR/full path to desired outdir>
```

Execute after you have update scripts with your species directories
```sh
sbatch runFASTP_1st_trim.sbatch/
```
