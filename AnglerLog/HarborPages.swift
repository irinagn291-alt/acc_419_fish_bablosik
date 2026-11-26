import SwiftUI
import UniformTypeIdentifiers
import WidgetKit

@main struct rA:App {
 @UIApplicationDelegateAdaptor(rD.self) var life
 @StateObject var v=rV()
 @Environment(\.scenePhase) var phase
 var body:some Scene {WindowGroup{Group {
#if targetEnvironment(simulator)
    if let index = StoreCaptureRoute.index { StoreCaptureScene(index: index) }
    else { rLaunch() }
#else
    rLaunch()
#endif
}.environmentObject(v).tint(qAccent).onChange(of:phase){_,p in if p == .active {rD.plan();let stamp=v.pack.cache?.fetched ?? v.pack.cache?.at ?? .distantPast
 let changedPoint=v.point.map{v.pack.cache?.lat != $0.0 || v.pack.cache?.lon != $0.1} ?? false
 if UserDefaults.standard.bool(forKey:"onlineWeather") && (abs(stamp.timeIntervalSinceNow)>3600 || changedPoint){Task{await v.refresh()}}
 if UserDefaults.standard.bool(forKey:"cloudEnabled") {Task{await v.sync()}}}}}}
}
struct rHome:View {
 @EnvironmentObject var v:rV
 @State var tab=0;@State var add=false
 var body:some View {
 TabView(selection:$tab){
 rJournal(add:$add).tabItem{Label(qL("Journal"),systemImage:"book.closed")}.tag(0)
 rMapPage().tabItem{Label(qL("Map"),systemImage:"map")}.tag(1)
 rStats().tabItem{Label(qL("Activity"),systemImage:"chart.bar.xaxis")}.tag(2)
 rSettings().tabItem{Label(qL("Tools"),systemImage:"slider.horizontal.3")}.tag(3)
 }.sheet(isPresented:$add){rEdit(row:rE())}
 .alert(qL("FIsh Bablosik"),isPresented:Binding(get:{ !v.issue.isEmpty },set:{if !$0 {v.issue=""}})){Button(qL("OK")){v.issue=""}}message:{Text(v.issue)}
 .onOpenURL{u in if u.host == "add"{add=true}else if u.host == "map"{tab=1}else if u.host == "activity"{tab=2}}
 }
}
struct rJournal:View {
 @EnvironmentObject var v:rV
 @Environment(\.horizontalSizeClass) var size
 @Binding var add:Bool
 @State var search="";@State var selection:rE?
 var filtered:[rE]{v.rows.filter{search.isEmpty || "\($0.species) \($0.lure) \($0.place) \($0.note)".localizedCaseInsensitiveContains(search)}}
 var body:some View {
 NavigationStack {
 ScrollView {
 VStack(alignment:.leading,spacing:22){
 VStack(spacing: 0) {
  Color.clear.aspectRatio(1.92, contentMode:.fit)
   .background { Image("LakePlate").resizable().scaledToFill().accessibilityHidden(true) }
   .clipped().allowsHitTesting(false)
  VStack(alignment: .leading, spacing: 14) {
   HStack(alignment:.firstTextBaseline) {
    Text(qL("Journal")).font(.system(.largeTitle, design:.serif, weight:.black))
    Spacer()
    Button { add = true } label: {
     Label(qL("Log a catch"),systemImage:"plus").font(.subheadline.bold())
      .padding(.horizontal,12).frame(minHeight:44).background(qSand,in:RoundedRectangle(cornerRadius:5))
      .foregroundStyle(qDeep)
    }.accessibilityIdentifier("addCatch")
   }
   Divider().overlay(qSand.opacity(0.6))
   HStack(alignment:.top,spacing:16) {
    rMetric(n:"\(v.rows.count)",s:"Entries")
    rMetric(n:"\(rS(rows:v.rows).fish)",s:"Fish logged")
    rMetric(n:"\(rS(rows:v.rows).species.count)",s:"Species")
   }
  }.padding(18).foregroundStyle(.white).background(qDeep)
 }.clipShape(RoundedRectangle(cornerRadius:8))
 HStack {
  Text(qL("Field notes")).font(.system(.title2,design:.serif,weight:.bold))
  Rectangle().fill(qAccent.opacity(0.38)).frame(height:1)
  Text("\(filtered.count)").font(.caption.monospacedDigit())
 }
 if v.rows.isEmpty {
 HStack(alignment:.top,spacing:16) {
  Image(systemName:"book.pages").foregroundStyle(qAccent).font(.title)
  VStack(alignment:.leading,spacing:8) {
   Text(qL("A journal worth keeping")).font(.system(.headline,design:.serif,weight:.bold))
   Text(qL("Log your first catch. A place, a lure and a few details are all you need. Everything stays available offline.")).font(.subheadline).foregroundStyle(.secondary)
  }
 }.padding(.vertical,8)

 }else if filtered.isEmpty {ContentUnavailableView.search(text:search)}
 else if size == .regular {
 VStack(spacing:0){
 HStack{Text(qL("Date")).frame(width:120,alignment:.leading);Text(qL("Species")).frame(maxWidth:.infinity,alignment:.leading);Text(qL("Lure")).frame(maxWidth:.infinity,alignment:.leading);Text(qL("Place")).frame(maxWidth:.infinity,alignment:.leading);Text(qL("Fish")).frame(width:50)}.font(.caption.bold()).foregroundStyle(qDeep).padding(14).background(qSand)
 ForEach(filtered){r in Button{selection=r}label:{HStack{Text(r.at,format:.dateTime.day().month().year()).frame(width:120,alignment:.leading);Text(r.species).fontWeight(.semibold).frame(maxWidth:.infinity,alignment:.leading);Text(r.lure).frame(maxWidth:.infinity,alignment:.leading);Text(r.place.isEmpty ? r.coordinateLabel:r.place).frame(maxWidth:.infinity,alignment:.leading);Text("\(r.count)").frame(width:50)}.padding(14).foregroundStyle(.primary)}.accessibilityIdentifier("catch-\(r.species)");Divider()}
 }.background(Color(uiColor:.secondarySystemGroupedBackground),in:RoundedRectangle(cornerRadius:16))
 }else {
 LazyVStack(spacing:12){ForEach(filtered){r in Button{selection=r}label:{rRow(row:r)}.buttonStyle(.plain).accessibilityIdentifier("catch-\(r.species)")}}
 }
 }.padding(.horizontal,18).padding(.bottom,30).frame(maxWidth:1100).frame(maxWidth:.infinity)
 }.background(Color(uiColor:.systemGroupedBackground))
 .navigationTitle("FIsh Bablosik").navigationBarTitleDisplayMode(.inline)
 .toolbar{ToolbarItem(placement:.topBarTrailing){Button{add=true}label:{Image(systemName:"plus.circle.fill")}.accessibilityLabel(qL("Log a catch"))}}
 .searchable(text:$search,prompt:qL("Search species, lure or place"))
 .sheet(item:$selection){rDetail(id:$0.id)}
 }
 }
}
struct rMetric:View {var n:String;var s:String;var body:some View{VStack(alignment:.leading,spacing:3){Text(n).font(.system(.title2,design:.serif,weight:.bold)).monospacedDigit();Text(qL(s)).font(.caption).foregroundStyle(qSand)}.frame(maxWidth:.infinity,alignment:.leading)}}
struct rRow:View {var row:rE;var body:some View{HStack(spacing:14){
 Group{if let d=row.photo,let im=UIImage(data:d){Image(uiImage:im).resizable().scaledToFill()}else{ZStack{qBlue.opacity(0.1);Image(systemName:"fish").font(.title).foregroundStyle(qAccent)}}}.frame(width:66,height:76).clipped().clipShape(RoundedRectangle(cornerRadius:14))
 VStack(alignment:.leading,spacing:6){Text(row.species).font(.headline);Text(row.lure).font(.subheadline).foregroundStyle(.secondary);Text(row.at,format:.dateTime.day().month().year()).font(.caption).foregroundStyle(.secondary)}
 Spacer();VStack(alignment:.trailing,spacing:6){Text("\(row.count)").font(.title2.bold()).foregroundStyle(qAccent);Text(qL("Fish")).font(.caption).foregroundStyle(.secondary)};Image(systemName:"chevron.right").font(.caption).foregroundStyle(.tertiary)
 }.padding(14).background(Color(uiColor:.secondarySystemGroupedBackground),in:RoundedRectangle(cornerRadius:20))}}
