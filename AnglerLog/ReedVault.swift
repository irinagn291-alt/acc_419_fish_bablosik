import SwiftUI
import CoreLocation
import WidgetKit
import UserNotifications
import BackgroundTasks

@MainActor final class rV:NSObject,ObservableObject,@preconcurrency CLLocationManagerDelegate {
 @Published var pack=rP(); @Published var issue=""; @Published var cloud=""; @Published var busy=false
 @Published var locating=false; @Published var fix:CLLocationCoordinate2D?
 let gps=CLLocationManager()
 private var gpsTimer:Task<Void,Never>?
 private var qLater=false
 private let disk:URL
 var readable=true
 var recovering=false
 var rows:[rE] { pack.entries.filter{ !$0.removed }.sorted{$0.at > $1.at} }
 var point:(Double,Double)? {
 if let row=rows.first(where:{$0.lat != nil && $0.lon != nil}){return(row.lat!,row.lon!)}
 if let w=pack.cache{return(w.lat,w.lon)}
 return nil
 }
 override init() {
 let base=FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0]
 disk=base.appendingPathComponent("reed-ledger.json")
 super.init()
 #if DEBUG
 if ProcessInfo.processInfo.arguments.contains("--qa-reset") {
 try? FileManager.default.removeItem(at:disk)
 for key in ["onlineWeather","cloudEnabled","daily","weekend"]{UserDefaults.standard.removeObject(forKey:key)}
 }
 #endif
 gps.delegate=self; gps.desiredAccuracy=kCLLocationAccuracyHundredMeters
 do { try FileManager.default.createDirectory(at:base,withIntermediateDirectories:true)
 if FileManager.default.fileExists(atPath:disk.path) { pack=try JSONDecoder().decode(rP.self,from:Data(contentsOf:disk)) }
 } catch { readable=false;issue=qL("Journal could not be read. Export or restore your backup before changing data.") }
 publish()
 }
 func publish() {
 var summary=pack
 summary.entries=rows.map{var r=$0;r.photo=nil;r.note="";return r}
 let d=try? JSONEncoder().encode(summary)
 UserDefaults(suiteName:qG)?.set(d,forKey:"ledger")
 WidgetCenter.shared.reloadAllTimelines()
 }
 @discardableResult func flush()->Bool {
 guard readable else{issue=qL("Journal could not be read. Export or restore your backup before changing data.");return false}
 do {
 if FileManager.default.fileExists(atPath:disk.path) && !recovering {
 let previous=try JSONDecoder().decode(rP.self,from:Data(contentsOf:disk))
 for entry in previous.entries {
 if let i=pack.entries.firstIndex(where:{$0.id==entry.id}) {if entry.changed>pack.entries[i].changed{pack.entries[i]=entry}}
 else{pack.entries.append(entry)}
 }
 if let cache=previous.cache,pack.cache == nil || (cache.fetched ?? cache.at) > (pack.cache!.fetched ?? pack.cache!.at) {pack.cache=cache}
 }
 try JSONEncoder().encode(pack).write(to:disk,options:[.atomic,.completeFileProtectionUntilFirstUserAuthentication]);recovering=false;publish();return true
 }
 catch {issue=qL("Could not save on this device. Please free storage and try again.");return false}
 }
 func put(_ entry:rE)->Bool {
 let old=pack
 var row=entry;let previous=pack.entries.first{$0.id==row.id}?.changed ?? row.changed;row.changed=max(Date(),max(previous,row.changed).addingTimeInterval(0.001))
 if let i=pack.entries.firstIndex(where:{$0.id==row.id}) {pack.entries[i]=row}else{pack.entries.append(row)}
 if flush(){return true};pack=old;return false
 }
 func delete(_ row:rE) { var e=rE();e.id=row.id;e.species="_";e.lure="_";e.count=0;e.removed=true;if put(e),UserDefaults.standard.bool(forKey:"cloudEnabled"){Task{await sync()}} }
 func stopLocate(){locating=false;gpsTimer?.cancel();gps.stopUpdatingLocation()}
 func locate() {
 guard !locating else{return};fix=nil;locating=true
 gpsTimer?.cancel();gpsTimer=Task {try? await Task.sleep(nanoseconds:18_000_000_000);if !Task.isCancelled && locating {gps.stopUpdatingLocation();locating=false;issue=qL("Location unavailable. Enter coordinates or choose a point on the map.")}}
 switch gps.authorizationStatus {
 case .notDetermined:gps.requestWhenInUseAuthorization()
 case .authorizedAlways,.authorizedWhenInUse:gps.requestLocation()
 default:locating=false;issue=qL("Location is off. You can enter a point manually.")
 }
 }
 func locationManagerDidChangeAuthorization(_ manager:CLLocationManager) {
 if locating {switch manager.authorizationStatus {
 case .authorizedAlways,.authorizedWhenInUse:manager.requestLocation()
 case .denied,.restricted:locating=false;issue=qL("Location is off. You can enter a point manually.")
 default:break}}
 }
 nonisolated func locationManager(_ manager:CLLocationManager,didUpdateLocations locations:[CLLocation]) {
 guard let p=locations.last else{return};Task{@MainActor in
 guard locating else{return};locating=false;gpsTimer?.cancel()
 guard p.horizontalAccuracy>=0,abs(p.timestamp.timeIntervalSinceNow)<=120 else{issue=qL("Location unavailable. Enter coordinates or choose a point on the map.");return}
 fix=p.coordinate
 }
 }
 nonisolated func locationManager(_ manager:CLLocationManager,didFailWithError error:Error) {Task{@MainActor in guard locating else{return};locating=false;gpsTimer?.cancel();issue=qL("Location unavailable. Enter coordinates or choose a point on the map.")}}
 func weather(lat:Double,lon:Double,at:Date) async throws ->rW {
 let requested=Date()
 var result:rW
 if at.timeIntervalSinceNow < -2*3600 {
  let format=DateFormatter();format.locale=Locale(identifier:"en_US_POSIX");format.timeZone=TimeZone(secondsFromGMT:0);format.dateFormat="yyyyMMdd"
  let day=format.string(from:at)
  format.dateFormat="yyyyMMddHH"
  let hour=format.string(from:at)
  let remoteLatitude=String(format:"%.2f",locale:Locale(identifier:"en_US_POSIX"),lat)
  let remoteLongitude=String(format:"%.2f",locale:Locale(identifier:"en_US_POSIX"),lon)
  let url=URL(string:"https://power.larc.nasa.gov/api/temporal/hourly/point?parameters=T2M,WS10M,PS,PRECTOTCORR&community=RE&longitude=\(remoteLongitude)&latitude=\(remoteLatitude)&start=\(day)&end=\(day)&time-standard=UTC&format=JSON")!
  let (d,response)=try await URLSession.shared.data(from:url)
  guard (response as? HTTPURLResponse)?.statusCode==200,let json=try JSONSerialization.jsonObject(with:d) as? [String:Any],
        let properties=json["properties"] as? [String:Any],let values=properties["parameter"] as? [String:[String:Double]],
        let t=values["T2M"]?[hour],let w=values["WS10M"]?[hour],let pressure=values["PS"]?[hour],let rain=values["PRECTOTCORR"]?[hour],
        t > -100,w >= 0,pressure > 0,rain >= 0 else {throw URLError(.resourceUnavailable)}
  result=rW(at:format.date(from:hour) ?? at,lat:lat,lon:lon,temp:t,wind:w*3.6,pressure:pressure*10,rain:rain,code:-1,provider:"NASA POWER")
 } else if let nearby=try? await HarbourForecast.sample(lat:lat,lon:lon,at:at) {
  result=nearby
 } else {
  guard !Task.isCancelled else{throw CancellationError()}
  result=try await HarbourGrid.sample(lat,lon,at)
 }
 result.fetched=requested
 if abs(at.timeIntervalSinceNow)<7200 {pack.cache=result;_ = flush()}
 return result
 }
 func refresh() async {
 guard UserDefaults.standard.bool(forKey:"onlineWeather") else{return}
 guard let p=point else{return}
 do {
 _ = try await weather(lat:p.0,lon:p.1,at:Date())
 let preferences=UserDefaults.standard
 if preferences.bool(forKey:"daily") || preferences.bool(forKey:"weekend") {
 let permission=await UNUserNotificationCenter.current().notificationSettings()
 if permission.authorizationStatus == .authorized || permission.authorizationStatus == .provisional {
 _ = await reminders(log:preferences.bool(forKey:"daily"),weekend:preferences.bool(forKey:"weekend"),hour:preferences.object(forKey:"hour") as? Int ?? 19)
 }
 }
 }catch{}
 }
 func sync() async {}
 func prepare2d798() throws -> Data {
  let value: [rE] = pack.entries
  return try JSONEncoder().encode(value)
 }
 func accept2d798(_ data:Data) throws {
  let incoming = try JSONDecoder().decode([rE].self, from:data)
  for e in incoming {if let i=pack.entries.firstIndex(where:{$0.id==e.id}){if e.changed>pack.entries[i].changed{pack.entries[i]=e}}else{pack.entries.append(e)}};guard flush() else{throw CocoaError(.fileWriteUnknown)}
 }

 func reminders(log:Bool,weekend:Bool,hour:Int) async ->Bool {
 let center=UNUserNotificationCenter.current()
 if log || weekend {
 do {guard try await center.requestAuthorization(options:[.alert,.sound,.badge]) else{issue=qL("Notifications are off. Enable them in system Settings.");return false}} catch{issue=qL("Notifications are off. Enable them in system Settings.");return false}
 }
 center.removePendingNotificationRequests(withIdentifiers:["reed.log","reed.weekend"])
 for (id,on,title,weekday) in [("reed.log",log,"Remember your catch",0),("reed.weekend",weekend,"Before the weekend",6)] where on {
 let c=UNMutableNotificationContent();c.title=qL(title);c.body=qL(weekday==0 ? "Add a few details to your fishing journal.":"Review your tackle and refresh the latest weather before heading out.");c.sound = .default
 if weekday>0,let w=pack.cache {c.body += "\n"+qL("Last weather")+" · "+w.at.formatted(date:.abbreviated,time:.shortened)+String(format:" · %.0f °C · %.0f km/h · %.0f hPa",w.temp,w.wind,w.pressure)}
 var date=DateComponents();date.hour=hour;date.minute=0;if weekday>0 {date.weekday=weekday}
 do {try await center.add(UNNotificationRequest(identifier:id,content:c,trigger:UNCalendarNotificationTrigger(dateMatching:date,repeats:true)))}catch{issue=qL("Could not schedule reminders.");return false}
 }
 return true
 }
}
final class rD:NSObject,UIApplicationDelegate {
 func application(_ application:UIApplication,didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey:Any]? = nil)->Bool {
 BGTaskScheduler.shared.register(forTaskWithIdentifier:"com.anglerlog.app.refresh",using:nil) { task in
 let work=Task{@MainActor in let vault=rV();await vault.refresh();task.setTaskCompleted(success:true);Self.plan()}
 task.expirationHandler={work.cancel()}
 };Self.plan();return true
 }
 static func plan(){let request=BGAppRefreshTaskRequest(identifier:"com.anglerlog.app.refresh");request.earliestBeginDate=Date(timeIntervalSinceNow:6*3600);try? BGTaskScheduler.shared.submit(request)}
 func application(_ application:UIApplication,performFetchWithCompletionHandler completionHandler:@escaping(UIBackgroundFetchResult)->Void) {Task{@MainActor in let v=rV();await v.refresh();completionHandler(.newData)}}
}

