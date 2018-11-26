# MetaboAnalyst Docker

## Description 

MetaboAnalyst is a web-application for comprehensive metabolomics data analysis, functional interpretation, and visualization. At its core, MetaboAnalyst permits users to perform a complete analytical workflow, from exploratory statistical analysis to network visualization of results. For users who wish to use MetaboAnalyst 4.0 locally for analysis of  their metabolomics data, we have provided the option for the application to be used as a Docker container, which is based in Ubuntu OS (Version 16.04), and installs necessary dependencies including: Java 8, library dependencies such as libnetcdf for xcms, R, R package dependencies such as Rserve, and Payara Micro.

## Getting Started

### Step 1. Install Docker

Please follow these directions to download Docker: https://docs.docker.com/install/ .

### Step 2. Download the Git Repository

MetaboAnalyst_Docker is freely available from this GitHub repository. In this repository you will find the Dockerfile, a rserve.conf file, which will be used to configure Rserve, and a R script to load the necessary R packages and start Rserve. To download the MetaboAnalyst_Docker, A) clone the GitHub, or B) manually download the ZIP file under the green "Clone or download" button in the top right of the page. If you download the zipped file, make sure that you extract the files before commencing with Step 3. 

```bash
# Option A
# If you want to clone this repository into a different directory (X by default), specify it as the next command-line option, leaving a space between the link and your directory
$ git clone https://github.com/xia-lab/MetaboAnalyst_Docker /Desktop/Metab4_Docker

```

### Step 3. Build and Run the Dockerfile

As Docker was built with the intention of running a single processes, the MetaboAnalyst docker requires users to enter the built container using a Ubuntu 16.04 shell to enter 2 commands, the 1st to start Rserve and the 2nd to deploy the application on Payara Micro.

```bash
### Step 1: Change your working directory to the downloaded GitHub repository
$ cd ~/Desktop/Metab4_Docker

### Step 2: Build the Dockerfile, note this will take a long time (30 mins / 1 hour) as several packages need to be installed
$ docker build -t metab_docker .

### Step 3: Run the Dockerfile, the -ti option will open an interactive Ubuntu terminal into the created container and presents a command prompt
$ docker run -ti --rm --name METAB_DOCKER -p 8080:8080 metab_docker

## The command prompt will look something like below; you are now in the shell
root@760b678fd4bf:/# 

### Step 4: Enter the script below, which opens all R libraries and starts the Rserve in daemon mode
root@760b678fd4bf:/# Rscript /metab4script.R 

# Note you should see "Rserv started in daemon mode" appear in the terminal.

### Step 5: Enter the command to deploy the MetaboAnalyst WAR file
root@760b678fd4bf:/# java -jar /opt/payara/payara-micro.jar --deploymentDir /opt/payara/deployments

### Step 6: In your web browser go to the link below. Note that you will have to change the MetaboAnalyst version in the link based on the WAR file 
### The application will take a minute or two to load as the scripts need to be compiled
http://localhost:8080/MetaboAnalyst/

### Step 7: Quitting Docker
From the terminal, use Ctrl-c to exit the Payara session, and then Ctrl-d to exit the docker container.

```
### Step 4. MetaboAnalyst Docker History

11-23-2018: Bug fixing + updated to MetaboAnalyst 4.39

03-23-2018: Bug fixing based on user feedback

03-08-2018: Added Dockerfile for MetaboAnalyst 4.09
