# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
#
# A modification of jupyter/all-spark-notebook
FROM jupyter/pyspark-notebook

MAINTAINER Clark Fitzgerald <clarkfitzg@gmail.com>

USER root

# RSpark config
ENV R_LIBS_USER $SPARK_HOME/R/lib

# R pre-requisites
#RUN apt-get update && \
    #apt-get install -y --no-install-recommends \
    #fonts-dejavu \
    #gfortran \
    #gcc && apt-get clean && \
    #rm -rf /var/lib/apt/lists/*
#
# Comment out to stay as root?
#USER $NB_USER

# Install R
RUN apt-get update
RUN apt-get install -y r-base

# Need packages irkernel for notebook, sparkapi, ddR
#RUN R --quiet -e "install.packages('devtools')"
#RUN R --quiet -e "devtools::install_github"
