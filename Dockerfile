ARG PROJECT_DIR=/apps
ARG PERLBREW_ROOT=/usr/local/perl
ARG PERL_VERSION=5.34.0

# Perlbrew common
FROM centos:centos8 as perl-base
ARG PROJECT_DIR
ARG PERLBREW_ROOT
ARG PERL_VERSION

RUN yum update -y
RUN yum install -y perl
RUN yum clean all

ENV PERLBREW_ROOT $PERLBREW_ROOT
ENV PATH $PERLBREW_ROOT/bin:$PATH

RUN mkdir -p $PERLBREW_ROOT

COPY resources/perlbrew /tmp
COPY resources/perlbrew-install /tmp

RUN chmod +x /tmp/perlbrew-install
RUN /tmp/perlbrew-install

COPY resources/patchperl $PERLBREW_ROOT/bin/patchperl
COPY resources/cpanm $PERLBREW_ROOT/bin/cpanm
COPY resources/cpm $PERLBREW_ROOT/bin/cpm
RUN chmod +x /$PERLBREW_ROOT/bin/*

RUN mkdir -p $PROJECT_DIR
WORKDIR $PROJECT_DIR

# Perl compile + Carton install
FROM perl-base as perl-perlbrew
ARG PROJECT_DIR
ARG PERLBREW_ROOT
ARG PERL_VERSION

RUN yum install -y yum-utils
RUN yum-builddep -y perl
RUN yum install -y bzip2 zip procps
RUN yum groupinstall -y 'Development Tools'

ENV PERLBREW_ROOT $PERLBREW_ROOT
ENV PATH $PERLBREW_ROOT/bin:$PATH
COPY resources/perl-${PERL_VERSION}.tar.gz /usr/local/perl/dists/
RUN perlbrew --notest --noman -j 4 install perl-$PERL_VERSION --as current
RUN perlbrew exec --with current cpanm Carton

# Builder
FROM perl-perlbrew as perl-builder
COPY cpanfile ./
RUN perlbrew exec --with current carton install

# Runner
FROM perl-base as perl-runner

ENV PATH $PERLBREW_ROOT/perls/current/bin:$PATH
ENV PERLBREW_PERL current
ENV PERLBREW_SKIP_INIT 1

ARG PROJECT_DIR
COPY --from=perl-perlbrew $PERLBREW_ROOT/perls/ $PERLBREW_ROOT/perls
RUN mkdir -p $PROJECT_DIR
COPY --from=perl-builder $PROJECT_DIR/local ./local
COPY myapp.pl ./