struct rMapPage:View {
 @EnvironmentObject var v:rV;@State var selected:UUID?
 var body:some View{NavigationStack{VStack(spacing:0){rOffline(rows:v.rows,selected:$selected).overlay(alignment:.bottomLeading){Text(qL("Offline atlas · Natural Earth")).font(.caption2).padding(8).background(.regularMaterial,in:Capsule()).padding(10)}
 VStack(alignment:.leading,spacing:8){Label(qL("Your places, always available"),systemImage:"map.fill").font(.headline);Text(qL("World atlas with saved coordinates. Coastlines and borders only; no detailed navigation charts.")).font(.footnote).foregroundStyle(.secondary);Text(String(format:qL("%d entries with a location"),v.rows.filter{$0.lat != nil}.count)).font(.caption).foregroundStyle(qAccent)}.padding().frame(maxWidth:.infinity,alignment:.leading).background(.regularMaterial)
 }.navigationTitle(qL("Catch map")).navigationBarTitleDisplayMode(.inline).sheet(item:Binding(get:{selected.flatMap{id in v.rows.first{$0.id==id}}},set:{selected=$0?.id})){rDetail(id:$0.id)}}}
}
struct rStats:View {
 @EnvironmentObject var v:rV
 @State var species="";@State var lure="";@State var sky="";@State var month=Calendar.current.dateInterval(of:.month,for:Date())!.start
 var data:rS{rS(rows:v.rows)}
 var filtered:[rE]{v.rows.filter{(species.isEmpty || $0.species==species) && (lure.isEmpty || $0.lure==lure) && (sky.isEmpty || $0.weather?.label==sky)}}
 var body:some View{NavigationStack{ScrollView{VStack(alignment:.leading,spacing:20){
 Text(qL("Patterns from your own water")).font(.system(.largeTitle,design:.serif,weight:.bold))
 HStack{rTile(value:"\(rS(rows:filtered).fish)",label:"Fish logged",icon:"fish");rTile(value:"\(filtered.count)",label:"Entries",icon:"book")}
 GroupBox{VStack(spacing:12){Picker(qL("Species"),selection:$species){Text(qL("All species")).tag("");ForEach(data.species,id:\.self){Text($0).tag($0)}};Picker(qL("Lure"),selection:$lure){Text(qL("All lures")).tag("");ForEach(data.lures.map(\.0),id:\.self){Text($0).tag($0)}};Picker(qL("Weather"),selection:$sky){Text(qL("All weather")).tag("");ForEach(Array(Set(v.rows.compactMap{$0.weather?.label})).sorted(),id:\.self){Text($0).tag($0)}}}.pickerStyle(.menu)}
 HStack{Button{shift(-1)}label:{Image(systemName:"chevron.left")}.accessibilityLabel(qL("Previous month"));Spacer();Text(month,format:.dateTime.month(.wide).year()).font(.headline);Spacer();Button{shift(1)}label:{Image(systemName:"chevron.right")}.accessibilityLabel(qL("Next month"))}
 calendar
 Text(qL("Lure performance")).font(.title2.bold())
 if filtered.isEmpty{Text(qL("Add entries to discover your patterns.")).foregroundStyle(.secondary)}
 ForEach(rS(rows:filtered).lures,id:\.0){name,n in VStack(alignment:.leading,spacing:6){HStack{Text(name).font(.headline);Spacer();Text("\(n) "+qL("Fish"))};GeometryReader{g in Capsule().fill(qBlue.opacity(0.1)).overlay(alignment:.leading){Capsule().fill(qBlue).frame(width:max(4,g.size.width*Double(n)/Double(max(1,rS(rows:filtered).fish))))}}.frame(height:8)}.padding(.vertical,4)}
 Text(qL("Counts describe your journal, not a prediction of future catches.")).font(.footnote).foregroundStyle(.secondary)
 }.padding(22)}.background(Color(uiColor:.systemGroupedBackground)).navigationTitle(qL("Activity")).navigationBarTitleDisplayMode(.inline)}}
 func shift(_ n:Int){month=Calendar.current.date(byAdding:.month,value:n,to:month)!}
 var calendar:some View{
 let c=Calendar.current;let range=c.range(of:.day,in:.month,for:month)!;let start=(c.component(.weekday,from:month)-c.firstWeekday+7)%7
 return VStack(alignment:.leading,spacing:12){Text(qL("Species calendar")).font(.title2.bold())
 LazyVGrid(columns:Array(repeating:GridItem(.flexible()),count:7),spacing:8){
 ForEach(0..<7,id:\.self){i in Text(c.veryShortStandaloneWeekdaySymbols[(i+c.firstWeekday-1)%7]).font(.caption).foregroundStyle(.secondary)}
 ForEach(0..<(start+range.count),id:\.self){i in if i<start{Color.clear.frame(height:48)}else{let d=c.date(byAdding:.day,value:i-start,to:month)!;let n=data.day(d,species:species,lure:lure,sky:sky)
 VStack(spacing:3){Text("\(i-start+1)").font(.subheadline);Text(n>0 ? "\(n)":"·").font(.caption2.bold())}.frame(maxWidth:.infinity,minHeight:48).foregroundStyle(n>0 ? .white:.secondary).background(n>0 ? qBlue:Color(uiColor:.secondarySystemGroupedBackground),in:RoundedRectangle(cornerRadius:10)).accessibilityLabel(d.formatted(date:.abbreviated,time:.omitted)+", \(n) "+qL("Fish"))}}
 }
 }
 }
}
struct rTile: View {
 var value: String; var label: String; var icon: String
 var body: some View {
  VStack(alignment:.leading, spacing:6) {
   Label(qL(label),systemImage:icon).font(.caption.bold()).foregroundStyle(qAccent)
   Text(value).font(.system(.title,design:.serif,weight:.bold)).fixedSize(horizontal:false,vertical:true)
  }.frame(maxWidth:.infinity,alignment:.leading).padding(14)
   .background(qAccent.opacity(0.08)).overlay(alignment:.top){Rectangle().fill(qAccent.opacity(0.55)).frame(height:1)}
 }
}
struct rSettings:View {
 @EnvironmentObject var v:rV
 @AppStorage("cloudEnabled") var cloud=false
 @AppStorage("onlineWeather") var online=false
 @AppStorage("daily") var daily=false;@AppStorage("weekend") var weekend=false;@AppStorage("hour") var hour=19
 @State var importer=false;@State var share:rShareItem?;@State var year=Calendar.current.component(.year,from:Date());@State var restoring=false
 var body:some View{NavigationStack{Form{
 Section(qL("Export & backup")){
 Button{export("csv")}label:{Label(qL("Export journal as CSV"),systemImage:"tablecells")}.disabled(v.rows.isEmpty)
 Button{export("json")}label:{Label(qL("Save complete backup"),systemImage:"square.and.arrow.up")}
 Button{importer=true}label:{Label(qL("Restore backup"),systemImage:"square.and.arrow.down")}
 Text(qL("Backups include photos, coordinates and weather. Share them only with people you choose.")).font(.footnote).foregroundStyle(.secondary)
 }
 Section(qL("Year in review")){
 Picker(qL("Year"),selection:$year){ForEach(((min(2000,v.rows.map{Calendar.current.component(.year,from:$0.at)}.min() ?? 2000))...Calendar.current.component(.year,from:Date())).reversed(),id:\.self){Text(String($0)).tag($0)}}
 Button(qL("Share annual report")){do{share=rShareItem(url:try qReport(v.rows,year:year))}catch{v.issue=qL("Could not prepare the export.")}}.disabled(v.rows.isEmpty)
 }
 Section(qL("Weather")){Toggle(qL("Fetch weather automatically"),isOn:$online);Text(qL("When enabled, coordinates and date are sent to ECCC GDPS / NASA POWER to attach model weather to new entries. Saved snapshots never change. Without a connection you can still save.")).font(.footnote).foregroundStyle(.secondary)
 if let w=v.pack.cache{rWeather(w:w)}
 if let p=v.point{Text(String(format:"%.5f, %.5f",p.0,p.1)).font(.caption.monospaced()).foregroundStyle(.secondary);Button(qL("Refresh latest weather")){Task{do{_ = try await v.weather(lat:p.0,lon:p.1,at:Date())}catch{v.issue=qL("Weather unavailable. Your entry can be saved without it.")}}}.disabled(!online)}
 Link("DWD · Bright Sky",destination:URL(string:"https://brightsky.dev/")!);Link("ECCC · GDPS",destination:URL(string:"https://eccc-msc.github.io/open-data/licence/readme_en/")!);Link("NASA POWER",destination:URL(string:"https://power.larc.nasa.gov/")!)
 Link("CC BY 4.0",destination:URL(string:"https://creativecommons.org/licenses/by/4.0/")!)
 }
   F2d798(encode: v.prepare2d798, apply: v.accept2d798)
 Section(qL("Reminders")){
 Text(qL("Choose a gentle prompt to record your catch or prepare for the weekend. Notifications are requested only when you enable a reminder.")).font(.footnote).foregroundStyle(.secondary)
 Toggle(qL("Daily journal reminder"),isOn:$daily).onChange(of:daily){_,_ in schedule()}
 Toggle(qL("Friday preparation"),isOn:$weekend).onChange(of:weekend){_,_ in schedule()}
 Picker(qL("Time"),selection:$hour){ForEach(0..<24,id:\.self){Text(String(format:"%02d:00",$0)).tag($0)}}.onChange(of:hour){_,_ in schedule()}
 }
 Section(qL("Privacy & sources")){
 Text(qL("No ads, purchases, analytics or tracking. The journal and photos are stored locally. iCloud sync uses your private database only when enabled. Weather requests share coordinates with ECCC GDPS / NASA POWER. Exports leave the app only through your chosen destination.")).font(.footnote)
 Text(qL("Location, camera and photos are optional. You can type a place and coordinates, and keep entries without a photo or weather.")).font(.footnote)
 Link(qL("Map data · Natural Earth · Public domain"),destination:URL(string:"https://www.naturalearthdata.com/about/terms-of-use/")!)
 Text("FIsh Bablosik · 1.2.2 (22)").font(.caption).foregroundStyle(.secondary)
 }
 }.navigationTitle(qL("Tools"))
 .sheet(item:$share){rShare(items:[$0.url])}
 .fileImporter(isPresented:$importer,allowedContentTypes:[.json]){result in
 do{let url=try result.get();let access=url.startAccessingSecurityScopedResource();defer{if access{url.stopAccessingSecurityScopedResource()}}
 let p=try JSONDecoder().decode(rP.self,from:Data(contentsOf:url));guard p.version==1,p.entries.count<100000,p.entries.allSatisfy({ !$0.species.isEmpty && $0.count>=0 && $0.count<=999 && $0.kg>=0 && $0.cm>=0 && ($0.photo?.count ?? 0)<700000 && ($0.lat.map{(-90...90).contains($0)} ?? true) && ($0.lon.map{(-180...180).contains($0)} ?? true)})else{throw CocoaError(.fileReadCorruptFile)}
 v.recovering = !v.readable
 v.readable=true
 for r in p.entries{if let i=v.pack.entries.firstIndex(where:{$0.id==r.id}){if r.changed>v.pack.entries[i].changed{v.pack.entries[i]=r}}else{v.pack.entries.append(r)}};_ = v.flush()
 }catch{v.issue=qL("This backup could not be restored. Choose a FIsh Bablosik JSON backup.")}
 }
 }}
 func schedule(){Task{if !(await v.reminders(log:daily,weekend:weekend,hour:hour)){daily=false;weekend=false}}}
 func export(_ ext:String){do{let u=FileManager.default.temporaryDirectory.appendingPathComponent("FIsh-Bablosik-\(UUID().uuidString.prefix(6)).\(ext)");let data=ext=="csv" ? Data(qCSV(v.rows).utf8):try JSONEncoder().encode(v.pack);try data.write(to:u);share=rShareItem(url:u)}catch{v.issue=qL("Could not prepare the export.")}}
}

