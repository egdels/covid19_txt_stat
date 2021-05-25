#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"                                                                                                                             
DATA_DIR=$THIS_DIR/../data/cases                                                                                                                                                                    
                                                                                                                                                                                                      
cd $DATA_DIR    

wget -O $(date +%Y-%m-%d).csv https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv

