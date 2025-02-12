ARG CUDA_VERSION="12.1.1"
ARG CUDNN_VERSION="8"
ARG UBUNTU_VERSION="22.04"
ARG DOCKER_FROM=nvidia/cuda:$CUDA_VERSION-cudnn$CUDNN_VERSION-devel-ubuntu$UBUNTU_VERSION

# Base NVidia CUDA Ubuntu image
FROM --platform=amd64 $DOCKER_FROM AS base

# Install Python plus openssh, which is our minimum set of required packages.
RUN apt-get update -y && \
    apt-get install -y python3 python3-pip python3-venv && \
    apt-get install -y --no-install-recommends openssh-server openssh-client git git-lfs && \
    python3 -m pip install --upgrade pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/usr/local/cuda/bin:${PATH}"

# Install pytorch
ARG PYTORCH="2.1.1"
ARG CUDA="121"
RUN pip3 install --no-cache-dir -U torch==$PYTORCH torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu$CUDA

WORKDIR /root

# Install text-generation-webui, including all extensions
# Also includes exllama
# We remove the ExLlama automatically installed by text-generation-webui
# so we're always up-to-date with any ExLlama changes, which will auto compile its own extension
RUN git clone https://github.com/oobabooga/text-generation-webui && \
    cd text-generation-webui && \
    # checkout a specific commit to avoid breaking changes in the future
    git checkout 7cf1402 && \
    pip3 install -r requirements.txt && \
    bash -c 'for req in extensions/*/requirements.txt ; do pip3 install -r "$req" ; done' && \
    #pip3 uninstall -y exllama && \
    mkdir -p repositories && \
    cd repositories && \
    git clone https://github.com/turboderp/exllama && \
    pip3 install -r exllama/requirements.txt && \
    # upgrade safetensors to latest version because the previous line installs an old version
    pip3 install --upgrade safetensors && \
    # install older version of flash_attn and transformers because the latest versions break the template
    pip3 install flash_attn==2.5.5 && \
    #pip3 install --upgrade gradio && \
    # install older version of transformers because the latest version is incompatible with AutoGPTQ
    pip3 install transformers==4.37.2 && \
    # upgrade exllama to latest version without upgrading its dependencies because it causes the image to blow up in size and breaks the template
    pip3 install --upgrade --no-deps exllamav2

WORKDIR /
COPY --chmod=755 scripts /root/scripts

COPY --chmod=755 start-with-ui.sh /start.sh

WORKDIR /workspace

CMD [ "/start.sh" ]
