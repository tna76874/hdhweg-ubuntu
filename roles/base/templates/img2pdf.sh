#!/bin/bash
NAME=$(date '+%Y%m%d_%H%M%S')
pdfjam --a4paper "$@" --outfile .imagepdfs.pdf >/dev/null 2>&1
ps2pdf .imagepdfs.pdf .out.pdf
mv .out.pdf .imagepdfs.pdf
gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$NAME"_bilder.pdf .imagepdfs.pdf
rm .imagepdfs.pdf
