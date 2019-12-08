FROM debian:latest

ARG UID=1000
ARG TERRAFORM_VERSION

WORKDIR /root

# Baseline tools
RUN apt -y update && \
        apt -y install \
            apt-transport-https \
            ca-certificates \
            gnupg \
            nano \
            curl \
            python-pip \
            wget \
            unzip

# Google Cloud
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
        tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
            curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
            apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
            apt update -y && apt install -y google-cloud-sdk

# Azure
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# AWS
RUN pip install awscli

# Installs latest version of Terraform unless version is provided as argument
RUN TERRAFORM_VERSION=${TERRAFORM_VERSION:-$(curl -s  https://api.github.com/repos/hashicorp/terraform/releases/latest | \
        grep tag_name | sed -E 's/.*"v([^"]+)".*/\1/')}; \
        curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
        unzip terraform.zip -d /usr/local/bin && rm terraform.zip

RUN useradd -u ${UID} hostuser && mkdir /home/hostuser
WORKDIR /home/hostuser
USER hostuser
