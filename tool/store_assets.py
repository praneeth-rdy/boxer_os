"""Builds the Play Store listing assets from raw 1080x2400 device captures.

Usage: python3 tool/store_assets.py <folder with home.png, session.png, train.png, combos.png,
reaction.png, progress.png, journal.png, reminders.png>

Output goes to screenshots/ (gitignored): framed 1080x1920 phone screenshots with a headline
each, a hero frame, the 1024x500 feature graphic and the 512 px icon. Needs Pillow.
"""
import sys, os, math
from PIL import Image, ImageDraw, ImageFont, ImageFilter
ROOT=os.path.dirname(os.path.dirname(os.path.abspath(__file__)))+'/'
OUT=ROOT+'screenshots/'
BEBAS=ROOT+'assets/fonts/BebasNeue-Regular.ttf'; INTER=ROOT+'assets/fonts/Inter-Medium.ttf'; INTERB=ROOT+'assets/fonts/Inter-SemiBold.ttf'
INK=(10,10,11); SURF=(20,20,22); CHALK=(244,242,238); MUTED=(154,154,159); ACCENT=(255,61,46); LINE=(42,42,46); DEEP=(184,38,28)
W,H=1080,1920

def background(w,h,glow_at=(0.8,0.85),glow_r=620,glow_alpha=90,ropes=True):
    bg=Image.new('RGB',(w,h),INK)
    # red glow
    glow=Image.new('RGBA',(w,h),(0,0,0,0)); g=ImageDraw.Draw(glow)
    cx,cy=int(w*glow_at[0]),int(h*glow_at[1])
    g.ellipse([cx-glow_r,cy-glow_r,cx+glow_r,cy+glow_r],fill=ACCENT+(glow_alpha,))
    glow=glow.filter(ImageFilter.GaussianBlur(260))
    bg=Image.alpha_composite(bg.convert('RGBA'),glow)
    if ropes:
        # three faint rope lines and a corner post, the brand mark at wall scale
        r=ImageDraw.Draw(bg)
        for i,y in enumerate((int(h*0.62),int(h*0.70),int(h*0.78))):
            r.rounded_rectangle([-40,y,w+40,y+10],radius=5,fill=(30,30,34,255))
        r.rounded_rectangle([64,int(h*0.56),84,int(h*0.84)],radius=6,fill=DEEP+(255,))
    return bg.convert('RGB')

