#!/bin/bash
cd $(dirname $(realpath $0))    # change into script dir

shw_grey () {
    echo $(tput bold)$(tput setaf 0)$@$(tput sgr 0)
}

shw_warn () {
    echo $(tput bold)$(tput setaf 2)$@$(tput sgr 0)
}
shw_err ()  {
    echo $(tput bold)$(tput setaf 1)$@$(tput sgr 0)
}

STORE="/opt/calibration"
mkdir -p $STORE
FREE=$(df -P $STORE | awk 'NR==2 {print $4}')

echo -e "RCN calibration\n"
# 64*19 (4096*3072*12bit=18.432 MB) = 1216 MB
RCN_SPACE="1245184" # kB

if [ "$FREE" -lt "$RCN_SPACE" ]; then
  shw_err "Error: not enough free space in $STORE"
  exit 1
fi

# reset calibration
./rcn_clear.py 1>/dev/null
./set_gain.sh 1 1>/dev/null

# disable HDMI stream
./cmv.func; fil_reg 15 0

# take 64 dark frames at 10ms
echo "taking 64 dark frames at 10ms"
mkdir -p $STORE/rcn
for i in $(seq 1 64); do
  .../sensor-tools/snap -2 -b -r -e 10ms > $STORE/rcn/dark-x1-10ms-$i.raw12 2>/dev/null
  printf "capturing darkframe $i of 64"\\r
done

printf "captured darkframe 64 of 64 \n"

# enable HDMI stream
./cmv.func; fil_reg 15 0x01000100

# compute a temporary darkframe for calibration
echo -e "\n\nCalculate darkframe"
raw2dng --swap-lines --no-blackcol --calc-darkframe $STORE/rcn/dark-x1-10ms-*.raw12

# clean up
rm -rf $STORE/rcn


# clean up
rm -rf $STORE

