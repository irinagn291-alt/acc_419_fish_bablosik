from pathlib import Path
import plistlib,json,uuid,re
root=Path(__file__).resolve().parents[1]
words={}
for line in (root/'Tools/words.tsv').read_text().splitlines():
 if not line:continue
 parts=[x.replace('\\n','\n') for x in line.split('|')];assert len(parts)==4,line
 words[parts[0]]=dict(zip(['en','de','fr','es'],parts))
strings={k:{'localizations':{lang:{'stringUnit':{'state':'translated','value':value}} for lang,value in values.items()}} for k,values in words.items()}
(root/'Resources/Localizable.xcstrings').write_text(json.dumps({'sourceLanguage':'en','strings':strings,'version':'1.0'},ensure_ascii=False,indent=2))
privacy={
'NSLocationWhenInUseUsageDescription':['Save the fishing point and fetch weather for that point when you choose.','Speichere deinen Angelplatz und rufe auf Wunsch das Wetter dort ab.','Enregistrez le lieu de pêche et récupérez sa météo si vous le souhaitez.','Guarda el punto de pesca y consulta su tiempo cuando lo elijas.'],
'NSCameraUsageDescription':['Photograph your catch to keep the image with a journal entry.','Fotografiere deinen Fang, um das Bild im Tagebuch zu behalten.','Photographiez votre prise pour la conserver dans le carnet.','Fotografía tu captura para guardarla en una entrada.'],
'NSPhotoLibraryUsageDescription':['Pick a catch photo to attach to your private fishing journal.','Wähle ein Fangfoto für dein privates Angeltagebuch.','Choisissez une photo de prise pour votre carnet privé.','Elige una foto de captura para tu diario privado.'],
'NSPhotoLibraryAddUsageDescription':['Keep a designed catch card in Photos when you tap Save card.','Speichere eine gestaltete Fangkarte in Fotos, wenn du dies auswählst.','Conservez une fiche de prise dans Photos à votre demande.','Guarda una ficha de captura en Fotos cuando lo solicites.']}
ps={k:{'localizations':{lang:{'stringUnit':{'state':'translated','value':v}} for lang,v in zip(['en','de','fr','es'],values)}} for k,values in privacy.items()}
(root/'Resources/InfoPlist.xcstrings').write_text(json.dumps({'sourceLanguage':'en','strings':ps,'version':'1.0'},ensure_ascii=False,indent=2))
def plist(path,data):
 with (root/path).open('wb') as f:plistlib.dump(data,f,sort_keys=False)
base={'CFBundleDevelopmentRegion':'en','CFBundleExecutable':'$(EXECUTABLE_NAME)','CFBundleIdentifier':'$(PRODUCT_BUNDLE_IDENTIFIER)','CFBundleInfoDictionaryVersion':'6.0','CFBundleName':'$(PRODUCT_NAME)','CFBundleShortVersionString':'$(MARKETING_VERSION)','CFBundleVersion':'$(CURRENT_PROJECT_VERSION)'}
app=dict(base);app.update({'CFBundleDisplayName':'FIsh Bablosik','CFBundlePackageType':'APPL','UILaunchScreen':{},'LSRequiresIPhoneOS':True,'ReedCloudSigning':'$(CODE_SIGNING_ALLOWED)','UIApplicationSupportsIndirectInputEvents':True,'UIApplicationSceneManifest':{'UIApplicationSupportsMultipleScenes':False,'UISceneConfigurations':{}},'UISupportedInterfaceOrientations':['UIInterfaceOrientationPortrait','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'],'UISupportedInterfaceOrientations~ipad':['UIInterfaceOrientationPortrait','UIInterfaceOrientationPortraitUpsideDown','UIInterfaceOrientationLandscapeLeft','UIInterfaceOrientationLandscapeRight'],'UIBackgroundModes':['fetch','remote-notification'],'BGTaskSchedulerPermittedIdentifiers':['com.anglerlog.app.refresh'],'CFBundleURLTypes':[{'CFBundleURLSchemes':['anglerlog']}],**{k:v[0] for k,v in privacy.items()}})
plist('AnglerLog/Info.plist',app)
plist('ReefWidget/Info.plist',{**base,'CFBundleDisplayName':'FIsh Bablosik','CFBundlePackageType':'XPC!','NSExtension':{'NSExtensionPointIdentifier':'com.apple.widgetkit-extension'}})
plist('AnglerLog/ReedLedger.entitlements',{'com.apple.security.application-groups':['group.com.anglerlog.app'],'com.apple.developer.icloud-container-identifiers':['iCloud.com.anglerlog.app'],'com.apple.developer.icloud-services':['CloudKit'],'aps-environment':'development'})
plist('ReefWidget/ReedGlance.entitlements',{'com.apple.security.application-groups':['group.com.anglerlog.app']})
plist('Resources/PrivacyInfo.xcprivacy',{'NSPrivacyTracking':False,'NSPrivacyCollectedDataTypes':[],'NSPrivacyAccessedAPITypes':[{'NSPrivacyAccessedAPIType':'NSPrivacyAccessedAPICategoryUserDefaults','NSPrivacyAccessedAPITypeReasons':['CA92.1','1C8F.1']}]})
# Unique object graph with no external build-time generator or absolute source references.
objects={}
def obj(isa,**values):
 key=uuid.uuid4().hex.upper()[:24];objects[key]={'isa':isa,**values};return key