def phone(shot, width=760, tilt=0.0):
    """Framed phone: bezel, rounded screen, punch-hole, subtle edge light, optional tilt (degrees)."""
    sw=width; sh=int(shot.height*sw/shot.width)
    s=shot.resize((sw,sh),Image.LANCZOS)
    bez=22; pw,ph=sw+2*bez,sh+2*bez
    layer=Image.new('RGBA',(pw+80,ph+80),(0,0,0,0))
    d=ImageDraw.Draw(layer)
    ox=oy=40
    d.rounded_rectangle([ox,oy,ox+pw,oy+ph],radius=92,fill=(18,18,20,255),outline=(58,58,64,255),width=3)
    d.rounded_rectangle([ox+3,oy+3,ox+pw-3,oy+ph-3],radius=89,outline=(8,8,9,255),width=4)
    mask=Image.new('L',(sw,sh),0); ImageDraw.Draw(mask).rounded_rectangle([0,0,sw-1,sh-1],radius=70,fill=255)
    layer.paste(s,(ox+bez,oy+bez),mask)
    d.ellipse([ox+pw//2-14,oy+bez+18,ox+pw//2+14,oy+bez+46],fill=(6,6,7,255))   # punch-hole
    d.rounded_rectangle([ox+pw+2,oy+260,ox+pw+8,oy+400],radius=3,fill=(70,70,76,255)) # power key
    if tilt: layer=layer.rotate(tilt,resample=Image.BICUBIC,expand=True)
    # drop shadow
    sh_layer=Image.new('RGBA',layer.size,(0,0,0,0)); alpha=layer.split()[3]
    shadow=Image.new('RGBA',layer.size,(0,0,0,0)); shadow.paste((0,0,0,170),(0,0),alpha)
    shadow=shadow.filter(ImageFilter.GaussianBlur(40))
    return layer, shadow

def clean(src):
    im=Image.open(src).convert('RGB')
    if im.size!=(1080,2400): im=im.resize((1080,2400))
    return im.crop((0,84,1080,2400-60))

def headline(d,text,accent_word,y,size=132,x=80,maxw=W-160):
    f=ImageFont.truetype(BEBAS,size)
    words=text.upper().split(); lines=[]; cur=[]
    for w in words:
        t=' '.join(cur+[w])
        if d.textlength(t,font=f)>maxw and cur: lines.append(cur); cur=[w]
        else: cur.append(w)
    lines.append(cur)
    for ln in lines:
        cx=x
        for w in ln:
            col=ACCENT if w.strip('.,')==accent_word.upper() else CHALK
            d.text((cx,y),w,font=f,fill=col); cx+=d.textlength(w+' ',font=f)
        y+=int(size*0.92)
    return y

def chips(d,y,items,x=80):
    f=ImageFont.truetype(INTERB,26)
    for it in items:
        tw=d.textlength(it,font=f)
        d.rounded_rectangle([x,y,x+tw+40,y+52],radius=26,outline=LINE,width=2,fill=SURF)
        d.text((x+20,y+11),it,font=f,fill=MUTED); x+=tw+56
    return y+52

def frame(src,title,accent_word,sub,out,tilt=-6,chip_items=None,glow_at=(0.82,0.86)):
    bg=background(W,H,glow_at=glow_at)
    d=ImageDraw.Draw(bg)
    y=headline(d,title,accent_word,110)
    f2=ImageFont.truetype(INTER,36)
    words=sub.split(); lines=[]; cur=''
    for w in words:
        t=(cur+' '+w).strip()
        if d.textlength(t,font=f2)>W-200 and cur: lines.append(cur); cur=w
        else: cur=t
    lines.append(cur); y+=6
    for l in lines: d.text((80,y),l,font=f2,fill=MUTED); y+=48
    if chip_items: y=chips(d,y+18,chip_items)
    layer,shadow=phone(clean(src),width=780,tilt=tilt)
    top=max(y+40,600); x=(W-layer.width)//2+ (40 if tilt else 0)
    bg=bg.convert('RGBA'); bg.alpha_composite(shadow,(x+10,top+30)); bg.alpha_composite(layer,(x,top))
    bg.convert('RGB').save(out,optimize=True); print('wrote',os.path.basename(out))

def hero(src_a,src_b,out):
    bg=background(W,H,glow_at=(0.5,0.62),glow_r=700,glow_alpha=130)
    d=ImageDraw.Draw(bg)
    f=ImageFont.truetype(BEBAS,96); d.text((80,96),'TRAIN. FIGHT.',font=f,fill=CHALK); d.text((80,186),'IMPROVE. REPEAT.',font=f,fill=ACCENT)
    f2=ImageFont.truetype(INTER,36)
    for i,l in enumerate(['The boxing companion that works before,','during and after every session.','No account. Nothing leaves your phone.']): d.text((80,300+i*48),l,font=f2,fill=MUTED)
    chips(d,470,['Local-first','Bells and haptics','Spoken cues'])
    a,sa=phone(clean(src_a),width=600,tilt=-7); b,sb=phone(clean(src_b),width=560,tilt=7)
    bg=bg.convert('RGBA')
    bg.alpha_composite(sa,(20,640)); bg.alpha_composite(a,(10,610))
    bg.alpha_composite(sb,(540,840)); bg.alpha_composite(b,(530,810))
    bg.convert('RGB').save(out,optimize=True); print('wrote',os.path.basename(out))

def feature():
    bg=background(1024,500,glow_at=(0.88,0.5),glow_r=360,glow_alpha=120,ropes=False)
    d=ImageDraw.Draw(bg)
    icon=Image.open(ROOT+'assets/icon/ic_launcher_1024.png').convert('RGB').resize((300,300),Image.LANCZOS)
    mask=Image.new('L',(300,300),0); ImageDraw.Draw(mask).rounded_rectangle([0,0,299,299],radius=68,fill=255)
    bg.paste(icon,(70,100),mask)
    f=ImageFont.truetype(BEBAS,150); d.text((420,112),'BOXER',font=f,fill=CHALK); d.text((800,112),'OS',font=f,fill=ACCENT)
    f2=ImageFont.truetype(INTER,30); d.text((426,286),'TRAIN. FIGHT. IMPROVE. REPEAT.',font=f2,fill=MUTED)
    f3=ImageFont.truetype(INTER,24); d.text((426,340),'Timer, workouts, combos, reaction, journal.',font=f3,fill=(120,120,126))
    bg.save(OUT+'feature_graphic_1024x500.png'); print('wrote feature graphic')

PLAN=[('home','Your corner, in your pocket','corner','Today\'s session, your streak, and a word from the greats.',['Streak','Quote of the day','Did you know']),
      ('session','Bells. Buzzes. Spoken cues.','spoken','Phone down. The clock reads from across the gym.',['Round timer','10 s warning','Voice']),
      ('combos','Sixty combinations, real boxing','real','Filter by level and style, bookmark, drill them with spoken cues.',['Grammar-checked','Bookmarks','Practice']),
      ('reaction','Train your reactions','reactions','Eight drills, boxing and pure speed. Sixty seconds of endurance.',['Best and average','Accuracy']),
      ('corner','The corner is open','open','Legends, the boxing calendar and words to train by.',['Twelve legends','39 dates','81 quotes']),
      ('story','Learn from the legends','legends','What they went through, and what it teaches.',['Stories','Takeaways']),
      ('progress','See the work add up','work','Rounds, minutes, streak, milestones. All on your phone, nowhere else.',['7-day chart','Badges'])]
# Play accepts at most eight phone screenshots: the hero plus these seven.

if __name__=='__main__':
    src=sys.argv[1]; os.makedirs(OUT,exist_ok=True)
    have={k:os.path.join(src,k+'.png') for k,*_ in PLAN if os.path.exists(os.path.join(src,k+'.png'))}
    n=1
    if 'home' in have and 'session' in have: hero(have['home'],have['session'],OUT+'01_hero_1080x1920.png'); n=2
    for key,t,aw,s,ch in PLAN:
        if key not in have: print('skip',key); continue
        frame(have[key],t,aw,s,OUT+f'{n:02d}_{key}_1080x1920.png',tilt=(-6 if n%2 else 6),chip_items=ch,glow_at=((0.82,0.86) if n%2 else (0.2,0.88))); n+=1
    feature()
    Image.open(ROOT+'assets/icon/play_store_512.png').convert('RGB').save(OUT+'icon_512.png')
