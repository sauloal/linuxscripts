#!/bin/bash
git archive HEAD | gzip > archive.tar.gz

#http://gitready.com/intermediate/2009/01/29/exporting-your-repository.html
#git checkout-index -f -a --prefix=/path/to/folder/
#git checkout-index -f --prefix=/path/to/folder/ bin/* README.textile