func qReport(_ rows:[rE],year:Int)throws->URL{
 let selected=rows.filter{Calendar.current.component(.year,from:$0.at)==year};let stats=rS(rows:selected)
 let u=FileManager.default.temporaryDirectory.appendingPathComponent("FIsh-Bablosik-\(year).pdf")
 let renderer=UIGraphicsPDFRenderer(bounds:CGRect(x:0,y:0,width:595,height:842))
 try renderer.writePDF(to:u){ctx in
 var y:CGFloat=70
 func page(){ctx.beginPage();y=70;UIColor(qDeep).setFill();ctx.cgContext.fill(CGRect(x:0,y:0,width:595,height:18))}
 func line(_ text:String,size:CGFloat=14,bold:Bool=false){
 let attrs:[NSAttributedString.Key:Any]=[.font:bold ? UIFont.boldSystemFont(ofSize:size):UIFont.systemFont(ofSize:size),.foregroundColor:UIColor(qDeep)]
 let storage=NSTextStorage(string:text,attributes:attrs);let layout=NSLayoutManager()
 storage.addLayoutManager(layout);let area=NSTextContainer(size:CGSize(width:475,height:CGFloat.greatestFiniteMagnitude));area.lineFragmentPadding=0;layout.addTextContainer(area);layout.ensureLayout(for:area)
 var glyph=0
 while glyph<layout.numberOfGlyphs {
 var span=NSRange();let bounds=layout.lineFragmentRect(forGlyphAt:glyph,effectiveRange:&span)
 let chars=layout.characterRange(forGlyphRange:span,actualGlyphRange:nil);let height=ceil(bounds.height)
 if y+height>780{page()}
 storage.attributedSubstring(from:chars).draw(at:CGPoint(x:60,y:y));y+=height;glyph=NSMaxRange(span)
 }
 y+=14
 }
 page();line("FIsh Bablosik · \(year)",size:30,bold:true);line(qL("Year in review"),size:20);line("\(selected.count) "+qL("Entries")+" · \(stats.fish) "+qL("Fish")+" · \(stats.species.count) "+qL("Species"));line(qL("Lure performance"),size:20,bold:true)
 for (l,n) in stats.lures{line("\(l) — \(n)")};line(qL("Field notes"),size:20,bold:true)
 for r in selected.sorted(by:{$0.at<$1.at}){line(r.at.formatted(date:.abbreviated,time:.omitted)+" · \(r.species) · \(r.count) · \(r.lure)",bold:true);if !r.place.isEmpty{line(r.place)};if !r.note.isEmpty{line(r.note)}}
 }
 return u
}

