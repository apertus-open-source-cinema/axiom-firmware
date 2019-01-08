#!/bin/bash

BASE=/opt/diamond/3.5_x64/
bindir=${BASE}/bin/lin64/
fpgadir=${BASE}/ispfpga
fpgabindir=${fpgadir}/bin/lin64/

#setup path
PATH="${bindir}:${fpgabindir}:${PATH}"
export PATH

#setup library path
LD_LIBRARY_PATH="${bindir}:${fpgabindir}"
export LD_LIBRARY_PATH

#setup license
LM_LICENSE_FILE="${bindir}/../../license/license.dat"
export LM_LICENSE_FILE

#setup foundry
FOUNDRY=${fpgadir}
export FOUNDRY
