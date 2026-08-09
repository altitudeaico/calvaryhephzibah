from PIL import Image, ImageDraw, ImageFont, ImageEnhance
import numpy as np, os, sys

W, H = 1080, 1920
OBS=(11,11,14); BONE=(244,239,230); RED=(208,68,28); GREY=(176,169,158)
R="/home/claude/calvaryhephzibah"
FD=R+"/anniversary/overlays/fonts"
def anton(s): return ImageFont.truetype(FD+"/anton-400.ttf", s)
def it7(s): return ImageFont.truetype(FD+"/inter-tight-700.ttf", s)
def it6(s): return ImageFont.truetype(FD+"/inter-tight-600.ttf", s)

def tracked(d,xy,t,f,fill,tr=0.18):
    x,y=xy
    for c in t:
        d.text((x,y),c,font=f,fill=fill); x+=d.textlength(c,font=f)+f.size*tr
    return x
def twidth(d,t,f,tr=0.18):
    return sum(d.textlength(c,font=f)+f.size*tr for c in t)-f.size*tr

img=Image.new("RGB",(W,H),OBS)
glow=Image.new("L",(W,H),0); gd=ImageDraw.Draw(glow)
for r in range(1400,0,-8):
    gd.ellipse([540-r,1500-r,540+r,1500+r],fill=int(46*(1-r/1400)**1.7))
img=Image.composite(Image.new("RGB",(W,H),(150,62,20)),img,glow)

# eagle roundel, centred upper third
ep=R+"/anniversary-design-system/assets/logo-eagle.png"
eag=Image.open(ep).convert("RGBA")
ew=760; eag=eag.resize((ew,int(eag.height*ew/eag.width)),Image.LANCZOS)
disc=Image.new("RGBA",(W,H),(0,0,0,0)); dd=ImageDraw.Draw(disc)
dd.ellipse([540-235,560-235,540+235,560+235],fill=RED+(255,))
img.paste(disc,(0,0),disc)
img.paste(eag,(540-ew//2,560-eag.height//2),eag)

d=ImageDraw.Draw(img)
# corner brackets
for (x,y,dx,dy) in [(70,70,1,1),(W-70,70,-1,1),(70,H-70,1,-1),(W-70,H-70,-1,-1)]:
    d.line([(x,y),(x+dx*70,y)],fill=RED,width=5); d.line([(x,y),(x,y+dy*70)],fill=RED,width=5)

f=it7(30); t="FULL SERMON"
tracked(d,((W-twidth(d,t,f,0.34))/2,1010),t,f,RED,0.34)

fa=anton(96)
for i,line in enumerate(["ENTER INTO","THE KINGDOM"]):
    w=d.textlength(line,font=fa)
    d.text(((W-w)/2,1075+i*104),line,font=fa,fill=BONE if i==0 else RED)

f=it6(34); t="Rev Ifeayinchukwu Obi"
d.text(((W-d.textlength(t,font=f))/2,1310),t,font=f,fill=BONE)

f=it6(30); t="Sunday 9 August 2026"
d.text(((W-d.textlength(t,font=f))/2,1362),t,font=f,fill=GREY)

d.line([(340,1450),(740,1450)],fill=(60,56,54),width=2)

f=it7(38); t="SEARCH YOUTUBE"
tracked(d,((W-twidth(d,t,f,0.22))/2,1500),t,f,GREY,0.22)
fa2=anton(72); t="CALVARY HEPHZIBAH"
d.text(((W-d.textlength(t,font=fa2))/2,1560),t,font=fa2,fill=BONE)

f=it6(28); t="Sundays 11am  ·  West Indian Centre, Manchester"
d.text(((W-d.textlength(t,font=f))/2,1700),t,font=f,fill=GREY)

img.save(sys.argv[1] if len(sys.argv)>1 else "/home/claude/endcard.jpg",quality=94)
print("saved")
