#!/bin/bash

for file in `ls /NAS_DIST02/cdn/import_mpg/hybrid_rvod/ | grep mp4`; do
        fileName=`echo ${file} | cut -d"." -f1 | sed -e "s/[[:space:]]*$//"`
        echo ${fileName}
        if [[ ${#fileName} -gt 0 ]]; then
                rm -f /NAS_DIST02/cdn/import_mpg/hybrid_rvod/${file}
                touch /NAS_DIST02/cdn/loaded/hybrid_rvod/${fileName}.sig
        fi
done