refs={}
def ref(path,kind='sourcecode.swift',tree='SOURCE_ROOT'):
 if path not in refs:refs[path]=obj('PBXFileReference',lastKnownFileType=kind,path=path,sourceTree=tree)
 return refs[path]
def buildfile(r,**kw):return obj('PBXBuildFile',fileRef=r,**kw)
def phase(isa,files,**kw):return obj(isa,buildActionMask=2147483647,files=files,runOnlyForDeploymentPostprocessing=0,**kw)
def configs(settings):
 ids=[]
 for name in ['Debug','Release']:
  extra={'ONLY_ACTIVE_ARCH':'YES','SWIFT_OPTIMIZATION_LEVEL':'-Onone','SWIFT_ACTIVE_COMPILATION_CONDITIONS':'$(inherited) DEBUG','DEBUG_INFORMATION_FORMAT':'dwarf'} if name=='Debug' else {'SWIFT_COMPILATION_MODE':'wholemodule','SWIFT_OPTIMIZATION_LEVEL':'-O','DEBUG_INFORMATION_FORMAT':'dwarf-with-dsym'}
  ids.append(obj('XCBuildConfiguration',buildSettings={**settings,**extra},name=name))
 return obj('XCConfigurationList',buildConfigurations=ids,defaultConfigurationIsVisible=0,defaultConfigurationName='Release')
