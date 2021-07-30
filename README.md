# Pre-Processing PIRE Data

List of steps to take in raw fq files 


---

The purpose of this repo is to provide the steps for processing raw fq files for both [Shotgun Sequencing Libraries - SSL data](https://github.com/philippinespire/pire_ssl_data_processing) for probe development and the [Capture Shotgun Sequencing Libraries- CSSL data](https://github.com/philippinespire/pire_cssl_data_processing) 

Scripts with the `ssl` are designed for shotgun data

Scripts with the `cssl` are designed for capture-shotgun data

Scripts with no suffix in the name can be used for both types of data

---

0. Create your `species dir` and transfer your raw data 
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

* [runFASTP_1st_trim.sbatch]()
* [cumplify.sbatch]()
* [runFASTP_2st_trim.sbatch]()
* [repair.sbatch]()

	* open scripts for usage instructions
	* review the outputs from `fastp` and `fastq_screen` with `multiqc` output


	       	 * open scripts for usage instructions    
	       	 * review the outputs from `fastp` and `fastq_screen` with `multiqc` output

5. Fetch the genome properties for your species
        * [`denovo_genome_assembly/pre-assembly_processing`](https://github.com/philippinespire/denovo_genome_assembly/tree/main/pre-assembly_processing)
	        * open scripts for usage instructions and setting up variables and directories
			* runFASTP_1st_trim.sbatch
                        * cumplify.sbatch
                        * runFASTP_2st_trim.sbatch
                        * fastqscrn.sbatch
                        * repair.sbatch
                * review the outputs from `fastp` and `fastq_screen` with `multiqc` output

All scripts are located in `/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/scripts`

Execute after you have update scripts with your species directories
```sh
sbatch ../../scripts/runFASTP_1st_trim.sbatch/
```

Move your log file into the `logs` dir
```sh
mv *out ../../logs
```

Repeat this for each script AFTER the previous has finished



### Assembly

5. Fetch the genome properties for your species
	* from the literature or other sources
	* estimate properties with *jellyfish* and *genomescope*


6. Assemble the genome
*


5. Rename files to follow the `ddocent` naming convention
   * `population_indivdual.R1.fq.gz`

5. Map processed reads against best reference genome
    * Best genome can be found by running [`wrangleData.R`](https://github.com/philippinespire/denovo_genome_assembly/tree/main/compare_assemblers), sorting tibble by busco or n50, and filtering by species 
    * Use [dDocentHPC mkBAM](https://github.com/cbirdlab/dDocentHPC) to map reads to ref
      * Use [`config.5.cssl`](https://github.com/cbirdlab/dDocentHPC/blob/master/configs/config.5.cssl) when running dDocentHPC as a starting point for the settings

6. Filter the `bam` files
    * Use [dDocentHPC fltrBAM](https://github.com/cbirdlab/dDocentHPC)
    * visualize results with IGV or equivalent on a local computer to look for mapping artifacts
      * look at both contemp and albatross (that goes for anything that follows)
    * compare the filtered (`RG.bam`) to unfiltered (`RAW.bam`) files
      * were a lot of reads lost?

7. Genotype the `bam` files
    * Use [`dDocentHPC mkVCF`](https://github.com/cbirdlab/dDocentHPC) 

8. Filter the `vcf` files
    * Use [`fltrVCF`](https://github.com/cbirdlab/fltrVCF)
      * Use [`config.fltr.ind.cssl`](https://github.com/cbirdlab/fltrVCF/blob/master/config_files/config.fltr.ind.cssl) as a starting point for filter settings

