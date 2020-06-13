#!/bin/sh
cd $(dirname $(realpath $0))    # change into script dir

. ./cmv.func

fil_reg $1 $2
