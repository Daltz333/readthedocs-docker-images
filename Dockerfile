# Read the Docs - Environment base
FROM ubuntu:18.04
LABEL mantainer="Read the Docs <support@readthedocs.com>"
LABEL version="5.0.0"

ENV DEBIAN_FRONTEND noninteractive
ENV APPDIR /app
ENV LANG C.UTF-8

# Versions, and expose labels for external usage
ENV RTD_PYTHON_VERSION_27 2.7.16
ENV RTD_PYTHON_VERSION_35 3.5.7
ENV RTD_PYTHON_VERSION_36 3.6.8
ENV RTD_PYTHON_VERSION_37 3.7.3
ENV RTD_PYTHON_VERSION_38 3.8.0
ENV RTD_PYPY_VERSION_35 pypy3.5-7.0.0

# Note: 4.7.12.1 drastically increases memory usage
ENV RTD_CONDA_VERSION 4.6.14

ENV RTD_PIP_VERSION 20.0.1
ENV RTD_SETUPTOOLS_VERSION 45.1.0
ENV RTD_VIRTUALENV_VERSION 16.7.9
LABEL python.version_27=$RTD_PYTHON_VERSION_27
LABEL python.version_35=$RTD_PYTHON_VERSION_35
LABEL python.version_36=$RTD_PYTHON_VERSION_36
LABEL python.version_37=$RTD_PYTHON_VERSION_37
LABEL python.version_38=$RTD_PYTHON_VERSION_38
LABEL pypy.version_35=$RTD_PYPY_VERSION_35
LABEL conda.version=$RTD_CONDA_VERSION

# System dependencies
RUN apt-get -y update
RUN apt-get -y install \
      software-properties-common \
      vim

# Install requirements
RUN apt-get -y install \
      build-essential \
      bzr \
      curl \
      doxygen \
      g++ \
      git-core \
      graphviz-dev \
      libbz2-dev \
      libcairo2-dev \
      libenchant1c2a \
      libevent-dev \
      libffi-dev \
      libfreetype6 \
      libfreetype6-dev \
      libgraphviz-dev \
      libjpeg8-dev \
      libjpeg-dev \
      liblcms2-dev \
      libmysqlclient-dev \
      libpq-dev \
      libreadline-dev \
      libsqlite3-dev \
      libtiff5-dev \
      libwebp-dev \
      libxml2-dev \
      libxslt1-dev \
      libxslt-dev \
      mercurial \
      pandoc \
      pkg-config \
      postgresql-client \
      subversion \
      zlib1g-dev

# pyenv extra requirements
# https://github.com/pyenv/pyenv/wiki/Common-build-problems
RUN apt-get install -y \
      liblzma-dev \
      libncurses5-dev \
      libncursesw5-dev \
      libssl-dev \
      llvm \
      make \
      python-openssl \
      tk-dev \
      wget \
      xz-utils

# LaTeX -- split to reduce image layer size
RUN apt-get -y install \
      texlive-fonts-extra
RUN apt-get -y install \
      texlive-latex-extra-doc \
      texlive-pictures-doc \
      texlive-publishers-doc
RUN apt-get -y install \
      texlive-lang-english \
      texlive-lang-japanese
RUN apt-get -y install \
      texlive-full

# lmodern: extra fonts
# https://github.com/rtfd/readthedocs.org/issues/5494
#
# xindy: is useful to generate non-ascii indexes
# https://github.com/rtfd/readthedocs.org/issues/4454
#
# fonts-noto-cjk-extra
# fonts-hanazono: chinese fonts
# https://github.com/readthedocs/readthedocs.org/issues/6319
RUN apt-get -y install \
      fonts-symbola \
      lmodern \
      latex-cjk-chinese-arphic-bkai00mp \
      latex-cjk-chinese-arphic-gbsn00lp \
      latex-cjk-chinese-arphic-gkai00mp \
      texlive-fonts-recommended \
      fonts-noto-cjk-extra \
      fonts-hanazono \
      xindy

# plantuml: is to support sphinxcontrib-plantuml
# https://pypi.org/project/sphinxcontrib-plantuml/
#
# imagemagick: is to support sphinx.ext.imgconverter
# http://www.sphinx-doc.org/en/master/usage/extensions/imgconverter.html
#
# inkscape: required to support more accurate svg conversion
#
# rsvg-convert: is for SVG -> PDF conversion
# using Sphinx extension sphinxcontrib.rsvgconverter, see
# https://github.com/missinglinkelectronics/sphinxcontrib-svg2pdfconverter
#
# swig: is required for different purposes
# https://github.com/rtfd/readthedocs-docker-images/issues/15
RUN apt-get -y install \
      imagemagick \
      inkscape \
      librsvg2-bin \
      plantuml \
      swig

# Install Python tools/libs
RUN apt-get -y install \
      python-pip \
 && pip install -U \
      auxlib \
      virtualenv==$RTD_VIRTUALENV_VERSION

