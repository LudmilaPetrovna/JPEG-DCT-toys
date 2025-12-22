#!/bin/bash

rm -f R0.jpg tmp.jpg *.jpg
convert R0.png -quality 100 R0.jpg

for q in {"","-rotate "{90,180,270}}" "{"","-flip "{"horizontal","vertical"}}" "{"","-transpose "}" "{"","-transverse"}; do 
jpegtran -outfile tmp.jpg -perfect $q -grayscale -optimize -copy none R0.jpg
SUM=`md5sum tmp.jpg | cut -b1-32`
FILENAME="R0 tran ${SUM}${q}";
FILENAME="R0 tran ${q}";
FILENAME=`sed -r "s, +$,,g;s,[- ]+,-,g" <<< $FILENAME`'.jpg';
mv -v tmp.jpg "$FILENAME"
done
