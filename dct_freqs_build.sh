#!/bin/bash

rm -f dct_freqs
gcc -std=c89 -O2 dct_freqs.c -lm -o dct_freqs

for SIDE in {8,256}; do
echo "Producing DCT tiles, size: $SIDE..."
SIZE="${SIDE}x${SIDE}"

./dct_freqs $SIDE | ffmpeg -v 0 -f rawvideo -s $SIZE -pix_fmt gray -i - -y freqs-$SIZE-%02d.png
montage -geometry $SIZE+0+0 -tile 8x freqs-$SIZE-*.png freqs-pano-$SIZE.png
convert freqs-pano-$SIZE.png -interpolate Nearest -interpolative-resize 1000x1000 freqs-pano-$SIZE-1000.png
done