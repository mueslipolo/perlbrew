#!/bin/bash

declare -a resources=("https://raw.githubusercontent.com/gugod/App-perlbrew/master/perlbrew" 
                      "https://raw.githubusercontent.com/gugod/patchperl-packing/master/patchperl"
                      "https://raw.githubusercontent.com/miyagawa/cpanminus/master/cpanm"
                      "https://raw.githubusercontent.com/skaji/cpm/master/cpm"
                      "https://www.cpan.org/src/5.0/perl-5.34.0.tar.gz"
                      )

## now loop through the above array
mkdir -p resources
cd resources
for i in "${resources[@]}"
do
   echo "$i"
   curl -s $i -O   
done