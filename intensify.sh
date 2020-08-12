#!/usr/bin/env bash
set -e

# make sure ImageMagick is around
which convert > /dev/null
im=$?
if [ $im -ne 0 ]; then
  echo "could not find ImageMagick"
  exit 1
fi

# make sure the image exists
if [[ ! -e "${1-}" ]]; then
  echo "no image called '$1' found"
  exit 1
fi

ORIG=$1
BASE=$(basename $ORIG .png)
OUTPUT="$BASE-intensifies.gif"
MOVEDIST=2
let DOUBLEMOVEDIST=$MOVEDIST*2

# make sure we don't clobber an existing output
if [[ -e $OUTPUT ]]; then
  echo "$OUTPUT already exists"
  exit 2
fi

convert $ORIG \
  -alpha set \
  -virtual-pixel Transparent \
  -set dispose 'Previous' \
  \( -clone 0 -distort SRT "0,0 1,1 0 -$MOVEDIST,-$MOVEDIST" \) \
  \( -clone 0 -distort SRT "0,0 1,1 0 $MOVEDIST,$MOVEDIST" \) \
  \( -clone 0 -distort SRT "0,0 0" \) \
  -set delay 10 \
  \( -clone 0 -distort SRT "0,0 1,1 0 -$MOVEDIST,-$DOUBLEMOVEDIST" \) \
  \( -clone 0 -distort SRT "0,0 1,1 0 $DOUBLEMOVEDIST,$MOVEDIST" \) \
  \( -clone 0 -distort SRT "0,0 0" \) \
  -set delay 7 \
  -loop 0 \
  $OUTPUT

convert -comment 'Made with intensifier.sh https://github.com/vtbassmatt/intensifier' \
  $OUTPUT $OUTPUT
