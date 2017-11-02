#!/bin/sh
cd $(dirname $(realpath $0))    # change into script dir

. ./cmv.func

cmv_reg $1 $2