# sphinx-js dependencies: jsdoc and typedoc (TypeScript support)
RUN apt-get -y install \
      nodejs \
      npm \
 && npm install --global \
      jsdoc \
      typedoc

# UID and GID from readthedocs/user
RUN groupadd --gid 205 docs
RUN useradd -m --uid 1005 --gid 205 docs

USER docs
WORKDIR /home/docs

# Install Conda
RUN curl -O https://repo.continuum.io/miniconda/Miniconda2-${RTD_CONDA_VERSION}-Linux-x86_64.sh
RUN bash Miniconda2-${RTD_CONDA_VERSION}-Linux-x86_64.sh -b -p /home/docs/.conda/
ENV PATH $PATH:/home/docs/.conda/bin
RUN rm -f Miniconda2-${RTD_CONDA_VERSION}-Linux-x86_64.sh

# Install pyenv
RUN wget https://github.com/pyenv/pyenv/archive/master.zip
RUN unzip master.zip && \
    rm -f master.zip && \
    mv pyenv-master ~docs/.pyenv
ENV PYENV_ROOT /home/docs/.pyenv
ENV PATH /home/docs/.pyenv/shims:$PATH:/home/docs/.pyenv/bin

# Install supported Python versions
RUN pyenv install $RTD_PYTHON_VERSION_27 && \
    pyenv install $RTD_PYTHON_VERSION_38 && \
    pyenv install $RTD_PYTHON_VERSION_37 && \
    pyenv install $RTD_PYTHON_VERSION_35 && \
    pyenv install $RTD_PYTHON_VERSION_36 && \
    pyenv install $RTD_PYPY_VERSION_35 && \
    pyenv global \
        $RTD_PYTHON_VERSION_27 \
        $RTD_PYTHON_VERSION_38 \
        $RTD_PYTHON_VERSION_37 \
        $RTD_PYTHON_VERSION_36 \
        $RTD_PYTHON_VERSION_35 \
        $RTD_PYPY_VERSION_35

WORKDIR /tmp

RUN pyenv local $RTD_PYTHON_VERSION_27 && \
    pyenv exec pip install --no-cache-dir -U pip==20.0.1 && \
    pyenv exec pip install --no-cache-dir -U setuptools==44.0.0 && \
    pyenv exec pip install --no-cache-dir --only-binary numpy,scipy numpy scipy && \
    pyenv exec pip install --no-cache-dir pandas matplotlib virtualenv==16.7.9

RUN pyenv local $RTD_PYTHON_VERSION_38 && \
    pyenv exec pip install --no-cache-dir -U pip==$RTD_PIP_VERSION && \
    pyenv exec pip install --no-cache-dir -U setuptools==$RTD_SETUPTOOLS_VERSION && \
    pyenv exec pip install --no-cache-dir --only-binary numpy numpy && \
    pyenv exec pip install --no-cache-dir pandas matplotlib virtualenv==$RTD_VIRTUALENV_VERSION

RUN pyenv local $RTD_PYTHON_VERSION_37 && \
    pyenv exec pip install --no-cache-dir -U pip==$RTD_PIP_VERSION && \
    pyenv exec pip install --no-cache-dir -U setuptools==$RTD_SETUPTOOLS_VERSION && \
    pyenv exec pip install --no-cache-dir --only-binary numpy,scipy numpy scipy && \
    pyenv exec pip install --no-cache-dir pandas matplotlib virtualenv==$RTD_VIRTUALENV_VERSION

RUN pyenv local $RTD_PYTHON_VERSION_36 && \
    pyenv exec pip install --no-cache-dir -U pip==$RTD_PIP_VERSION && \
    pyenv exec pip install --no-cache-dir -U setuptools==$RTD_SETUPTOOLS_VERSION && \
    pyenv exec pip install --no-cache-dir --only-binary numpy,scipy numpy scipy && \
    pyenv exec pip install --no-cache-dir pandas matplotlib virtualenv==$RTD_VIRTUALENV_VERSION

RUN pyenv local $RTD_PYTHON_VERSION_35 && \
    pyenv exec pip install --no-cache-dir -U pip==$RTD_PIP_VERSION && \
    pyenv exec pip install --no-cache-dir -U setuptools==$RTD_SETUPTOOLS_VERSION && \
    pyenv exec pip install --no-cache-dir --only-binary numpy,scipy numpy scipy && \
    pyenv exec pip install --no-cache-dir pandas matplotlib virtualenv==$RTD_VIRTUALENV_VERSION

RUN pyenv local $RTD_PYPY_VERSION_35 && \
    pyenv exec python -m ensurepip && \
    pyenv exec pip3 install --no-cache-dir -U pip==$RTD_PIP_VERSION && \
    pyenv exec pip install --no-cache-dir -U setuptools==$RTD_SETUPTOOLS_VERSION && \
    pyenv exec pip install --no-cache-dir virtualenv==$RTD_VIRTUALENV_VERSION

WORKDIR /

CMD ["/bin/bash"]
