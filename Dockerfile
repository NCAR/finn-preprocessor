FROM kartoza/postgis:11.0-2.5

ENV PATH /opt/conda/bin:$PATH

RUN rm -fr /var/lib/apt/lists/* && apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 postgis git unzip

# 2020-06-27 somehow plpython3 seems to work out of box
#RUN apt-get install -y curl grep sed dpkg unzip python3-pip sudo postgresql-plpython3-11 
RUN apt-get install -y curl grep sed dpkg unzip python3-pip sudo

RUN TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate" >> ~/.bashrc && \
    export PATH="$HOME/miniconda/bin:$PATH"

RUN conda info && \
  . ~/.bashrc && \
  conda activate

RUN conda update conda
RUN conda install -c conda-forge \
	gdal=2.4 \
  "libgfortran-ng=7.2" \
	python=3.7 \
	jupyterlab=2.2.9 \
	ncurses=6.2 \
	pyproj=1.9.6 \
	beautifulsoup4=4.9.3 \
	shapely=1.6.4 \
	psycopg2=2.8.4 \
	matplotlib=2.2.5 \
	basemap=1.2.1

# verify that gdal is importable
RUN /opt/conda/bin/python -c "from osgeo import gdal"

# conda's networkx cannot be accessed, stuck with debian's python for plpython (set at compile time)
# apt has older version of networkx, cannot be used.
# so i have to use pip3
# also i SOULD specify version of library so that results are reproducible...
#RUN /usr/bin/pip3 install numpy scipy networkx
#RUN /usr/bin/pip3 install numpy==1.18.0 scipy networkx==2.4 # versions in finn2.2-preproc1.2a
RUN /usr/bin/pip3 install numpy==1.19.4 scipy==1.5.4 networkx==2.5 # versions installed as of 2020-11-07

EXPOSE 8888

# default database settings
ENV POSTGRES_USER=finn \
    POSTGRES_PASS=finn \
    POSTGRES_DBNAME=finn \
    PGDATABASE=finn \
    PGUSER=finn \
    PGPASSWORD=finn \
    PGHOST=localhost \
    PGPORT=5432


### # as of 2019-12-21, kartoza/postgis:11.0-2.5 has postgresql 11.6 and postgis
### # 3.0.0, for some reason.  And the binary does not have raster support at
### # compiler time.  I was told
### # https://github.com/kartoza/docker-postgis/issue/172 that raster support can
### # be enabled at run time
### 
### ENV POSTGRES_MULTIPLE_EXTENSIONS=postgis,postgis_raster
### 
### # the above to actually kick in i had to do below..., seems like?  Hope this
### # doesn't backfire when the postgis has raster enabled at compile time.  in
### # that case i will come back here and remove two lines around here
### 
### RUN echo "psql -d finn -c 'create extension postgis_raster;'" >> /docker-entrypoint.sh

ENTRYPOINT /docker-entrypoint.sh
