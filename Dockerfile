# Use Ubuntu Version 14
FROM ubuntu:16.04

MAINTAINER Xia Lab "jasmine.chong@mail.mcgill.ca"

LABEL Description = "MetaboAnalyst 4.0, includes the installation of all necessary system requirements including JDK, R plus all relevant packages, and Payara Micro."

# Install and set up project dependencies (netcdf library for XCMS, imagemagick and 
# graphviz libraries for RGraphviz), then purge apt-get lists.
# Thank you to Jack Howarth for his contributions in improving the Dockerfile.

RUN apt-get update && \
    apt-get install -y software-properties-common sudo
    
RUN apt-get update && \
    add-apt-repository ppa:webupd8team/java && \
    apt-get update && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \ 
    echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" >> /etc/apt/sources.list && \
    gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
    gpg -a --export E084DAB9 | sudo apt-key add - && \
    apt-get update && \
    apt-get install -y \   
    oracle-java8-installer \
    oracle-java8-set-default \
    graphviz \
    imagemagick \
    libcairo2-dev \
    libnetcdf-dev \
    netcdf-bin \
    libssl-dev \
    libxt-dev \
    libxml2-dev \
    libcurl4-openssl-dev \
    gfortran \
    texlive-full \
    texlive-latex-extra \
    wget \
    r-base && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
    r-cran-plyr \
    r-cran-car 

# Install all R packages from bioconductor 

RUN R -e 'source("http://bioconductor.org/biocLite.R"); biocLite(c("Rserve", "RColorBrewer", "xtable", "fitdistrplus","som", "ROCR", "RJSONIO", "gplots", "e1071", "caTools", "igraph", "randomForest", "Cairo", "pls", "pheatmap", "lattice", "rmarkdown", "knitr", "data.table", "pROC", "Rcpp", "caret", "ellipse", "scatterplot3d", "impute", "pcaMethods", "siggenes", "globaltest", "GlobalAncova", "Rgraphviz", "KEGGgraph", "preprocessCore", "genefilter", "SSPA", "sva", "limma", "xcms", "lars", "tidyverse", "pacman", "Hmisc"))'

ADD rserve.conf /rserve.conf
ADD metab4script.R /metab4script.R

# Download and Install Payara Micro
# From payara/micro github - https://github.com/payara/docker-payaramicro/blob/master/Dockerfile

ENV PAYARA_PATH /opt/payara

RUN mkdir -p $PAYARA_PATH/deployments && \
    useradd -d $PAYARA_PATH payara && echo payara:payara | chpasswd && \
    chown -R payara:payara /opt

ENV PAYARA_PKG https://s3-eu-west-1.amazonaws.com/payara.fish/Payara+Downloads/Payara+4.1.2.181/payara-micro-4.1.2.181.jar
ENV PAYARA_VERSION 181
ENV PKG_FILE_NAME payara-micro.jar

RUN wget --quiet -O $PAYARA_PATH/$PKG_FILE_NAME $PAYARA_PKG

ENV DEPLOY_DIR $PAYARA_PATH/deployments
ENV AUTODEPLOY_DIR $PAYARA_PATH/deployments
ENV PAYARA_MICRO_JAR=$PAYARA_PATH/$PKG_FILE_NAME

# Default payara ports + rserve to expose
EXPOSE 4848 8009 8080 8181 6311

# Download and copy MetaboAnalyst war file to deployment directory

ENV METABOANALYST_VERSION 4.53
ENV METABOANALYST_LINK https://www.dropbox.com/s/huu0g35wp45v7ih/MetaboAnalyst-4.61.war?dl=0
ENV METABOANALYST_FILE_NAME MetaboAnalyst.war

RUN wget --quiet -O $DEPLOY_DIR/$METABOANALYST_FILE_NAME $METABOANALYST_LINK

ENTRYPOINT ["bin/bash"]