struct rLaunch:View {
 @EnvironmentObject var v:rV
 var body:some View {
 #if DEBUG
 if ProcessInfo.processInfo.arguments.contains("--widget-qa") {
 ScrollView{VStack(spacing:20){
 ForEach([WidgetFamily.systemSmall,.systemMedium,.systemLarge,.accessoryRectangular],id:\.self){family in
 rGlance(override:family,entry:rTick(date:Date(),pack:v.pack)).frame(width:family == .systemSmall ? 170:350,height:family == .systemLarge ? 380:family == .accessoryRectangular ? 90:170).padding().background(Color(uiColor:.secondarySystemBackground),in:RoundedRectangle(cornerRadius:20))
 }
 }.padding(.vertical)}
 }else{rHome()}
 #else
 rHome()
 #endif
 }
}

import UniformTypeIdentifiers

private struct F2d798:View {
 let encode:() throws -> Data
 let apply:(Data) throws -> Void
 @Environment(\.locale) private var language
 @State private var exporting=false
 @State private var importing=false
 @State private var document:Envelope?
 @State private var status=""
 private var labels:[String] {
  let words:[String:[String]]=["en":["Export file","Import file","File imported"],"de":["Datei exportieren","Datei importieren","Datei importiert"],"fr":["Exporter un fichier","Importer un fichier","Fichier importé"],"es":["Exportar archivo","Importar archivo","Archivo importado"]]
  return words[language.language.languageCode?.identifier ?? "en"] ?? words["en"]!
 }
 private struct Envelope:FileDocument {
  static var readableContentTypes:[UTType]{[.json]}
  let contents:Data
  init(contents:Data){self.contents=contents}
  init(configuration:ReadConfiguration)throws{guard let data=configuration.file.regularFileContents else{throw CocoaError(.fileReadCorruptFile)};contents=data}
  func fileWrapper(configuration:WriteConfiguration)throws->FileWrapper{FileWrapper(regularFileWithContents:contents)}
 }
 var body:some View {
  VStack(alignment:.leading,spacing:12){
   Button {do {let payload=try encode();let obj=try JSONSerialization.jsonObject(with:payload,options:[.fragmentsAllowed])
    document=Envelope(contents:try JSONSerialization.data(withJSONObject:["format":"com.anglerlog.app/1","payload":obj]));status="";exporting=true
   }catch{status=error.localizedDescription}} label:{Label(labels[0],systemImage:"square.and.arrow.up")}.buttonStyle(.borderless)
   Button {importing=true} label:{Label(labels[1],systemImage:"square.and.arrow.down")}.buttonStyle(.borderless)
   if !status.isEmpty{Text(status).font(.footnote).foregroundStyle(.secondary)}
  }.fileExporter(isPresented:$exporting,document:document,contentType:.json,defaultFilename:"FIsh Bablosik - Records"){
   if case .failure(let error)=$0{status=error.localizedDescription}
  }.fileImporter(isPresented:$importing,allowedContentTypes:[.json]){
   do {let url=try $0.get();let scoped=url.startAccessingSecurityScopedResource();defer{if scoped{url.stopAccessingSecurityScopedResource()}}
    guard let size=try url.resourceValues(forKeys:[.fileSizeKey]).fileSize,size>0,size<100_000_000 else{throw CocoaError(.fileReadTooLarge)}
    let raw=try JSONSerialization.jsonObject(with:Data(contentsOf:url))
    guard let envelope=raw as? [String:Any],envelope["format"] as? String=="com.anglerlog.app/1",let payload=envelope["payload"] else{throw CocoaError(.fileReadCorruptFile)}
    try apply(JSONSerialization.data(withJSONObject:payload,options:[.fragmentsAllowed]));status=labels[2]
   }catch{status=error.localizedDescription}
  }
 }
}