project_id=obj('PBXProject')
appProduct=obj('PBXFileReference',explicitFileType='wrapper.application',path='ReedLedger.app',sourceTree='BUILT_PRODUCTS_DIR')
widgetProduct=obj('PBXFileReference',explicitFileType='wrapper.app-extension',path='ReedGlance.appex',sourceTree='BUILT_PRODUCTS_DIR')
testProduct=obj('PBXFileReference',explicitFileType='wrapper.cfbundle',path='CreelChecks.xctest',sourceTree='BUILT_PRODUCTS_DIR')
shared=ref('AnglerLog/TideBits.swift');widget=ref('ReefWidget/WaterGlance.swift')
app_sources=[shared,ref('AnglerLog/ReedVault.swift'),ref('AnglerLog/HarborPages.swift'),ref('AnglerLog/CreelDesk.swift'),widget]
resources=[ref('Resources/HarborArt.xcassets','folder.assetcatalog'),ref('Resources/Localizable.xcstrings','text.json.xcstrings'),ref('Resources/InfoPlist.xcstrings','text.json.xcstrings'),ref('Resources/PrivacyInfo.xcprivacy','text.xml'),ref('Resources/OfflineTiles','folder')]
common={'SWIFT_VERSION':'5.0','IPHONEOS_DEPLOYMENT_TARGET':'17.5','SDKROOT':'iphoneos','SUPPORTED_PLATFORMS':'iphoneos iphonesimulator','TARGETED_DEVICE_FAMILY':'1,2','SUPPORTS_MACCATALYST':'NO','SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD':'NO','CODE_SIGN_STYLE':'Automatic','MARKETING_VERSION':'1.2.2','CURRENT_PROJECT_VERSION':'22','ENABLE_USER_SCRIPT_SANDBOXING':'YES','SWIFT_SERIALIZE_DEBUGGING_OPTIONS':'NO','OTHER_SWIFT_FLAGS':'$(inherited) -debug-prefix-map $(SRCROOT)=. -Xfrontend -no-clang-module-breadcrumbs','SWIFT_EMIT_LOC_STRINGS':'NO'}
widget_settings={**common,'PRODUCT_NAME':'ReedGlance','PRODUCT_BUNDLE_IDENTIFIER':'com.anglerlog.app.glance','INFOPLIST_FILE':'ReefWidget/Info.plist','CODE_SIGN_ENTITLEMENTS':'ReefWidget/ReedGlance.entitlements','SKIP_INSTALL':'YES','APPLICATION_EXTENSION_API_ONLY':'YES','LD_RUNPATH_SEARCH_PATHS':'$(inherited) @executable_path/Frameworks @executable_path/../../Frameworks','OTHER_SWIFT_FLAGS':'$(inherited) -D WIDGET_EXTENSION -debug-prefix-map $(SRCROOT)=. -Xfrontend -no-clang-module-breadcrumbs'}
widgetTarget=obj('PBXNativeTarget',name='ReedGlance',productName='ReedGlance',productReference=widgetProduct,productType='com.apple.product-type.app-extension',buildConfigurationList=configs(widget_settings),buildPhases=[phase('PBXSourcesBuildPhase',[buildfile(shared),buildfile(widget)]),phase('PBXFrameworksBuildPhase',[]),phase('PBXResourcesBuildPhase',[buildfile(r) for r in resources[:2]+[resources[3]]])],dependencies=[],buildRules=[])
proxy=obj('PBXContainerItemProxy',containerPortal=project_id,proxyType=1,remoteGlobalIDString=widgetTarget,remoteInfo='ReedGlance')
dep=obj('PBXTargetDependency',target=widgetTarget,targetProxy=proxy)
app_settings={**common,'PRODUCT_NAME':'ReedLedger','PRODUCT_BUNDLE_IDENTIFIER':'com.anglerlog.app','INFOPLIST_FILE':'AnglerLog/Info.plist','CODE_SIGN_ENTITLEMENTS':'AnglerLog/ReedLedger.entitlements','ASSETCATALOG_COMPILER_APPICON_NAME':'LedgerMark','LD_RUNPATH_SEARCH_PATHS':'$(inherited) @executable_path/Frameworks','ENABLE_PREVIEWS':'YES'}
appTarget=obj('PBXNativeTarget',name='ReedLedger',productName='ReedLedger',productReference=appProduct,productType='com.apple.product-type.application',buildConfigurationList=configs(app_settings),buildPhases=[phase('PBXSourcesBuildPhase',[buildfile(r) for r in app_sources]),phase('PBXFrameworksBuildPhase',[]),phase('PBXResourcesBuildPhase',[buildfile(r) for r in resources]),phase('PBXCopyFilesBuildPhase',[buildfile(widgetProduct,settings={'ATTRIBUTES':['RemoveHeadersOnCopy']})],dstPath='',dstSubfolderSpec=13,name='Embed Glance')],dependencies=[dep],buildRules=[])
proxy=obj('PBXContainerItemProxy',containerPortal=project_id,proxyType=1,remoteGlobalIDString=appTarget,remoteInfo='ReedLedger')
dep=obj('PBXTargetDependency',target=appTarget,targetProxy=proxy)
testsettings={**common,'PRODUCT_NAME':'CreelChecks','PRODUCT_BUNDLE_IDENTIFIER':'com.anglerlog.app.checks','GENERATE_INFOPLIST_FILE':'YES','TEST_TARGET_NAME':'ReedLedger','LD_RUNPATH_SEARCH_PATHS':'$(inherited) @executable_path/Frameworks @loader_path/Frameworks'}
testTarget=obj('PBXNativeTarget',name='CreelChecks',productName='CreelChecks',productReference=testProduct,productType='com.apple.product-type.bundle.ui-testing',buildConfigurationList=configs(testsettings),buildPhases=[phase('PBXSourcesBuildPhase',[buildfile(ref('QA/CreelChecks.swift')),buildfile(shared),buildfile(ref('AnglerLog/ReedVault.swift'))]),phase('PBXFrameworksBuildPhase',[])],dependencies=[dep],buildRules=[])
products=obj('PBXGroup',children=[appProduct,widgetProduct,testProduct],name='Products',sourceTree='<group>')
main=obj('PBXGroup',children=list(refs.values())+[products],sourceTree='<group>')
objects[project_id].update({'attributes':{'LastUpgradeCheck':'2700','ORGANIZATIONNAME':'Reedfolio Fieldworks','TargetAttributes':{appTarget:{'SystemCapabilities':{'com.apple.ApplicationGroups.iOS':{'enabled':1},'com.apple.iCloud':{'enabled':1},'com.apple.Push':{'enabled':1},'com.apple.BackgroundModes':{'enabled':1}}}}},'buildConfigurationList':configs({'CLANG_ENABLE_MODULES':'YES','CLANG_ENABLE_OBJC_ARC':'YES','GCC_C_LANGUAGE_STANDARD':'gnu17','ENABLE_STRICT_OBJC_MSGSEND':'YES','SWIFT_STRICT_CONCURRENCY':'minimal'}),'compatibilityVersion':'Xcode 14.0','developmentRegion':'en','knownRegions':['en','de','fr','es'],'mainGroup':main,'productRefGroup':products,'projectDirPath':'','projectRoot':'','targets':[appTarget,widgetTarget,testTarget]})
def encode(v):
 if isinstance(v,dict):return '{ '+ ' '.join(encode(k)+' = '+encode(x)+';' for k,x in v.items())+' }'
 if isinstance(v,list):return '( '+', '.join(encode(x) for x in v)+', )' if v else '()'
 if isinstance(v,int):return str(v)
 return json.dumps(v,ensure_ascii=False)
