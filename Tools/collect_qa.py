from pathlib import Path
import json,re,shutil
root=Path(__file__).resolve().parents[1]
index=['# Simulator evidence','','Screenshots show actual app UI. Entries marked QA were created by the test runner only.','']
for kind in ['iphone','ipad']:
 runs=root/f'QA/{kind}-verified'
 if not runs.exists():continue
 manifests=list(runs.glob('attachments*/manifest.json'))
 if not manifests:continue
 latest=max(manifests,key=lambda p:p.stat().st_mtime)
 destination=root/f'QA/Screenshots/{kind}';destination.mkdir(parents=True,exist_ok=True)
 index+=['## '+kind,'']
 for test in json.loads(latest.read_text()):
  for attachment in test.get('attachments',[]):
   source=latest.parent/attachment['exportedFileName']
   if source.suffix.lower()!='.png':continue
   name=attachment['suggestedHumanReadableName']
   safe=re.sub('[^A-Za-z0-9_.-]+','-',name)[:180]
   if not safe.endswith('.png'):safe+='.png'
   output=destination/safe;shutil.copy2(source,output)
   index.append(f'- [{name}](Screenshots/{kind}/{safe})')
 index.append('')
(root/'QA/screenshots-index.md').write_text('\n'.join(index))
print('Updated screenshot index')
