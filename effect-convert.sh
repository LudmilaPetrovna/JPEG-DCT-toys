#!/bin/bash

rm -f R0-convert*
convert ref/R0.png -quality 100 R0.jpg
echo "<html><body>" > effect-convert-compare.html

cat <<CODE | while read aa; do
-flip
-flop
-transpose
-transverse
-rotate 90
-rotate 180
-rotate 270
-shade 70
-sepia-tone 127
-radial-blur 50
-noise 1x1
-negate
+level 0%,0%
+level 0%,10%
+level 0%,20%
+level 0%,30%
+level 0%,40%
+level 0%,50%
+level 0%,60%
+level 0%,70%
+level 0%,80%
+level 0%,90%
+level 0%,100%
+level 0%,100%
+level 10%,100%
+level 20%,100%
+level 30%,100%
+level 40%,100%
+level 50%,100%
+level 60%,100%
+level 70%,100%
+level 80%,100%
+level 90%,100%
+level 100%,100%
+level 0%
+level 10%
+level 20%
+level 30%
+level 40%
+level 50%
+level 60%
+level 70%
+level 80%
+level 90%
+level 100%
-contrast
-emboss 1
-edge 1
-sharpen 1x1
-unsharp 1x1
-motion-blur 0x1
-gaussian-blur 0x1
-blur 0x1
CODE

FILENAME_JPEG="R0-convert"`sed -r "s, +$,,g;s,[-+%\, ]+,-,g;s,-$,,g" <<< $aa`'.jpg';
convert ref/R0.png $aa -colorspace gray -quality 100 -strip $FILENAME_JPEG

FILENAME_BIG="R0-convert"`sed -r "s, +$,,g;s,[-+%\, ]+,-,g;s,-$,,g" <<< $aa`'-big.png';
convert ref/R0.png $aa -colorspace gray -scale 1000%  -gravity north -font /usr/share/fonts/truetype/Fifaks10Dev1.ttf -pointsize 12 -fill green -annotate 0x0+0+0 "$aa" $FILENAME_BIG

LIST="$LIST $FILENAME_BIG"

echo "opt $aa $FILENAME"
montage -background green -geometry 80x80+1+1 -tile 10x $LIST tmp.jpg

echo "Creating comparison with effect '$aa'..."
OUTCOMP="jpeg_effect_convert"`sed -r "s, +$,,g;s,[-+%\, ]+,-,g;s,-$,,g" <<< $aa`"_compare.png"
perl compare_jpeg.pl R0.jpg "$FILENAME_JPEG" "$OUTCOMP"


echo "<img src=$OUTCOMP><br>" >> effect-convert-compare.html
done