#if targetEnvironment(simulator)
private enum StoreCaptureRoute {
    static var index: Int? {
        let process = ProcessInfo.processInfo
        let args = process.arguments
        if let at = args.firstIndex(of:"-ReviewScreen"), args.indices.contains(at+1) {
            return ["fishing-journal", "catch-details", "fishing-atlas", "species-calendar", "edit-entry", "catch-card"].firstIndex(of:args[at+1])
        }
        guard args.contains("-AppStoreScreenshots") || process.environment["APPSTORE_SCREENSHOTS"] == "1" else { return nil }
        if let at = args.firstIndex(of: "-AppStoreScreenshotScreen"), args.indices.contains(at+1) { return Int(args[at+1]) }
        return Int(process.environment["APPSTORE_SCREENSHOT_SCREEN"] ?? "0")
    }
}

@MainActor private struct StoreCaptureScene: View {
    let index: Int
    @StateObject private var model: rV
    init(index: Int) {
        self.index = index
        let m = rV()
        let names = ["European perch", "Northern pike", "Rainbow trout", "Brown trout", "Common roach"]
        let places = ["Windermere", "Lough Corrib", "Lac d’Annecy", "Llyn Tegid", "Vänern"]
        let lures = ["Gold spinner", "Silver spoon", "Dry fly", "Copper nymph", "Soft shad"]
        let coords = [(54.37,-2.94),(53.48,-9.30),(45.85,6.17),(52.89,-3.63),(58.90,13.40)]
        m.pack.entries = (0..<16).map { i in
            let k = i % names.count, time = Calendar.current.date(byAdding:.day,value:-i,to:Date())!
            let (lat,lon) = coords[k]
            let weather = rW(at:time,lat:lat,lon:lon,temp:12,wind:9,pressure:1018,rain:0,code:2,provider:"Open-Meteo")
            return rE(at:time,species:names[k],lure:lures[k],place:places[k],count:1+i%4,kg:1.7+Double(k)*0.5,cm:38+Double(k)*2,note:"A slow retrieve along the reed edge at first light.",lat:lat,lon:lon,weather:weather)
        }
        m.pack.entries[5].photo = UIImage(named:"LakePlate")?.jpegData(compressionQuality:0.9)
        _model = StateObject(wrappedValue:m)
    }
    var body: some View {
        let sample = model.pack.entries[0]
        Group {
            switch index {
            case 1: rDetail(id:sample.id)
            case 2: rHome(tab:1)
            case 3: rHome(tab:2)
            case 4: rEdit(row:sample)
            case 5:
                ZStack {
                    qSand.ignoresSafeArea()
                    if let card = ImageRenderer(content:rCard(row:model.pack.entries[5]).frame(width:600)).uiImage {
                        Image(uiImage:card).resizable().scaledToFit().frame(maxWidth:620).padding(18)
                    }
                }
            default: rHome()
            }
        }.environmentObject(model)
    }
}

#endif
