
# Offset tuning: until the black reference columns are around 128 (not critical, +/-50 is fine)
# ADC_RANGE tuning: until an overexposed image (by 2 stops or so) reaches 4000 at 99.9th percentile
# this is so it won't clip harshly to white, and to also use the full range

case $1 in 
   ("1")
        GAIN=0
        ADC_RANGE=0x3eb
    ;;
   ("2")
        GAIN=1
        ADC_RANGE=0x3d5
    ;;
   ("3")
        GAIN=3
        ADC_RANGE=0x3d5  # to be double-checked
    ;;
   ("4")
        GAIN=7
        ADC_RANGE=0x3d5
    ;;
   ("3/3" | "3_3")
        GAIN=11
        ADC_RANGE=0x3e9
    ;;

    (*)
        echo "Usage: $0 <gain>"
        echo "Available gains: 1 2 3 4 3/3"
        exit
    ;;
esac

echo "Setting gain x$1 ($GAIN,$ADC_RANGE)..."
. ./cmv.func
cmv_reg 115 $GAIN      # gain
cmv_reg 116 $ADC_RANGE # ADC_range fine-tuned for each gain
cmv_reg 100 1          # ADC_range_mult2
cmv_reg 87 2000        # offset 1
cmv_reg 88 2000        # offset 2
