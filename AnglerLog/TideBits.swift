import Foundation
import SwiftUI

let qG = "group.com.anglerlog.app"
let qC = "iCloud.com.anglerlog.app"
func qL(_ s:String)->String { NSLocalizedString(s, comment: "") }
let qBlue = Color(red:0.12,green:0.37,blue:0.34)
let qAccent = Color("ReedAccent")
let qDeep = Color(red:0.047,green:0.20,blue:0.18)
let qOrange = Color(red:0.976,green:0.451,blue:0.086)
let qSand = Color(red:0.957,green:0.894,blue:0.757)

struct rW:Codable,Equatable {
 var at:Date; var lat:Double; var lon:Double
 var temp:Double; var wind:Double; var pressure:Double; var rain:Double; var code:Int
 var fetched:Date? = nil;var provider:String?=nil
 var label:String {
 switch code {
 case -1:return qL("Model weather")
 case 0:return qL("Clear")
 case 1...3:return qL("Cloudy")
 case 45,48:return qL("Fog")
 case 71...77,85,86:return qL("Snow")
 case 95...99:return qL("Thunderstorm")
 case 80...82:return qL("Showers")
 default:return qL("Rain")
 }
 }
}
struct rE:Codable,Identifiable,Equatable {
 var id:UUID = UUID(); var at:Date = Date(); var species:String = ""; var lure:String = ""
 var place:String = ""; var count:Int = 1; var kg:Double = 0; var cm:Double = 0; var note:String = ""
 var lat:Double?; var lon:Double?; var weather:rW?; var photo:Data?
 var changed:Date = Date(); var removed:Bool = false
 var coordinateLabel:String { guard let lat,let lon else{return qL("No location")}; return String(format:"%.5f, %.5f",lat,lon) }
}
struct rP:Codable {
 var version:Int = 1; var entries:[rE] = []; var cache:rW?
}
struct rS {
 var rows:[rE]
 var fish:Int { rows.reduce(0){$0 + $1.count} }
 var month:[rE] { rows.filter{Calendar.current.isDate($0.at,equalTo:Date(),toGranularity:.month)} }
 var lures:[(String,Int)] { Dictionary(grouping:rows,by:{$0.lure}).map{($0.key,$0.value.reduce(0){$0+$1.count})}.sorted{$0.1 > $1.1} }
 var species:[String] { Array(Set(rows.map(\.species))).sorted() }
 func day(_ d:Date,species:String = "",lure:String = "",sky:String = "")->Int {
 rows.filter{Calendar.current.isDate($0.at,inSameDayAs:d) && (species.isEmpty || $0.species == species) && (lure.isEmpty || $0.lure == lure) && (sky.isEmpty || $0.weather?.label == sky)}.reduce(0){$0+$1.count}
 }
}
func qCSV(_ rows:[rE])->String {
 func e(_ s:String)->String { "\"" + s.replacingOccurrences(of:"\"",with:"\"\"") + "\"" }
 let f=ISO8601DateFormatter()
 let header=["Date","Species","Lure","Place","Fish","Weight kg","Length cm","Latitude","Longitude","Weather date","Temperature C","Wind km/h","Pressure hPa","Rain mm","Notes","Weather source","Weather license"]
 return ([header.map(e).joined(separator:",")] + rows.map { r in
 [f.string(from:r.at),r.species,r.lure,r.place,String(r.count),String(r.kg),String(r.cm),r.lat.map{String($0)} ?? "",r.lon.map{String($0)} ?? "",r.weather.map{f.string(from:$0.at)} ?? "",r.weather.map{String($0.temp)} ?? "",r.weather.map{String($0.wind)} ?? "",r.weather.map{String($0.pressure)} ?? "",r.weather.map{String($0.rain)} ?? "",r.note,r.weather == nil ? "":"MET Norway / NASA POWER",r.weather == nil ? "":"https://creativecommons.org/licenses/by/4.0/"].map(e).joined(separator:",")
 }).joined(separator:"\r\n")
}
struct rAtlas:View {
 var rows:[rE]
 var body:some View {
 GeometryReader { geo in
 ZStack {
 Image("atlas",bundle:.main).resizable().frame(width:geo.size.width,height:geo.size.height).clipped()
 ForEach(rows.filter{$0.lat != nil && $0.lon != nil}) { r in
 let x=(r.lon!+180)/360*geo.size.width
 let phi=min(85,max(-85,r.lat!))*Double.pi/180
 let y=(1-log(tan(phi)+1/cos(phi))/Double.pi)/2*geo.size.height
 Circle().fill(qOrange).frame(width:8,height:8).overlay(Circle().stroke(.white,lineWidth:1)).position(x:x,y:y)
 }
 }
 }.clipped().accessibilityLabel(qL("Season map"))
 }
}
