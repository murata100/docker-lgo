FROM jupyter/scipy-notebook

USER root

RUN apt-get update && apt-get -y upgrade && \
  apt-get install -y apt-utils golang-1.10 libzmq3-dev pkg-config gnupg curl ssh

# Install lgo Jupyter lab extension to support code formatting.
# Please remove this line if you do not use JupyterLab.
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y nodejs && \
  jupyter labextension install @yunabe/lgo_extension && jupyter lab clean && \
  apt-get remove -y nodejs --purge && rm -rf /var/lib/apt/lists/*

USER jovyan

ENV GOPATH $HOME/go
ENV LGOPATH $HOME/lgo
ENV PATH $PATH:/usr/local/go/bin:$GOPATH/bin:/usr/lib/go-1.10/bin
WORKDIR ${HOME}

RUN go get -u github.com/golang/dep/cmd/dep && mkdir -p $GOPATH/src/Gopkgdir

# Support UTF-8 filename in Python (https://stackoverflow.com/a/31754469)
ENV LC_CTYPE=C.UTF-8

RUN mkdir -p $LGOPATH && mkdir -p $GOPATH

# Fetch lgo repository
RUN go get github.com/yunabe/lgo/cmd/lgo && go get -d github.com/yunabe/lgo/cmd/lgo-internal

# Install lgo
RUN lgo install
RUN python3 $GOPATH/src/github.com/yunabe/lgo/bin/install_kernel
