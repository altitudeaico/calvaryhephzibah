#!/usr/bin/env python3
"""Render an animated closing sequence: several beats, one after another.

A single card cannot carry an argument. This renders a short sequence - a
premise, a turn, and a landing - each beat fading up, holding, and clearing
before the next. The rhythm does the work: the pause between beats is where
the viewer supplies the thought themselves.

Spec is a JSON file:

    {"beats": [
       {"lines": ["You think church is for", "people with problems."]},
       {"lines": ["You are right."], "red": 0},
       {"lines": ["That is exactly", "who it is for."], "red": 1}
     ]}

Usage: python3 render_quotecard.py spec.json out.mp4
"""
import json, os, subprocess, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

W, H, FPS = 1080, 1920, 25
OBS=(11,11,14); BONE=(244,239,230); RED=(208,68,28)
R="/home/claude/calvaryhephzibah"
FD=R+"/anniversary/overlays/fonts"
IN, HOLD, OUT, GAP = 0.55, 1.45, 0.40, 0.22
STAGGER = 0.16

def ground():
    img=Image.new("RGB",(W,H),OBS)
    glow=Image.new("L",(W,H),0); gd=ImageDraw.Draw(glow)
    for r in range(1500,0,-10):
        gd.ellipse([380-r,1650-r,380+r,1650+r],fill=int(42*(1-r/1500)**1.7))
    img=Image.composite(Image.new("RGB",(W,H),(150,62,20)),img,glow)
    d=ImageDraw.Draw(img)
    for (x,y,dx,dy) in [(70,70,1,1),(W-70,70,-1,1),(70,H-70,1,-1),(W-70,H-70,-1,-1)]:
        d.line([(x,y),(x+dx*66,y)],fill=RED,width=5)
        d.line([(x,y),(x,y+dy*66)],fill=RED,width=5)
    return img

def ease(t): return 1-(1-t)**3

def fit(d, lines, cap=112):
    size=cap
    while size>46:
        f=ImageFont.truetype(FD+"/anton-400.ttf",size)
        if max(d.textlength(l,font=f) for l in lines)<=W-150: return f,size
        size-=4
    return ImageFont.truetype(FD+"/anton-400.ttf",46),46

def render(spec,out):
    beats=spec["beats"]
    base=ground(); d0=ImageDraw.Draw(base)
    prep=[]
    for b in beats:
        f,size=fit(d0,b["lines"])
        prep.append({"lines":b["lines"],"font":f,"size":size,"red":b.get("red")})
    bd=IN+HOLD+OUT+GAP
    total=bd*len(beats); n=int(total*FPS)
    tmp="/tmp/qframes"; os.system(f"rm -rf {tmp}; mkdir -p {tmp}")
    for fi in range(n):
        t=fi/FPS
        idx=min(int(t//bd),len(prep)-1); lt=t-idx*bd; b=prep[idx]
        img=base.copy()
        layer=Image.new("RGBA",(W,H),(0,0,0,0)); ld=ImageDraw.Draw(layer)
        lh=int(b["size"]*1.13); y0=(H-lh*len(b["lines"]))//2
        for i,line in enumerate(b["lines"]):
            p=min(1.0,max(0.0,(lt-i*STAGGER)/IN))
            if p<=0: continue
            e=ease(p)
            col=RED if (b["red"] is not None and i==b["red"]) else BONE
            x=(W-ld.textlength(line,font=b["font"]))/2
            y=y0+i*lh+int(26*(1-e))
            ld.text((x,y),line,font=b["font"],fill=col+(int(255*e),))
        clear=IN+HOLD
        if lt>clear:
            k=1-min(1.0,(lt-clear)/OUT)
            arr=np.array(layer); arr[:,:,3]=(arr[:,:,3]*k).astype(np.uint8)
            layer=Image.fromarray(arr)
        img.paste(layer,(0,0),layer)
        img.save(f"{tmp}/f{fi:04d}.png")
    subprocess.run(["ffmpeg","-nostdin","-v","error","-y","-framerate",str(FPS),
        "-i",f"{tmp}/f%04d.png","-c:v","libx264","-crf","18","-preset","veryfast",
        "-pix_fmt","yuv420p","-r",str(FPS),out],check=True)
    print(f"{out}  {len(beats)} beats, {round(total,1)}s")

if __name__=="__main__":
    render(json.load(open(sys.argv[1])),sys.argv[2])
