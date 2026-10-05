#!/bin/bash
# $1=prefix(A/B/C) $2 $3 $4 = durations ; output closing-$1.mp4
P=$1; D=($2 $3 $4); X=0.5; FPS=25
for i in 0 1 2; do
  n=$((i+1)); d=${D[$i]}; fr=$(python3 -c "print(int(($d+$X)*$FPS))")
  ffmpeg -v error -y -loop 1 -i cards/$P$n.png -vf "zoompan=z='1+0.05*on/$fr':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=$fr:s=1080x1920:fps=$FPS,format=yuv420p" -frames:v $fr -c:v libx264 -crf 18 -preset veryfast seg$P$n.mp4
done
o1=$(python3 -c "print(${D[0]})"); o2=$(python3 -c "print(${D[0]}+${D[1]})")
ffmpeg -v error -y -i seg${P}1.mp4 -i seg${P}2.mp4 -i seg${P}3.mp4 -filter_complex "[0][1]xfade=transition=fade:duration=$X:offset=$o1[a];[a][2]xfade=transition=fade:duration=$X:offset=$o2,fade=t=in:st=0:d=0.4[v]" -map "[v]" -c:v libx264 -crf 18 -preset veryfast -pix_fmt yuv420p -r $FPS closing-$P.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 closing-$P.mp4
