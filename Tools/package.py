from pathlib import Path
import zipfile,json,hashlib
root=Path(__file__).resolve().parents[1]
archive=root/'Artifacts/AnglerLog.xcarchive'
# Keep DWARF offsets stable when neutralising a toolchain-generated module-cache
# path that Swift's debug-prefix-map does not cover. Executables are not modified.
needle=str(root).encode();neutral=b'/build/angler-log'
neutral+=b'/'*(len(needle)-len(neutral))
for p in (archive/'dSYMs').rglob('*'):
 if not p.is_file():continue
 data=p.read_bytes()
 if needle in data:p.write_bytes(data.replace(needle,neutral))
assert not [p for p in archive.rglob('*') if p.is_file() and b'/Users/' in p.read_bytes()]
files=[]
for folder in ['AnglerLog','ReefWidget','Resources','Tools','StoreMetadata','AnglerLog.xcodeproj']:
 files.extend(p for p in (root/folder).rglob('*') if p.is_file() and not any(x in p.parts for x in ['xcuserdata','.DS_Store','__pycache__']))
files.extend([root/'QA/CreelChecks.swift',root/'QA/run-device.sh',root/'QA/source-verification.md'])
for name in ['README.md','REPORT.md']:
 if (root/name).exists():files.append(root/name)
with zipfile.ZipFile(root/'Artifacts/AnglerLog-source.zip','w',zipfile.ZIP_DEFLATED) as z:
 for p in files:z.write(p,p.relative_to(root))
manifest={str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
(root/'Artifacts/source-sha256.json').write_text(json.dumps(manifest,indent=2))
print('Source package created; archive personal-path scan passed.')
