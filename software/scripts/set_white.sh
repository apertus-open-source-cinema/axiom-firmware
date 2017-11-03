#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir

./mat4_conf.sh 0 0 0 0  0 0 0 $1  0 $2 $2 0  $3 0 0 0 
echo "./mat4_conf.sh 0 0 0 0  0 0 0 $1  0 $2 $2 0  $3 0 0 0 "