func qJPEG(_ image:UIImage)->Data?{
 let scale=min(1,900/max(image.size.width,image.size.height));let s=CGSize(width:image.size.width*scale,height:image.size.height*scale)
 let fmt=UIGraphicsImageRendererFormat();fmt.scale=1
 return UIGraphicsImageRenderer(size:s,format:fmt).image{_ in image.draw(in:CGRect(origin:.zero,size:s))}.jpegData(compressionQuality:0.65)
}

private enum HarbourForecast {
 struct Feed:Decodable {let sources:[Site];let weather:[Hour]}
 struct Site:Decodable {let id:Int;let distance:Double?;let station_name:String}
 struct Hour:Decodable {let timestamp:String;let source_id:Int;let temperature:Double?;let wind_speed:Double?;let pressure_msl:Double?;let precipitation:Double?;let icon:String?}
 static func sample(lat:Double,lon:Double,at:Date)async throws->rW {
  let iso=ISO8601DateFormatter();var query=URLComponents(string:"https://api.brightsky.dev/weather")!
  query.queryItems=["lat":String((lat*100).rounded()/100),"lon":String((lon*100).rounded()/100),"max_dist":"25000","tz":"UTC","units":"dwd","date":iso.string(from:at.addingTimeInterval(-3600)),"last_date":iso.string(from:at.addingTimeInterval(7200))].map{URLQueryItem(name:$0.key,value:$0.value)}
  let (data,reply)=try await URLSession.shared.data(for:URLRequest(url:query.url!,timeoutInterval:12))
  guard (reply as? HTTPURLResponse)?.statusCode==200,data.count<500000 else{throw URLError(.badServerResponse)}
  return try reading(data,lat:lat,lon:lon,at:at)
 }
 static func reading(_ data:Data,lat:Double,lon:Double,at:Date)throws->rW {
  let feed=try JSONDecoder().decode(Feed.self,from:data);let iso=ISO8601DateFormatter()
  let sites=Dictionary(feed.sources.filter{($0.distance ?? .infinity)<=25000}.map{($0.id,$0.station_name)},uniquingKeysWith:{$1})
  let times=feed.weather.compactMap{h in iso.date(from:h.timestamp).map{($0,h)}}
  let values=times.compactMap{date,h->rW? in
   guard abs(date.timeIntervalSince(at))<=3600,let station=sites[h.source_id],let t=h.temperature,(-100...65).contains(t),let w=h.wind_speed,(0...500).contains(w),let p=h.pressure_msl,(800...1120).contains(p),
   let next=times.first(where:{$0.1.source_id==h.source_id && abs($0.0.timeIntervalSince(date)-3600)<1}),let rain=next.1.precipitation,(0...500).contains(rain) else{return nil}
   let codes=["clear-day":0,"clear-night":0,"partly-cloudy-day":2,"partly-cloudy-night":2,"cloudy":3,"fog":45,"rain":61,"snow":71,"sleet":71,"thunderstorm":95]
   return rW(at:date,lat:lat,lon:lon,temp:t,wind:w,pressure:p,rain:rain,code:codes[h.icon ?? ""] ?? -1,provider:"DWD · "+station)
  }
  guard let sample=values.min(by:{abs($0.at.timeIntervalSince(at))<abs($1.at.timeIntervalSince(at))}) else{throw URLError(.resourceUnavailable)};return sample
 }
}

