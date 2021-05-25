#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"                                                                                                                             
DATA_DIR=$THIS_DIR/../data/cases                                                                                                                                                                    
cd $DATA_DIR    
wget -nd -r --no-parent -P . -A zip http://5.35.247.113/data/cases/ 

