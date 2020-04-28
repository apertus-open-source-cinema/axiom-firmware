#!/bin/sh
cd $(dirname $(realpath $0))    # change into script dir

. ./cmv.func

fig_reg $1 $2
