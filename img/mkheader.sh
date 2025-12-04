#!/bin/bash

convert example.png -resize 640x320^ -gravity south -crop 640x320+0+0 +repage -gravity north -font /usr/share/fonts/truetype/Fifaks10Dev1.ttf -pointsize 90 -fill green -annotate 0x0+0+0 "JPEG IDCT TOYS" header.png
