# Pre-Processing PIRE Data

List of steps to take in raw fq files from shotgun and capture-shotgun

---


<details><summary>Before You Start, Read This</summary>
<p>

## Before You Start, Read This

The purpose of this repo is to provide the steps for processing raw fq files for both [Shotgun Sequencing Libraries - SSL data](https://github.com/philippinespire/pire_ssl_data_processing) for probe development and the [Capture Shotgun Sequencing Libraries- CSSL data](https://github.com/philippinespire/pire_cssl_data_processing).

Scripts with `ssl` in the name are designed for shotgun data, including `lcwgs`. Scripts with `cssl` in the name are designed for capture-shotgun data. Scripts with no suffix in the name can be used for both types of data. Both the the `pire_ssl_data_processing` and `pire_cssl_data_processing` and `pire_lcwgs_data_processing` repos assume that the `pire_fq_gz_processing` repo is in the same directory as they are.  

---

</p>
</details>


<details><summary>Which HPC Are You Using?</summary>
<p>

## Use Turing

We encourage everybody to use `wahab.hpc.odu.edu` or `turing.hpc.odu.edu`, preferably wahab.  You can start by logging onto wahab

	```bash
	ssh YourUserName@wahab.hpc.odu.edu
	```

There are shared repos on wahab and turing in `/home/e1garcia/shotgun_PIRE` that you are encouraged to use.

	```bash
	cd /home/e1garcia/shotgun_PIRE
	```

If, however, you know that you deliberately don't want to use the shared repos on wahab and turing in `/home/e1garcia/shotgun_PIRE`, then here is how you would get started on another hpc and realize that you will have to modify all of the paths given in these `README.md` and tutorials.

**ONLY DO THE FOLLOWING STEPS 0 AND 1 IF YOU ARE NOT USING WAHAB OR TURING**

0. Create a directory for your PIRE repos to live in, and cd into it

	```bash
	mkdir <pathToPireDir>
	cd <pathToPireDir>
	```

1. Clone the repos into your PIRE working dir 

	```sh
	#cd to your working dir then
	git clone https://github.com/philippinespire/pire_fq_gz_processing.git

	# then choose which repo you are using
	git clone https://github.com/philippinespire/pire_ssl_data_processing.git
	git clone https://github.com/philippinespire/pire_cssl_data_processing.git
	git clone https://github.com/philippinespire/pire_lcwgs_data_processing.git
	```

---

</p>
</details>

<details><summary>Git Your Act Together or Be Doomed to a Life of Anguish and Despair</summary>
<p>

## Git etiquette 

You must constantly be pulling and pushing changes to github with `git` or else you're going to mess up the repo.

1. Goto your PIRE working dir (`/home/e1garcia/shotgun_PIRE` on wahab) and use the `pire_fq_gz_processing` repo along with either `pire_ssl_data_processing` or `pire_cssl_data_processing` or `pire_lcwgs_data_processing`, and immediately start by pulling changes from github in the repos you are using **EACH TIME YOU LOG IN**

	```bash
	# on wahab replace <yourPireDirPath> with /home/e1garcia/shotgun_PIRE
	cd <yourPireDirPath>/pire_fq_gz_processing
	git pull

	# replace <ssl or cssl or lcwgs> with either ssl or cssl or lcwgs, no spaces
	cd <yourPireDirPath>/pire_<ssl or cssl or lcwgs>_data_processing
	git pull
	```

2. When your session is done, i.e. you are about to log off, push your changes to github **EACH TIME YOU LOG OUT**

	```bash
	cd <yourPireDirPath>/pire_<ssl or cssl or lcwgs>_data_processing
	git pull

	# if there are no errors, then proceed, otherwise get help
	git add --all

	# if there are no errors, then proceed, otherwise get help
	git commit -m "insert message here"

	# if there are no errors, then proceed, otherwise get help
	git push
	```

3. As you work through this tutorial it is assumed that you will be running scripts from either `pire_ssl_data_processing` or `pire_cssl_data_processing` or `pire_lcwgs_data_processing` and you will need to add the path to the `pire_fq_gz_processing` directory before the script's name in the code blocks below.

	```sh
	#add this path when running scripts on wahab
	#<yourPireDirPath>/pire_fq_gz_processing/<script's name> <script arguments>

	#Example:
	sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh <script arguments>
	```

---

</p>
</details>


<details><summary>Overview</summary>
<p>

## Overview

***Download data, rename files, trim, deduplicate, decontaminate, and repair the raw `fq.gz` files***
*(plan for a few hours for each step except for decontamination, which can take 1-2 days)*

Scripts to run
  * [gridDownloader.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/gridDownloader.sh)
  * [renameFQGZ.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/renameFQGZ.bash)
  * [Multi_FASTQC.sh](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh)
  * [runFASTP_1st_trim.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch)
  * [runCLUMPIFY_r1r2_array.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash)
  * [runFASTP_2_ssl.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_ssl.sbatch) | [runFASTP_2_cssl.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_cssl.sbatch)
  * [runFQSCRN_6.bash](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFQSCRN_6.bash)
  * [runREPAIR.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runREPAIR.sbatch)
  
    * open scripts for usage instructions
    * review the outputs from `fastp`, `fastq_screen`, and `repair` with `MultiQC` output

---

</p>
</details>


<details><summary>0. Set up directory for species if it doesn't exist</summary>
<p>

## 0. Set up directory

All types of data will share the following directories associated with data qc

```bash
# if it does not exist, make the directory for your species 
# you must replace the <> with the real val
mkdir <yourPireDirPath>/pire_<ssl or cssl or lcwgs>_data_processing/<genus_species>
cd <yourPireDirPath>/pire_<ssl or cssl or lcwgs>_data_processing/<genus_species>
mkdir fq_raw fq_fp1 fq_fp1_clmp fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired
```

---

</p>
</details>


<details><summary>1. Download data</summary>
<p>

## **1. Download your data from the TAMUCC grid**

**Locate the link to the files**. This is provided by Sharon at the species slack channel once the data is ready to be downloaded.  Make sure it works: click on it and your web browser should open listing your data files.
e.g. [https://gridftp.tamucc.edu/genomics/20221011_PIRE-Gmi-capture](https://gridftp.tamucc.edu/genomics/20221011_PIRE-Gmi-capture).


```bash
# Navigate to dir to download files into, e.g.
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>/fq_raw

# sbatch gridDownloader.sh <outdir> <link-to-files>
# outdir becomes "." since you have already navigated there
sbatch <yourPireDirPath>/pire_fq_gz_processing/gridDownloader.sh . https://gridftp.tamucc.edu/genomics/20221011_PIRE-<your_species>-capture/
```

If your download fails, go back to the web browser and check that you can see a file named "tamucc_files.txt" along with the decode and fq files. 

`*1.fq.gz` files contain the forward reads and `*2.fq.gz` files contain the reverse reads for an individual.

---

</p>
</details>


<details><summary>2. Proofread the decode files</summary>
<p>

## **2. Proofread the decode file(s) (<1 minute run time) **

Make sure you check and edit the decode file(s) as necessary so that the following naming format is followed:

`PopSampleID_LibraryID` where:

  * `PopSampleID` = `3LetterSpeciesCode-CorA3LetterSiteCode`
  * `LibraryID` = `IndiviudalID-Extraction-PlateAddress`  or just `IndividualID` if there is only 1 library for the individual 

__Do NOT use `_` in the LibraryID. *The only `_` should be separating `PopSampleID` and `LibraryID`.__

Examples of compatible names:

  * `Sne-CTaw_051-Ex1-3F` = *Sphaeramia nematoptera* (Sne), contemporary (C) from Tawi-Tawi (Taw), indv 051, extraction 1, loc 3F on plate
  * `Sne-CTaw_051` = *Sphaeramia nematoptera* (Sne), contemporary (C) from Tawi-Tawi (Taw), indv 051
  * `Sne-CTaw_051-Ex1-L4` = *Sphaeramia nematoptera* (Sne), contemporary (C) from Tawi-Tawi (Taw), indv 051, extraction 1, loc L4 (lane 4)


Here are some other QC checks on the downloaded data and the decode files:

```bash
salloc
bash

# Navigate to dir with downloaded files, e.g.
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>/fq_raw

#check that you got back sequencing data for all individuals in decode file
#XX files (2 additional files for README.md & decode.tsv = XX/2 = XX individuals (R&F)
ls | wc -l 

#XX lines (1 additional line for header = XX individuals), checks out
wc -l <NAMEOFDECODEFILE>.tsv 

```

---

</p>
</details>


<details><summary>3. Perform a renaming dry run</summary>
<p>

## **3. Perform a renaming dry run**

Then, use the decode file with [`renameFQGZ.bash`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/renameFQGZ.bash) to rename your raw `fq.gz` files. If you make a mistake here, it could be catastrophic for downstream analyses. This is why we ***STRONGLY recommend*** you use this pre-written bash script to automate the renaming process. [`renameFQGZ.bash`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/renameFQGZ.bash) allows you to view what the files will be named before renaming them and also stores the original and new file names in files that could be used to restore the original file names.

Run `renameFQGZ.bash` to view the original and new file names and create `tsv` files to store the original and new file naming conventions.

```bash
# Navigate to dir with downloaded files, e.g.
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>/fq_raw

bash <yourPireDirPath>/pire_fq_gz_processing/renameFQGZ.bash <NAMEOFDECODEFILE>.tsv 
```

**NOTE:** Depending on how you have your `.wahab_tcshrc` (or `.turing_tcshrc` if on Turing) set-up, you may get the following error when you try to execute this script: *Cwd.c: loadable library and perl binaries are mismatched (got handshake key 0xcd00080, needed 0xde00080)*. To fix this:

  1. Open up `.wahab_tcshrc` (it will be in your home (`~`) directory) and add `unsetenv PERL5LIB` at the end of the chunk of code under the `if (! $?MODULES_LOADED) then` line. One of the modules we are loading for the scripts loads a "bad" perl library that is causing the error message downstream.
  2. Save your changes.
  3. Close out of your Terminal connection and restart it. You should be able to run `renameFQGZ.bash` now without any issues.

---

</p>
</details>


<details><summary>4. Rename the files for real</summary>
<p>

## **4. Rename the files for real (<1 minute run time) **

After you are satisfied that the orginal and new file names are correct, then you can change the names. To check and make sure that the names match up, you are mostly looking at the individual and population numbers in the new and old names, and that the `-` and `_` in the new names are correct (e.g. no underscores where there should be a dash, etc.). If you have to make changes, you can open up the `NAMEOFDECODEFILE.tsv` to do so, **but be very careful!!**

Example of how the file names line up:

  * `Sne-CTaw_051` = `SnC01051` at the beginning of the original file name
    * Sn = Sne, C = C, 01 = population/location 1 if there are more than 1 populations/locations in the dataset (here Taw location), 051 = 051
    
When you are ready to change names, execute the line of code below. This script will ask you twice whether you want to proceed with renaming.

```bash
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>/fq_raw

bash <yourPireDirPath>/pire_fq_gz_processing/renameFQGZ.bash <NAMEOFDECODEFILE>.tsv rename

#you will need to say y 2X
```


---

</p>
</details>


<details><summary>5. Make a copy of the renamed files</summary>
<p>

## **5. Make a copy of the renamed files (several hours run time)**

If you haven't done so, create a copy of your raw files unmodified in the longterm Carpenter RC dir
`/RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<species_name>/fq_raw`.  
*(can take several hours)*

```bash
mkdir /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_<ssl|cssl|lcwgs>_data_processing/<species_name>/fq_raw

cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>/fq_raw

cp ./* /RC/group/rc_carpenterlab_ngs/shotgun_PIRE/pire_<ssl|cssl|lcwgs>_data_processing/<species_name>/fq_raw
```

---

</p>
</details>


<details><summary>6. Check the quality of raw data</summary>
<p>

## **6. Check the quality of your data. Run `fastqc` (1-2 hours run time)**

FastQC and then MultiQC can be run using the [Multi_FASTQC.sh](Multi_FASTQC.sh) script in this repo.

Execute `Multi_FASTQC.sh` while providing, in quotations and in this order, (1) the FULL path to these files and (2) a suffix that will identify the files to be processed.

`Multi_FASTQC.sh` should be run from the directory that holds the raw, renamed `fq.gz` files. This will be `fq_raw`. If not, rename it to fq_raw

```bash
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>/fq_raw

#sbatch Multi_FASTQC.sh "<indir>" "<file extension>"
#do not use trailing / in paths. Example:
sbatch /home/e1garcia/shotgun_PIRE/pire_fq_gz_processing/Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>/fq_raw" "fq.gz"   
```

If you get a message about not finding `crun` then load the following containers in your current session and run `Multi_FASTQC.sh` again.

```bash
enable_lmod
module load parallel
module load container_env multiqc
module load container_env fastqc

#Example:
sbatch Multi_FASTQC.sh "/home/e1garcia/shotgun_PIRE/pire_ssl_data_processing/spratelloides_gracilis/fq_raw" "fq.gz"
```

Review the `MultiQC` output (`fq_raw/fastqc_report.html`). You can push your changes to github, then copy and paste the url to the raw html on github into this site: https://htmlpreview.github.io/ .  Note that because our repo is private, there is a token attached to the link that goes stale pretty quickly. 

Make notes in your <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>/README.md file as follows:

	Potential issues:  
	  * % duplication - 
		* Alb: XX%, Contemp: XX%
	  * GC content - 
		* Alb: XX%, Contemp: XX%
	  * number of reads - 
		* Alb: XX mil, Contemp: XX mil

---

</p>
</details>


<details><summary>7. First trim</summary>
<p>

## **7. First trim. 

Execute [`runFASTP_1st_trim.sbatch`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_1st_trim.sbatch) (0.5-3 hours run time)**

```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

#sbatch runFASTP_1st_trim.sbatch <indir> <outdir>
#do not use trailing / in paths
# note, if your dir is set up correctly, this relative path will work
sbatch ../../pire_fq_gz_processing/runFASTP_1st_trim.sbatch fq_raw fq_fp1 
```

Review the `FastQC` output (`fq_fp1/1st_fastp_report.html`) and update your `README.md`:

Potential issues:  
  * % duplication - 
    * Alb: XX%, Contemp: XX%
  * GC content -
    * Alb: XX%, Contemp: XX%
  * passing filter - 
    * Alb: XX%, Contemp: XX%
  * % adapter - 
    * Alb: XX%, Contemp: XX%
  * number of reads - 
    * Alb: XX mil, Contemp: XX mil

---

</p>
</details>


<details><summary>8. Remove duplicates</summary>
<p>

## **8. Remove duplicates. 

Execute [`runCLUMPIFY_r1r2_array.bash`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runCLUMPIFY_r1r2_array.bash) (0.5-3 hours run time)**

`runCLUMPIFY_r1r2_array.bash` is a bash script that executes several sbatch jobs to de-duplicate and clumpify your `fq.gz` files. It does two things:

1. Removes duplicate reads.
2. Re-orders each `fq.gz` file so that similar sequences (reads) appear closer together. This helps with file compression and speeds up downstream steps.

You will need to specify the number of nodes you wish to allocate your jobs to. The max # of nodes to use at once should not exceed the number of pairs of r1-r2 files to be processed. (Ex: If you have 3 pairs of r1-r2 files, you should only use 3 nodes at most.) If you have many sets of files (likely to occur if you are processing capture data), you might also limit the nodes to the current number of idle nodes to avoid waiting on the queue (run `sinfo` to find out # of nodes idle in the main partition).

```bash
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

#runCLUMPIFY_r1r2_array.bash <indir; fast1 files> <outdir> <tempdir> <max # of nodes to use at once>
#do not use trailing / in paths
bash ../../pire_fq_gz_processing/runCLUMPIFY_r1r2_array.bash fq_fp1 fq_fp1_clmp /scratch/<YOURUSERNAME> 20
```

After completion, run [`checkClumpify_EG.R`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/checkClumpify_EG.R) to see if any files failed.

```bash
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

salloc #because R is interactive and takes a decent amount of memory, we want to grab an interactive node to run this
enable_lmod
module load container_env mapdamage2

crun R < checkClumpify_EG.R --no-save
exit #to relinquish the interactive node

#if the previous line returns an error that tidyverse is missing then do the following
crun R

#you are now in the R environment (there should be a > rather than $), install tidyverse
install.packages("tidyverse") #when prompted, type "yes"

#when the install is complete, exit R with the following keystroke combo: ctrl-d (typing q() also works)
#type "n" when asked about saving the environment

#you are now in the shell environment and you should be able to run the checkClumpify script
crun R < checkClumpify_EG.R --no-save
```

If all files were successful, `checkClumpify_EG.R` will return "Clumpify Successfully worked on all samples". 

If some failed, the script will also let you know. Try raising "-c 20" to "-c 40" in the `runCLUMPIFY_r1r2_array.bash` and run Clumplify again.

Also look for this error *"OpenJDK 64-Bit Server VM warning:
INFO: os::commit_memory(0x00007fc08c000000, 204010946560, 0) failed; error='Not enough space' (errno=12)"*

If the array set up doesn't work, try running Clumpify on a Turing himem (high memory) node.

---

</p>
</details>


<details><summary>9. Second trim</summary>
<p>

## **9. Second trim. Execute `runFASTP_2.sbatch` (0.5-3 hours run time)**

If you are going to assemble a genome with this data, use [runFASTP_2_ssl.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_ssl.sbatch). Otherwise, use [runFASTP_2_cssl.sbatch](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFASTP_2_cssl.sbatch).  Modify the script name in the code blocks below as necessary. 

```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

#sbatch runFASTP_2.sbatch <indir; clumpified files> <outdir>
#do not use trailing / in paths
sbatch ../../pire_fq_gz_processing/runFASTP_2.sbatch fq_fp1_clmp fq_fp1_clmp_fp2

#for SSL: runFASTP_2_ssl.sbatch
#for CSSL: runFASTP_2_cssl.sbatch
```

Review the results with the `FastQC` output (`fq_fp1_clmp_fp2/2nd_fastp_report.html`) and update your `README.md`.

Potential issues:  
  * % duplication - 
    * Alb: XX%, Contemp: XX%
  * GC content - 
    *  Alb: XX%, Contemp: XX%
  * passing filter - 
    * Alb: XX%, Contemp: XX%
  * % adapter - 
    * Alb: XX%, Contemp: XX%
  * number of reads - 
    * Alb: XX mil, Contemp: XX mil


---

</p>
</details>


<details><summary>10. Decontaminate</summary>
<p>

## **10. Decontaminate files. 

Execute [`runFQSCRN_6.bash`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runFQSCRN_6.bash) (several hours run time)**

`FastQ Screen` works to identify and remove contamination by mapping the reads in our `fq.gz` files to a set of bacterial, protist, virus, fungi, human, etc. genome assemblies that we previously downloaded. If any of the reads in any of the `fq.gz` files map (or "hit") to one or more of these assemblies they are removed from the `fq.gz` file. 

Like with Clumpify, `runFQSCRN_6.bash` is a bash script that executes several sbatch jobs. You will need to specify the number of nodes you wish to allocate your jobs to. Try running 1 node per `fq.gz` file if possible. (Ex: If you have 3 pairs of r1-r2 files, you should only use 6 nodes maximum (1 per file)). If you have many `fq.gz` files (likely to occur if you are processing capture data), you might also limit the nodes to the current number of idle nodes to avoid waiting on the queue (run `sinfo` to find out # of nodes idle in the main partition).
  * ***NOTE: You are executing the bash not the sbatch script.***
  * ***This can take up to several days depending on the size of your dataset. Plan accordingly!***

```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

#runFQSCRN_6.bash <indir; fp2 files> <outdir> <number of nodes running simultaneously>
#do not use trailing / in paths
bash ../../pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 20
```

Once done, confirm that all files were successfully completed.

```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

#FastQ Screen generates 5 files (*tagged.fastq.gz, *tagged_filter.fastq.gz, *screen.txt, *screen.png, *screen.html) for each input fq.gz file
#check that all 5 files were created for each file: 
ls fq_fp1_clmp_fp2_fqscrn/*tagged.fastq.gz | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*tagged_filter.fastq.gz | wc -l 
ls fq_fp1_clmp_fp2_fqscrn/*screen.txt | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.png | wc -l
ls fq_fp1_clmp_fp2_fqscrn/*screen.html | wc -l

#for each, you should have the same number as the number of input files (number of fq.gz files)

#you should also check for errors in the *out files:
#this will return any out files that had a problem

#do all out files at once
grep 'error' slurm-fqscrn.*out
grep 'No reads in' slurm-fqscrn.*out

#or check individuals files <replace JOBID with your actual job ID>
grep 'error' slurm-fqscrn.JOBID*out
grep 'No reads in' slurm-fqscrn.JOBID*out
```

If you see missing indiviudals or categories in the FastQC output, there was likely a RAM error. The "error" search term may not catch it.

Run the files that failed again.

```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

#runFQSCRN_6.bash <indir; fp2 files> <outdir> <number of nodes to run simultaneously> <fq file pattern to process>
#do not use trailing / in paths. Example:
bash ../../pire_fq_gz_processing/runFQSCRN_6.bash fq_fp1_clmp_fp2 fq_fp1_clmp_fp2_fqscrn 1 LlA01010*r1.fq.gz
```

Once `FastQ Screen` has finished running and there are no issues, run [`runMULTIQC.sbatch`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runMULTIQC.sbatch) to get the MultiQC output.

```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

#sbatch runMULTIQC.sbatch <indir; fqscreen files> <report name>
#do not use trailing / in paths
sbatch ../../pire_fq_gz_processing/runMULTIQC.sbatch fq_fp1_clmp_fp2_fqscrn fastqc_screen_report
```

Review the results with the `MultiQC` output (`fq_fp1_clmp_fp2_fqscrn/fastqc_screen_report.html`) and update your `README.md`.

Potential issues:

  * one hit, one genome, no ID - 
    * Alb: XX%, Contemp: XX%
  * no one hit, one genome to any potential contaminators (bacteria, virus, human, etc) - 
    * Alb: XX%, Contemp: XX%

---

</p>
</details>


<details><summary>11. Repair</summary>
<p>

## **11. Execute [`runREPAIR.sbatch`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/runREPAIR.sbatch) (<1 hour run time)**

`runREPAIR.sbatch` does not "repair" reads but instead re-pairs them. Basically, it matches up forward (r1) and reverse (r2) reads so that the `*1.fq.gz` and `*2.fq.gz` files have reads in the same order.

```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

#runREPAIR.sbatch <indir; fqscreen files> <outdir> <threads>
sbatch ../../pire_fq_gz_processing/runREPAIR.sbatch fq_fp1_clmp_fp2_fqscrn fq_fp1_clmp_fp2_fqscrn_repaired 40
```

Once the job has finished, run [`Multi_FASTQC.sh`](https://github.com/philippinespire/pire_fq_gz_processing/blob/main/Multi_FASTQC.sh) separately.

```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>
/fq_fp1_clmp_fp2_fqscrn_repaired

#sbatch Multi_FASTQC.sh "<indir>" "<file extension>"
#do not use trailing / in paths. Example:
sbatch ../../pire_fq_gz_processing/Multi_FASTQC.sh "<yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>/fq_fp1_clmp_fp2_fqscrn_repaired" "fq.gz" 
```

Review the results with the `MultiQC` output (`fq_fp1_clmp_fp2_fqscrn_repaired/fastqc_report.html`) and update your `README.md`.

Potential issues:  
  * % duplication - 
    * Alb: XX%, Contemp: XX%
  * GC content - 
    * Alb: XX%, Contemp: XX%
  * number of reads - 
    * Alb: XX mil, Contemp: XX mil

---

</p>
</details>


<details><summary>12. Calculate the percent of reads lost in each step</summary>
<p>

## **12. Calculate the percent of reads lost in each step**

`read_calculator_ssl.sh` counts the number of reads before and after each step in the pre-process of ssl (or cssl) data and creates the dir `preprocess_read_change` with the following 2 tables:

  1. `readLoss_table.tsv` which reports the step-specific percentage of reads lost and the final cumulative percentage of reads lost.
  2. `readsRemaining_table.tsv` which reports the step-specific percentage of reads that remain and the final cumulative percentage of reads that remain.
 
```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

#read_calculator_ssl.sh "<path to species home dir>" "<Path to dir with raw files>"
#do not use trailing / in paths.

# SSL Example:
sbatch ../../pire_fq_gz_processing/read_calculator.sh "." "fq_raw"

```

Once the job has finished, inspect the two tables and revisit steps if too much data was lost.

---

</p>
</details>


<details><summary>13. Clean Up</summary>
<p>

## **13. Clean Up**

Move any `.out` files into the `logs` dir (if you have not already done this as you went along):

```sh
cd <yourPireDirPath>/pire_<ssl-or-cssl-or-lcwgs>_data_processing/<genus_species>

mv *out logs/
```

Be sure to update your `README.md` file so that others know what happened in your directory. Ideally, somebody should be able to replicate what you did exactly.

***Congratulations!!** You have finished the pre-processing steps for your data analysis. Now move on to either the [SSL](https://github.com/philippinespire/pire_ssl_data_processing) or [CSSL](https://github.com/philippinespire/pire_cssl_data_processing) pipelines.*

</p>
</details>