project=root/'AnglerLog.xcodeproj';project.mkdir(exist_ok=True)
(project/'project.pbxproj').write_text('// !$*UTF8*$!\n'+encode({'archiveVersion':1,'classes':{},'objectVersion':56,'objects':objects,'rootObject':project_id})+'\n')
scheme=f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2700" version="1.7"><BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{appTarget}" BuildableName="ReedLedger.app" BlueprintName="ReedLedger" ReferencedContainer="container:AnglerLog.xcodeproj"/></BuildActionEntry></BuildActionEntries></BuildAction><TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES"><Testables><TestableReference skipped="NO"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{testTarget}" BuildableName="CreelChecks.xctest" BlueprintName="CreelChecks" ReferencedContainer="container:AnglerLog.xcodeproj"/></TestableReference></Testables></TestAction><LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.IDEFoundation.Launcher.LLDB" launchStyle="0"><BuildableProductRunnable runnableDebuggingMode="0"><BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{appTarget}" BuildableName="ReedLedger.app" BlueprintName="ReedLedger" ReferencedContainer="container:AnglerLog.xcodeproj"/></BuildableProductRunnable></LaunchAction><ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES"/><AnalyzeAction buildConfiguration="Debug"/><ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/></Scheme>'''
schemedir=project/'xcshareddata/xcschemes';schemedir.mkdir(parents=True,exist_ok=True);(schemedir/'ReedLedger.xcscheme').write_text(scheme)
print(f'Generated {len(objects)} unique project objects; {len(words)} strings x 4 locales')
