# Run MetaboAnalyst after installation


## Start docker image (temporary container)

```bash
$ docker run -ti --rm --name METAB_DOCKER -p 8080:8080 metab_docker
```

The command prompt will look something like below; you are now in the shell

```
root@760b678fd4bf:/#
```

## Open all R libraries and starts the Reserve in daemon mode

```bash
Rscript /metab4script.R 
```

Output  

```
Starting Rserve:
 /usr/lib/R/bin/R CMD /usr/local/lib/R/site-library/Rserve/libs//Rserve  --no-save --RS-conf /etc/rserve.conf 


R version 3.4.4 (2018-03-15) -- "Someone to Lean On"
Copyright (C) 2018 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

...

Rserv started in daemon mode.
```

## Deploy the MetaboAnalyst WAR file

```bash
java -jar /opt/payara/payara-micro.jar --deploymentDir /opt/payara/deployments
```

## Open web interface

In your web browser go to this link  
http://localhost:8080/MetaboAnalyst/  

Note that you will have to change the MetaboAnalyst version in the link based on the WAR file.  
The application will take a minute or two to load as the scripts need to be compiled

## Quitting Docker

From the terminal, use Ctrl-c to exit the Payara session, and then Ctrl-d to exit the docker container.