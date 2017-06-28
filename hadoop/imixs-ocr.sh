#!/bin/bash
# imixs-ocr
# This script performs a OCR conversion based on the tesseract library
# The script automatically converts PDF files into a TIF format, so this 
# script can be used for images as also for PDF files. 
# The text result is stored into a file ${FILENAME}.txt
#

DPI=300
TESS_LANG=deu
ISPDF=false

# test if input is pdf file
if [[ "$@" == *.pdf ]]
then
    ISPDF=true
fi


if ($ISPDF)
then
   # convert pdf to tif 
   FILENAME=${@%.pdf} 
   convert -density ${DPI} -depth 8 ${@} "${FILENAME}.tif"
   tesseract "${FILENAME}.tif" "$@" -l ${TESS_LANG}
   # remove tif
   rm "${FILENAME}.tif"
else
   tesseract "$@" "$@" -l ${TESS_LANG}
fi
