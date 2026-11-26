import SwiftUI
import MapKit
import PhotosUI
import Photos

struct rEdit:View {
 @EnvironmentObject var v:rV;@Environment(\.dismiss) var dismiss
 @AppStorage("onlineWeather") var online=false
 @State var row:rE;@State var lat="";@State var lon="";@State var photo:PhotosPickerItem?
 @State var camera=false;@State var chooseMap=false;@State var working=false;@State var message=""
 @State var selection:UUID?
 var valid:Bool { !row.species.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty && !row.lure.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty && ((lat.isEmpty && lon.isEmpty) || coordinates != nil) && row.kg.isFinite && row.cm.isFinite && row.kg>=0 && row.cm>=0 && row.kg<=10000 && row.cm<=3000 && row.species.trimmingCharacters(in:.whitespacesAndNewlines).count<=120 && row.lure.trimmingCharacters(in:.whitespacesAndNewlines).count<=120 && row.place.count<=240 && row.note.count<=12000 }
 var coordinates:(Double,Double)? {guard let a=Double(lat.replacingOccurrences(of:",",with:".")),let b=Double(lon.replacingOccurrences(of:",",with:".")),(-90...90).contains(a),(-180...180).contains(b)else{return nil};return(a,b)}
 var body:some View{NavigationStack{Form{
 Section{DatePicker(qL("Date & time"),selection:$row.at,in:...Date());TextField(qL("Species"),text:$row.species).accessibilityIdentifier("speciesInput");TextField(qL("Lure"),text:$row.lure).accessibilityIdentifier("lureInput");Stepper(value:$row.count,in:0...999){HStack{Text(qL("Fish"));Spacer();Text("\(row.count)")}};HStack{Text(qL("Weight (kg)"));Spacer();TextField("0",value:$row.kg,format:.number).keyboardType(.decimalPad).multilineTextAlignment(.trailing)};HStack{Text(qL("Length (cm)"));Spacer();TextField("0",value:$row.cm,format:.number).keyboardType(.decimalPad).multilineTextAlignment(.trailing)}}header:{Text(qL("Catch details"))}footer:{Text(qL("Use zero fish to record a quiet outing. Weight and length describe the largest fish."))}
 Section(qL("Place")){
 TextField(qL("Place name (optional)"),text:$row.place)
 Button{v.locate()}label:{Label(v.locating ? qL("Finding location…"):qL("Use current location"),systemImage:"location")}.disabled(v.locating)
 HStack{TextField(qL("Latitude"),text:$lat).keyboardType(.numbersAndPunctuation).accessibilityIdentifier("latitudeInput");TextField(qL("Longitude"),text:$lon).keyboardType(.numbersAndPunctuation).accessibilityIdentifier("longitudeInput")}
 Button{v.stopLocate();chooseMap=true}label:{Label(qL("Choose on offline map"),systemImage:"mappin.and.ellipse")}
 if (!lat.isEmpty || !lon.isEmpty) && coordinates==nil{Text(qL("Enter latitude −90…90 and longitude −180…180, or leave both empty.")).font(.caption).foregroundStyle(.red)}
 }
 Section(qL("Weather snapshot")){
 Toggle(qL("Fetch weather automatically"),isOn:$online)
 Text(qL("When enabled, coordinates and date are sent to ECCC GDPS / NASA POWER to attach model weather to new entries. Saved snapshots never change. Without a connection you can still save.")).font(.caption).foregroundStyle(.secondary)
 if let w=row.weather{rWeather(w:w);Button(qL("Remove weather"),role:.destructive){row.weather=nil}}
 }
 Section(qL("Catch photo")){
 if let d=row.photo,let i=UIImage(data:d){Image(uiImage:i).resizable().scaledToFit().frame(maxHeight:220).frame(maxWidth:.infinity);Button(qL("Remove photo"),role:.destructive){row.photo=nil}}
 PhotosPicker(selection:$photo,matching:.images){Label(qL("Choose photo"),systemImage:"photo")}
 if UIImagePickerController.isSourceTypeAvailable(.camera){Button{camera=true}label:{Label(qL("Take photo"),systemImage:"camera")}}
 }
 Section{TextEditor(text:$row.note).frame(minHeight:100).accessibilityLabel(qL("Notes"))
 if row.note.count>12000{Text(qL("Notes are limited to 12,000 characters.")).font(.footnote).foregroundStyle(.red)}
 }header:{HStack{Text(qL("Notes"));Spacer();Text("\(row.note.count)/12000").font(.caption)}}
 if row.species.trimmingCharacters(in:.whitespacesAndNewlines).count>120 || row.lure.trimmingCharacters(in:.whitespacesAndNewlines).count>120 || row.place.count>240{Text(qL("Species and lure names allow 120 characters; place names allow 240.")).font(.footnote).foregroundStyle(.red)}
 
 }.scrollDismissesKeyboard(.interactively)
 .safeAreaInset(edge:.bottom){let text=v.issue.isEmpty ? message:v.issue;if !text.isEmpty{rNotice(text:text){v.issue="";message=""}}}
 .onDisappear{v.stopLocate()}
 .navigationTitle(qL(row.species.isEmpty ? "New entry":"Edit entry")).navigationBarTitleDisplayMode(.inline)
 .toolbar{ToolbarItem(placement:.cancellationAction){Button(qL("Cancel")){dismiss()}.disabled(working)};ToolbarItem(placement:.confirmationAction){Button{Task{await save()}}label:{if working{ProgressView()}else{Text(qL("Save"))}}.disabled(!valid || working).accessibilityIdentifier("saveEntry")}}
 .interactiveDismissDisabled(working)
 .onAppear{lat=row.lat.map{String($0)} ?? "";lon=row.lon.map{String($0)} ?? ""}
 .onChange(of:v.fix?.latitude){_,_ in if let c=v.fix{lat=String(c.latitude);lon=String(c.longitude)}}
 .onChange(of:photo){_,p in guard let p else{return};Task{defer{photo=nil};do{if let d=try await p.loadTransferable(type:Data.self),let i=UIImage(data:d),let cooked=qJPEG(i){row.photo=cooked}else{message=qL("Could not open this photo. Choose another image.")}}catch{message=qL("Could not open this photo. Choose another image.")}}}
 .sheet(isPresented:$camera){rCamera{image in if let image{row.photo=qJPEG(image)}}}
 .sheet(isPresented:$chooseMap){NavigationStack{rOffline(rows:[],selected:$selection,pick:{a,b in lat=String(format:"%.5f",a);lon=String(format:"%.5f",b);chooseMap=false}).overlay(alignment:.top){Text(qL("Tap the atlas to choose a point")).padding().background(.regularMaterial,in:Capsule()).padding()}.navigationTitle(qL("Choose location")).toolbar{Button(qL("Cancel")){chooseMap=false}}}}
 }}
 func save()async{
 guard valid else{return};working=true;defer{working=false}
 row.species=String(row.species.trimmingCharacters(in:.whitespacesAndNewlines).prefix(120));row.lure=String(row.lure.trimmingCharacters(in:.whitespacesAndNewlines).prefix(120));row.place=String(row.place.prefix(240));row.note=String(row.note.prefix(12000))
 let old=v.pack.entries.first{$0.id==row.id}
 let moved=old?.lat != coordinates?.0 || old?.lon != coordinates?.1 || old?.at != row.at
 row.lat=coordinates?.0;row.lon=coordinates?.1
 if moved{row.weather=nil}
 var missing=false
 if online,row.weather==nil,let(a,b)=coordinates {
 do{row.weather=try await v.weather(lat:a,lon:b,at:row.at)}catch{missing=true}
 }
 if v.put(row){dismiss();if missing{v.issue=qL("Entry saved without weather. Open it later to retry the snapshot.")};if UserDefaults.standard.bool(forKey:"cloudEnabled"){Task{await v.sync()}}}
 }
}
struct rWeather:View {
 var w:rW
 var body:some View{VStack(alignment:.leading,spacing:8){Label(w.label,systemImage:"cloud.sun").font(.headline)
 ViewThatFits{HStack(spacing:18){Text(String(format:"%.1f °C",w.temp));Text(String(format:"%.0f km/h",w.wind));Text(String(format:"%.0f hPa",w.pressure))};VStack(alignment:.leading){Text(String(format:"%.1f °C · %.0f km/h",w.temp,w.wind));Text(String(format:"%.0f hPa",w.pressure))}}
 Text(qL("Model weather")+" · "+w.at.formatted(date:.abbreviated,time:.shortened)).font(.caption).foregroundStyle(.secondary)
 Text(w.provider ?? "MET Norway / NASA POWER").font(.caption2).foregroundStyle(.secondary)
 }}
}
private struct CatchSlip: View {
 let row: rE
 var body: some View {
  HStack(spacing: 16) {
   Image(systemName: "water.waves").font(.title).padding(14)
    .overlay(Circle().strokeBorder(qSand.opacity(0.65))).accessibilityHidden(true)
   VStack(alignment: .leading, spacing: 5) {
    Text(qL("Field notes")).font(.caption.weight(.bold)).textCase(.uppercase).tracking(2)
    Text(row.species).font(.system(.title, design:.serif, weight:.bold))
    Text(row.at, format:.dateTime.day().month(.wide).year().hour().minute()).font(.subheadline)
   }
   Spacer(minLength:0)
  }.padding(18).padding(.bottom,8).foregroundStyle(qSand).frame(maxWidth:.infinity, alignment:.leading)
   .background(qDeep)
   .overlay(alignment:.bottom) {
    Canvas { context, size in
     var ticks = Path()
     for i in 0..<Int(size.width / 7) {
      let x = CGFloat(i) * 7
      ticks.move(to: CGPoint(x:x,y:size.height)); ticks.addLine(to: CGPoint(x:x,y:i.isMultiple(of:5) ? 0 : 5))
     }
     context.stroke(ticks,with:.color(qSand.opacity(0.7)),lineWidth:1)
    }.frame(height:10).accessibilityHidden(true)
   }.clipShape(RoundedRectangle(cornerRadius:6))
 }
}
struct rDetail:View {
 @EnvironmentObject var v:rV;@Environment(\.dismiss) var dismiss
 var id:UUID;@State var edit=false;@State var confirm=false;@State var share:rShareItem?;@State var saving=false
 var row:rE?{v.rows.first{$0.id==id}}
 var body:some View{NavigationStack{if let row{ScrollView{VStack(alignment:.leading,spacing:20){
 if let d=row.photo,let image=UIImage(data:d){Image(uiImage:image).resizable().scaledToFit().frame(maxHeight:380).frame(maxWidth:.infinity).clipShape(RoundedRectangle(cornerRadius:20))
  Text(row.species).font(.system(.largeTitle,design:.serif,weight:.bold))
  Text(row.at,format:.dateTime.day().month(.wide).year().hour().minute()).foregroundStyle(.secondary)
 }else{CatchSlip(row:row)}
 HStack{rTile(value:"\(row.count)",label:"Fish",icon:"fish");rTile(value:row.lure,label:"Lure",icon:"leaf")}
 if row.kg>0 || row.cm>0{Text(String(format:"%.2f kg · %.1f cm",row.kg,row.cm)).font(.title3.bold())}
 Label(row.place.isEmpty ? qL("Fishing place"):row.place,systemImage:"mappin.and.ellipse").font(.headline);Text(row.coordinateLabel).font(.caption.monospaced()).textSelection(.enabled)
 if row.lat != nil{rOffline(rows:[row],selected:.constant(nil)).frame(height:220).clipShape(RoundedRectangle(cornerRadius:18))}
 if let w=row.weather{rWeather(w:w)}else{Label(qL("No weather snapshot"),systemImage:"cloud.slash").foregroundStyle(.secondary);Text(qL("Edit and save with online weather enabled to retry for this entry’s date.")).font(.caption).foregroundStyle(.secondary)}
 if !row.note.isEmpty{Text(row.note).textSelection(.enabled)}
 Button{card(row,save:false)}label:{Label(qL("Share catch card"),systemImage:"square.and.arrow.up")}
 Button{card(row,save:true)}label:{Label(saving ? qL("Saving…"):qL("Save card to Photos"),systemImage:"photo.badge.arrow.down")}.disabled(saving)
 Button(qL("Delete entry"),role:.destructive){confirm=true}
 }.padding(22)}.safeAreaInset(edge:.bottom){if !v.issue.isEmpty{rNotice(text:v.issue){v.issue=""}}}.navigationTitle(qL("Catch details")).navigationBarTitleDisplayMode(.inline).toolbar{ToolbarItem(placement:.cancellationAction){Button(qL("Done")){dismiss()}};ToolbarItem(placement:.topBarTrailing){Button(qL("Edit")){edit=true}}}
 .sheet(isPresented:$edit){rEdit(row:row)}.sheet(item:$share){rShare(items:[$0.url])}
 .confirmationDialog(qL("Delete this entry?"),isPresented:$confirm,titleVisibility:.visible){Button(qL("Delete entry"),role:.destructive){v.delete(row);dismiss()};Button(qL("Cancel"),role:.cancel){}}
 }else{ContentUnavailableView(qL("Entry unavailable"),systemImage:"book.closed")}}}
 @MainActor func card(_ row:rE,save:Bool){
 let render=ImageRenderer(content:rCard(row:row).frame(width:600));render.scale=2
 guard let image=render.uiImage,let data=image.pngData()else{return}
 if save{saving=true;Task{let permission=await PHPhotoLibrary.requestAuthorization(for:.addOnly);guard permission == .authorized || permission == .limited else{saving=false;v.issue=qL("Photo access is off. Use Share to save the card elsewhere.");return}
 do{try await PHPhotoLibrary.shared().performChanges{PHAssetChangeRequest.creationRequestForAsset(from:image)};v.issue=qL("Catch card saved to Photos.")}catch{v.issue=qL("Could not save the card to Photos.")};saving=false}}
 else{do{let u=FileManager.default.temporaryDirectory.appendingPathComponent("Catch-\(row.id).png");try data.write(to:u);share=rShareItem(url:u)}catch{v.issue=qL("Could not prepare the export.")}}
 }
}
struct rCard:View {var row:rE;var body:some View{VStack(alignment:.leading,spacing:20){HStack{Image(systemName:"fish");Text("FIsh Bablosik").tracking(3)}.font(.headline).foregroundStyle(qSand);if let d=row.photo,let i=UIImage(data:d){Image(uiImage:i).resizable().scaledToFill().frame(height:300).clipped().clipShape(RoundedRectangle(cornerRadius:18))};Text(row.species).font(.system(size:42,weight:.bold,design:.serif));Text(row.at,format:.dateTime.day().month(.wide).year()).foregroundStyle(qSand);Text("\(row.count) "+qL("Fish")+" · "+row.lure).font(.title2);Text(row.place);if let w=row.weather{Text(String(format:"%.1f °C · %.0f km/h · %.0f hPa",w.temp,w.wind,w.pressure)).font(.headline);Text(w.provider ?? "MET Norway / NASA POWER").font(.caption2);Text("creativecommons.org/licenses/by/4.0").font(.caption2)};if !row.note.isEmpty{Text(row.note).lineLimit(8)}}.padding(36).frame(maxWidth:.infinity,alignment:.leading).foregroundStyle(.white).background(qDeep)}}
struct rShareItem:Identifiable{let id=UUID();var url:URL}
struct rShare:UIViewControllerRepresentable{var items:[Any];func makeUIViewController(context:Context)->UIActivityViewController{UIActivityViewController(activityItems:items,applicationActivities:nil)};func updateUIViewController(_ uiViewController:UIActivityViewController,context:Context){}}
struct rCamera:UIViewControllerRepresentable{
 @Environment(\.dismiss)var dismiss;var done:(UIImage?)->Void
 func makeCoordinator()->Q{Q(self)}
 func makeUIViewController(context:Context)->UIImagePickerController{let p=UIImagePickerController();p.sourceType = .camera;p.delegate=context.coordinator;return p}
 func updateUIViewController(_ uiViewController:UIImagePickerController,context:Context){}
 final class Q:NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate{let p:rCamera;init(_ p:rCamera){self.p=p};func imagePickerControllerDidCancel(_ picker:UIImagePickerController){p.done(nil);p.dismiss()};func imagePickerController(_ picker:UIImagePickerController,didFinishPickingMediaWithInfo info:[UIImagePickerController.InfoKey:Any]){p.done(info[.originalImage] as? UIImage);p.dismiss()}}
}
final class rTiles:MKTileOverlay {
 override func url(forTilePath path:MKTileOverlayPath)->URL{Bundle.main.resourceURL!.appendingPathComponent("OfflineTiles/\(min(4,path.z))/\(path.x)/\(path.y).png")}
 override func loadTile(at path:MKTileOverlayPath,result:@escaping(Data?,Error?)->Void){let u=url(forTilePath:path);do{result(try Data(contentsOf:u),nil)}catch{result(nil,error)}}
}
struct rOffline:UIViewRepresentable {
 var rows:[rE];@Binding var selected:UUID?;var pick:((Double,Double)->Void)?=nil
 func makeCoordinator()->Q{Q(self)}
 func makeUIView(context:Context)->MKMapView{
 let m=MKMapView();m.delegate=context.coordinator;m.pointOfInterestFilter = .excludingAll;m.showsCompass=true;m.isRotateEnabled=false;m.isPitchEnabled=false
 let t=rTiles(urlTemplate:nil);t.canReplaceMapContent=true;t.minimumZ=0;t.maximumZ=4;m.addOverlay(t,level:.aboveLabels)
 m.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance:1_800_000,maxCenterCoordinateDistance:40_000_000),animated:false)
 m.addGestureRecognizer(UITapGestureRecognizer(target:context.coordinator,action:#selector(Q.tap(_:))))
 let located=rows.filter{$0.lat != nil && $0.lon != nil}
 #if targetEnvironment(simulator)
 if (ProcessInfo.processInfo.arguments.contains("-AppStoreScreenshots") || ProcessInfo.processInfo.arguments.contains("-ReviewScreen")), located.count > 1, let r=located.first {
    m.setRegion(MKCoordinateRegion(center:CLLocationCoordinate2D(latitude:r.lat!,longitude:r.lon!),span:MKCoordinateSpan(latitudeDelta:75,longitudeDelta:85)),animated:false)
    return m
 }
 #endif
 if let r=located.first{m.setRegion(MKCoordinateRegion(center:CLLocationCoordinate2D(latitude:r.lat!,longitude:r.lon!),span:MKCoordinateSpan(latitudeDelta:20,longitudeDelta:25)),animated:false)}else{m.setRegion(MKCoordinateRegion(center:CLLocationCoordinate2D(latitude:28,longitude:0),span:MKCoordinateSpan(latitudeDelta:140,longitudeDelta:300)),animated:false)}
 return m
 }
 func updateUIView(_ m:MKMapView,context:Context){context.coordinator.parent=self
 let pins=Dictionary(uniqueKeysWithValues:m.annotations.compactMap{a -> (UUID,rPin)? in guard let p=a as? rPin else{return nil};return(p.key,p)})
 let located=rows.filter{$0.lat != nil && $0.lon != nil}
 let changed=pins.count != located.count || located.contains{r in guard let p=pins[r.id] else{return true};return p.coordinate.latitude != r.lat! || p.coordinate.longitude != r.lon! || p.title != r.species}
 if changed {
 m.removeAnnotations(m.annotations);m.addAnnotations(located.map{rPin(row:$0,a:$0.lat!,b:$0.lon!)})
 if let r=located.first,located.count==1 {m.setCenter(CLLocationCoordinate2D(latitude:r.lat!,longitude:r.lon!),animated:false)}
 }
 }
 final class Q:NSObject,MKMapViewDelegate{
 var parent:rOffline;init(_ p:rOffline){parent=p}
 func mapView(_ mapView:MKMapView,rendererFor overlay:MKOverlay)->MKOverlayRenderer{if let t=overlay as? MKTileOverlay{return MKTileOverlayRenderer(tileOverlay:t)};return MKOverlayRenderer(overlay:overlay)}
 func mapView(_ mapView:MKMapView,didSelect annotation:MKAnnotation){if let a=annotation as? rPin{parent.selected=a.key}}
 func mapView(_ mapView:MKMapView,viewFor annotation:MKAnnotation)->MKAnnotationView?{guard annotation is rPin else{return nil};let v=MKMarkerAnnotationView(annotation:annotation,reuseIdentifier:"reedpin");v.markerTintColor=UIColor(qOrange);v.glyphImage=UIImage(systemName:"fish.fill");return v}
 @objc func tap(_ recognizer:UITapGestureRecognizer){guard let m=recognizer.view as? MKMapView,let pick=parent.pick else{return};let c=m.convert(recognizer.location(in:m),toCoordinateFrom:m);pick(c.latitude,c.longitude)}
 }
}
final class rPin:NSObject,MKAnnotation{let key:UUID;let coordinate:CLLocationCoordinate2D;let title:String?;init(row:rE,a:Double,b:Double){key=row.id;coordinate=CLLocationCoordinate2D(latitude:a,longitude:b);title=row.species}}

struct rNotice:View {
 var text:String;var clear:()->Void
 var body:some View{HStack(alignment:.center,spacing:12){Text(text).font(.footnote).frame(maxWidth:.infinity,alignment:.leading);Button(qL("OK"),action:clear).buttonStyle(.bordered)}.padding().background(.regularMaterial)}
}
