#!/bin/bash
# $1 clip $2 cliplen $3 closing $4 endcard $5 bed $6 bedoffset $7 out
CLIP=$1; VEND=$2; CL=$3; EC=$4; BED=$5; OFF=$6; OUT=$7
CD=$(ffprobe -v error -show_entries format=duration -of csv=p=0 $CL)
PAD=$(python3 -c "print(round($CD+3.2,2))"); TOTAL=$(python3 -c "print(round($VEND+$CD+3,2))"); FO=$(python3 -c "print(round($TOTAL-1.8,2))")
ffmpeg -v error -y -i $CLIP -i $CL -loop 1 -t 3 -i $EC -ss $OFF -i $BED -filter_complex "\
[0:v]trim=0:$VEND,setpts=PTS-STARTPTS,scale=1080:1920,fps=25,setsar=1[v0];\
[1:v]scale=1080:1920,fps=25,setsar=1,format=yuv420p[v1];\
[2:v]scale=1080:1920,fps=25,setsar=1,format=yuv420p,fade=t=in:st=0:d=0.5[v2];\
[v0][v1][v2]concat=n=3:v=1:a=0[v];\
[0:a]atrim=0:$VEND,asetpts=PTS-STARTPTS,afade=t=out:st=$(python3 -c "print($VEND-0.25)"):d=0.25,highpass=f=90,acompressor=threshold=-22dB:ratio=3.5:attack=8:release=180,loudnorm=I=-14:TP=-1.5:LRA=11,apad=pad_dur=$PAD[a0];\
[3:a]volume=-6dB,afade=t=in:st=0:d=1.2,volume='if(gt(t,$VEND),1.7,1)':eval=frame,afade=t=out:st=$FO:d=1.8[a1];\
[a0][a1]amix=inputs=2:duration=first:dropout_transition=0:normalize=0,atrim=0:$TOTAL,alimiter=limit=0.97[a]" \
-map "[v]" -map "[a]" -c:v libx264 -crf 21 -preset veryfast -pix_fmt yuv420p -c:a aac -b:a 192k -ar 48000 -movflags +faststart $OUT
ffprobe -v error -show_entries format=duration -of csv=p=0 $OUT; ls -la $OUT | awk '{print $5}'
