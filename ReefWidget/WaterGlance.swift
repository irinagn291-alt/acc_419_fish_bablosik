import SwiftUI
import WidgetKit

struct rTick:TimelineEntry{var date:Date;var pack:rP}
struct rFeed:TimelineProvider {
 func placeholder(in context:Context)->rTick{rTick(date:Date(),pack:rP())}
 func getSnapshot(in context:Context,completion:@escaping(rTick)->Void){completion(read())}
 func getTimeline(in context:Context,completion:@escaping(Timeline<rTick>)->Void){completion(Timeline(entries:[read()],policy:.after(Date(timeIntervalSinceNow:3600))))}
 func read()->rTick{let p=UserDefaults(suiteName:qG)?.data(forKey:"ledger").flatMap{try? JSONDecoder().decode(rP.self,from:$0)} ?? rP();return rTick(date:Date(),pack:p)}
}
struct rGlance:View {
 @Environment(\.widgetFamily) var systemFamily
 var override:WidgetFamily? = nil
 var family:WidgetFamily { override ?? systemFamily }
 let entry:rTick
 var rows:[rE]{entry.pack.entries.filter{ !$0.removed }}
 var stats:rS{rS(rows:rows)}
 var body:some View {
 Group { switch family {
 case .accessoryCircular: circle
 case .accessoryRectangular: lock
 case .accessoryInline: inline
 case .systemSmall: small
 case .systemMedium: medium
 default: large
 }}.containerBackground(for:.widget){Color(uiColor:.systemBackground)}
 }
 @ViewBuilder var circle:some View {
 if let w=entry.pack.cache {VStack(spacing:0){Image(systemName:"wind");Text("\(Int(w.wind))").font(.headline);Text("km/h").font(.system(size:8))}}else{Image(systemName:"cloud.slash")}
 }
 @ViewBuilder var lock:some View {
 if let w=entry.pack.cache {VStack(alignment:.leading){Text(String(format:"%.0f hPa · %.0f km/h",w.pressure,w.wind)).font(.headline);Text(w.at,format:.dateTime.day().month().hour().minute()).font(.caption);Text(qL("Last weather")).font(.caption2)}}else{Label(qL("No weather snapshot"),systemImage:"cloud.slash")}
 }
 @ViewBuilder var inline:some View {
 if let w=entry.pack.cache{Text(String(format:"%.0f hPa · %.0f km/h",w.pressure,w.wind))}else{Text(qL("No weather snapshot"))}
 }
 var small:some View {
 VStack(alignment:.leading,spacing:8){
 Label("FIsh Bablosik",systemImage:"fish").font(.caption.bold()).foregroundStyle(qAccent)
 Spacer(minLength:0)
 Text("\(rows.count)").font(.system(size:42,weight:.bold,design:.rounded)).minimumScaleFactor(0.5).lineLimit(1).foregroundStyle(.primary)
 Text(qL("Entries")).font(.caption)
 HStack{Image(systemName:"calendar").foregroundStyle(qOrange);Text("\(rS(rows:stats.month).fish) "+qL("Fish this month")).font(.caption2)}
 Spacer(minLength:0)
 }.widgetURL(URL(string:"anglerlog://add"))
 }
 var medium:some View {
 HStack(spacing:20){
 VStack(alignment:.leading,spacing:8){Image(systemName:"cloud.sun.fill").font(.largeTitle).foregroundStyle(qOrange);Text(qL("Fishing weather")).font(.headline).foregroundStyle(.primary);Text(qL("Last weather")).font(.caption).foregroundStyle(.secondary)}
 Spacer(minLength:0)
 weatherText
 }
 }
 @ViewBuilder var weatherText:some View {
 if let w=entry.pack.cache {
 VStack(alignment:.trailing,spacing:6){Text(String(format:"%.0f°",w.temp)).font(.system(size:34,weight:.bold));Text(String(format:"%.0f km/h · %.0f hPa",w.wind,w.pressure)).font(.caption);Text(w.at,format:.dateTime.day().month().hour().minute()).font(.caption2).foregroundStyle(.secondary);Text(w.at.timeIntervalSinceNow < -7200 ? qL("Cached weather"):qL("Model weather")).font(.caption2).foregroundStyle(qAccent)}
 }else{Text(qL("Open the app and fetch weather at a fishing point.")).font(.caption).foregroundStyle(.secondary)}
 }
 var large:some View {
 VStack(alignment:.leading,spacing:10){
 HStack{Label(qL("Season map"),systemImage:"map").font(.headline);Spacer();Text("\(stats.fish) "+qL("Fish")).font(.caption.bold()).foregroundStyle(qAccent)}
 rAtlas(rows:rows.filter{Calendar.current.isDate($0.at,equalTo:entry.date,toGranularity:.year)}).frame(height:95).clipShape(RoundedRectangle(cornerRadius:12))
 lureList
 Text(qL("Species calendar")).font(.caption.bold())
 days
 Text(stats.species.prefix(3).joined(separator:" · ")).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
 }.widgetURL(URL(string:"anglerlog://activity"))
 }
 var lureList:some View {
 VStack(alignment:.leading,spacing:5){
 Text(qL("Lure performance")).font(.caption.bold())
 if stats.lures.isEmpty{Text(qL("No entries yet")).font(.caption2).foregroundStyle(.secondary)}
 ForEach(Array(stats.lures.prefix(3)),id:\.0){item in HStack{Text(item.0).lineLimit(1);Spacer();Text("\(item.1)").foregroundStyle(qAccent)}.font(.caption2)}
 }
 }
 var days:some View {
 HStack(spacing:4){ForEach(0..<14,id:\.self){n in day(n)}}
 }
 func day(_ n:Int)->some View {
 let d=Calendar.current.date(byAdding:.day,value:n-13,to:entry.date)!
 let count=stats.day(d)
 return VStack(spacing:3){RoundedRectangle(cornerRadius:3).fill(count>0 ? qBlue:qBlue.opacity(0.08)).frame(height:18);Text(d,format:.dateTime.day()).font(.system(size:8))}.frame(maxWidth:.infinity)
 }
}

#if WIDGET_EXTENSION
@main struct rWidget:Widget {
 var body:some WidgetConfiguration{StaticConfiguration(kind:"ReedGlance",provider:rFeed()){rGlance(entry:$0)}.configurationDisplayName("FIsh Bablosik").description(qL("Your journal, weather and fishing patterns, available offline.")).supportedFamilies([.systemSmall,.systemMedium,.systemLarge,.accessoryCircular,.accessoryRectangular,.accessoryInline])}
}

#endif
