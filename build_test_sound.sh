for q in {6,12,16,24,32,48,64,128,256}; do
ffmpeg -strict -2 -i '11. ON3 - Bosonic Field.mp3' -map_metadata -1 -vn -acodec libopus -b:a ${q}k -y opus-test-${q}k.opus;
done