private enum HarbourGrid {
 struct MapReply:Decodable {let layer:String;let features:[Spot]
  struct Spot:Decodable {let properties:Reading;let geometry:Point}
  struct Point:Decodable {let coordinates:[Double]}
  struct Reading:Decodable {let value:Double;let time:String;let dim_reference_time:String}
 }
 static func sample(_ lat:Double,_ lon:Double,_ date:Date)async throws->rW {
  let iso=ISO8601DateFormatter(),hour=Date(timeIntervalSince1970:floor(date.timeIntervalSince1970/3600)*3600)
  // Query a pixel centred on the requested point using WMS 1.3 latitude/longitude axis order.
  guard lat.isFinite,lon.isFinite,(-90...90).contains(lat),(-180...180).contains(lon) else{throw URLError(.badURL)}
  let centerY=min(89.99,max(-89.99,(lat*100).rounded()/100))
  let centerX=min(179.99,max(-179.99,(lon*100).rounded()/100))
  let dy=min(0.1,90-abs(centerY)),dx=min(0.1,180-abs(centerX))
  let bbox=[centerY-dy,centerX-dx,centerY+dy,centerX+dx].map{String(format:"%.2f",locale:Locale(identifier:"en_US_POSIX"),$0)}.joined(separator:",")
  func get(_ name:String,_ time:Date)async throws->MapReply.Reading {
   let layer="GDPS_15km_"+name,stamp=iso.string(from:time)
   var point=URLComponents(string:"https://geo.weather.gc.ca/geomet")!
   point.queryItems=["SERVICE":"WMS","VERSION":"1.3.0","REQUEST":"GetFeatureInfo","CRS":"EPSG:4326","BBOX":bbox,"WIDTH":"101","HEIGHT":"101","I":"50","J":"50","LAYERS":layer,"QUERY_LAYERS":layer,"INFO_FORMAT":"application/json","FORMAT":"image/png","STYLES":"","TIME":stamp].map{URLQueryItem(name:$0.key,value:$0.value)}
   guard let url=point.url else{throw URLError(.badURL)}
   let (bytes,res)=try await URLSession.shared.data(for:URLRequest(url:url,timeoutInterval:18))
   guard (res as? HTTPURLResponse)?.statusCode==200,bytes.count<64000 else{throw URLError(.badServerResponse)}
   let map=try JSONDecoder().decode(MapReply.self,from:bytes)
   guard map.layer==layer,let spot=map.features.first,spot.geometry.coordinates.count==2,abs(spot.geometry.coordinates[1]-lat)<=0.16 else{throw URLError(.resourceUnavailable)}
   let delta=abs(spot.geometry.coordinates[0]-lon)
   guard min(delta,abs(delta-360))<=0.16,iso.date(from:spot.properties.time)==time,spot.properties.value.isFinite else{throw URLError(.cannotParseResponse)};return spot.properties
  }
  let t=try await get("AirTemp_2m",hour),w=try await get("WindSpeed_10m",hour),p=try await get("Pressure_MSL",hour),rain=try await get("Precip-Accum1h",hour.addingTimeInterval(3600))
  guard Set([t,w,p,rain].map(\.dim_reference_time)).count==1,(-105...70).contains(t.value),(0...155).contains(w.value),(80000...112000).contains(p.value),rain.value>=0 else{throw URLError(.badServerResponse)}
  return rW(at:hour,lat:lat,lon:lon,temp:t.value,wind:w.value*3.6,pressure:p.value/100,rain:rain.value,code:-1,provider:"ECCC · GDPS · 15 km · 1 h")
 }
}
