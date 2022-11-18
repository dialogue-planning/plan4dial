FROM python:3.8

WORKDIR /root

# This run command will make dockerfile auto convert line endings
RUN apt-get update -q \
        && apt-get upgrade -qy \
        && apt-get install -qy dos2unix

COPY install-apptainer-ubuntu.sh /root/install-apptainer-ubuntu.sh
RUN dos2unix install-apptainer-ubuntu.sh

RUN bash install-apptainer-ubuntu.sh 1.0.3 1.18.3 \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    bash-completion \
    ca-certificates \
    git \
    libseccomp-dev \
    python3 \
    python3-pip \
    python3-venv \
    tzdata \
    unzip \
    vim \
    wget \
    build-essential \
    gcc-x86-64-linux-gnu \
    python3-dev \
    g++ \
    cmake \
    make \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /root/app/

COPY requirements.txt .

RUN pip install -r requirements.txt

RUN python -m spacy download en_core_web_md


COPY rbp.sif /root/rbp.sif
RUN chmod +x /root/rbp.sif
