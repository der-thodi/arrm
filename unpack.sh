#!/bin/bash

DOWNLOAD_DIR=~/Downloads
BASE_DIR=~/reddit
ZIP_DIR=${BASE_DIR}/zips

mv ${DOWNLOAD_DIR}/export_*_*.zip ${ZIP_DIR}/

cd ${ZIP_DIR}

for f in *.zip
do
  base=$(basename -s .zip $f)
  cd ${BASE_DIR}
  if [[ ! -d ${base} ]]
  then
    echo ${base}
    mkdir ${base}
    cd ${base}
    unzip -q ${ZIP_DIR}/${f}
  fi
done
