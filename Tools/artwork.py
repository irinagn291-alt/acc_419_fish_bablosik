from pathlib import Path
import json,math
from PIL import Image,ImageDraw
root=Path(__file__).resolve().parents[1]
a=root/'Resources'/'HarborArt.xcassets';a.mkdir(exist_ok=True)
(a/'Contents.json').write_text(json.dumps({'info':{'author':'xcode','version':1}}))
accent=a/'ReedAccent.colorset';accent.mkdir(exist_ok=True)
(accent/'Contents.json').write_text('{"colors": [{"color": {"color-space": "srgb", "components": {"red": "0.055", "green": "0.353", "blue": "0.655", "alpha": "1.000"}}, "idiom": "universal"}, {"appearances": [{"appearance": "luminosity", "value": "dark"}], "color": {"color-space": "srgb", "components": {"red": "0.384", "green": "0.675", "blue": "0.957", "alpha": "1.000"}}, "idiom": "universal"}], "info": {"author": "xcode", "version": 1}}')
features=json.loads((root/'Resources/earth-source.geojson').read_text())['features']
for z in range(5):
 n=256*2**z
 im=Image.new('RGB',(n,n),'#0E5AA7');d=ImageDraw.Draw(im)
 def xy(p):
  x,y=p;lat=max(-85.051,min(85.051,y))*math.pi/180
  return ((x+180)/360*n,(1-math.log(math.tan(lat)+1/math.cos(lat))/math.pi)/2*n)
 for f in features:
  geom=f['geometry'];polys=geom['coordinates'] if geom['type']=='MultiPolygon' else [geom['coordinates']]
  for rings in polys:
   for i,ring in enumerate(rings):
    pts=[xy(p) for p in ring]
    d.polygon(pts,fill='#F4E4C1' if i==0 else '#0E5AA7',outline='#c5bd9e')
 for x in range(2**z):
  p=root/f'Resources/OfflineTiles/{z}/{x}';p.mkdir(parents=True,exist_ok=True)
  for y in range(2**z):im.crop((x*256,y*256,(x+1)*256,(y+1)*256)).save(p/f'{y}.png',optimize=True)
 if z==3:
  p=a/'atlas.imageset';p.mkdir(exist_ok=True);im.save(p/'atlas.png');(p/'Contents.json').write_text(json.dumps({'images':[{'filename':'atlas.png','idiom':'universal'}],'info':{'author':'xcode','version':1}}))
im=Image.new('RGB',(1024,1024),'#062F55');d=ImageDraw.Draw(im)
for y in range(1024):
 k=y/1024;d.line((0,y,1024,y),fill=(int(6+8*(1-k)),int(47+43*(1-k)),int(85+82*(1-k))))
# utility journal, fish print, bookmark and geographic pin
for x in (80,900): d.arc((x-300,550,x+400,1150),180,345,fill='#2174AC',width=9)
d.rounded_rectangle((233,178,794,846),radius=65,fill='#041f3b')
d.rounded_rectangle((205,158,766,822),radius=58,fill='#F4E4C1')
d.rounded_rectangle((205,158,273,822),radius=24,fill='#edcea1')
d.line((294,180,294,796),fill='#d7bc95',width=8)
for y in (270,380,490,600,710):d.rounded_rectangle((175,y,244,y+20),radius=8,fill='#062F55')
d.polygon([(643,159),(703,159),(703,302),(673,272),(643,302)],fill='#F97316')
d.ellipse((348,365,635,545),fill='#0E5AA7')
d.polygon([(615,449),(703,365),(703,544)],fill='#0E5AA7')
d.polygon([(445,381),(501,320),(556,387)],fill='#0E5AA7')
d.ellipse((389,416,410,437),fill='#F4E4C1')
d.arc((417,382,497,534),280,80,fill='#F4E4C1',width=7)
d.line((354,611,615,611),fill='#c4aa82',width=8);d.line((354,655,559,655),fill='#c4aa82',width=8)
d.ellipse((455,700,513,760),fill='#F97316')
d.ellipse((479,712,489,722),fill='#062F55')
d.line((484,758,484,788),fill='#062F55',width=8)
d.arc((484,770,526,812),0,180,fill='#062F55',width=8)
d.polygon([(524,791),(510,788),(520,778)],fill='#062F55')
d.ellipse((665,620,849,804),fill='#F97316');d.polygon([(680,749),(757,869),(835,749)],fill='#F97316');d.ellipse((715,670,799,754),fill='#062F55')
p=a/'LedgerMark.appiconset';p.mkdir(exist_ok=True);im.save(p/'LedgerMark.png');(p/'Contents.json').write_text(json.dumps({'images':[{'filename':'LedgerMark.png','idiom':'universal','platform':'ios','size':'1024x1024'}],'info':{'author':'xcode','version':1}}))
print('341 offline tiles and icon generated')
