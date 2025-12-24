#!/bin/bash

echo "<html><body>" > jpeg_quality_compare.html
for q in {100..0}; do
echo "Creating comparison with '-quality $q'..."
OUTJPEG="R0-conv-q${q}.jpg"
OUTCOMP="jpeg_quality_100_vs_${q}.png"
convert ref/R0.png -quality $q "$OUTJPEG"
perl compare_jpeg.pl R0.jpg "$OUTJPEG" "$OUTCOMP"
echo "<img src=$OUTCOMP><br>" >> jpeg_quality_compare.html
done
