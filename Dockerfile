FROM quay.io/isciences/tops-school:latest

USER root
RUN pip install nbgitpuller
USER rstudio
