# Use Ubuntu Version 18.04
FROM ubuntu:18.04

MAINTAINER Xia Lab "jasmine.chong@mail.mcgill.ca"

LABEL Description = "MetaboAnalyst 4.0, includes the installation of all necessary system requirements including JDK, R plus all relevant packages, and Payara Micro."

# Install and set up project dependencies (netcdf library for XCMS, imagemagick and 
# graphviz libraries for RGraphviz), then purge apt-get lists.
# Thank you to Jack Howarth for his contributions in improving the Dockerfile.

# Install base packages and setup java environment (move from Java 8 to Java 11)
# R 3.5 set up via https://github.com/rocker-org/rocker/blob/master/r-ubuntu/bionic/Dockerfile
RUN apt-get update && \
    apt-get install -y software-properties-common \
    apt-transport-https \
    wget \
    locales \
    && add-apt-repository --enable-source --yes "ppa:marutter/rrutter3.5" \
    && add-apt-repository --enable-source --yes "ppa:marutter/c2d4u3.5" 

# make sure UTF-8
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen en_US.utf8 \
    && /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

ENV DEBIAN_FRONTEND noninteractive    

RUN apt-get update && \
    apt-get install -y software-properties-common sudo apt-transport-https apt-utils openjdk-8-jdk && \
    update-java-alternatives --jre-headless --jre --set java-1.8.0-openjdk-amd64

RUN apt-get update && \
    apt-get install -y \
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
    littler \
    r-base \
    r-base-dev \
    r-recommended && \
    ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r && \
    ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r && \
    install.r docopt && \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y \
    r-cran-biocmanager

# Need updated R serve not from CRAN
RUN R -e 'install.packages("Rserve",,"http://rforge.net/",type="source")'

# Need to install XML from specific repo
RUN R -e 'install.packages("XML", repos = "http://www.omegahat.net/R")'

# Install all R packages from CRAN
RUN install2.r RColorBrewer xtable fitdistrplus som ROCR RJSONIO gplots e1071 caTools igraph randomForest Cairo pls pheatmap lattice rmarkdown knitr data.table pROC Rcpp caret ellipse scatterplot3d lars tidyverse Hmisc reshape plyr car

# Install all R packages from Bioconductor 
RUN R -e 'BiocManager::install(c("impute", "pcaMethods", "siggenes", "globaltest", "GlobalAncova", "Rgraphviz", "KEGGgraph", "preprocessCore", "genefilter", "SSPA", "sva", "limma", "mzID", "xcms"))'

ADD rserve.conf /rserve.conf
ADD metab4script.R /metab4script.R
ADD run.sh /run.sh
RUN chmod +x /run.sh

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

ENV METABOANALYST_VERSION 4.93
ENV METABOANALYST_LINK https://www.dropbox.com/s/9xo4yy3gzqsvyj9/MetaboAnalyst-4.93.war?dl=0
ENV METABOANALYST_FILE_NAME MetaboAnalyst.war

RUN wget --quiet -O $DEPLOY_DIR/$METABOANALYST_FILE_NAME $METABOANALYST_LINK

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=90.0", "-jar", "/opt/payara/payara-micro.jar"]
CMD ["/run.sh", "--deploymentDir", "/opt/payara/deployments"]