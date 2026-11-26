import XCTest
import SwiftUI

final class rChecks:XCTestCase {
 func testA_ModelRoundTripAndAggregates()throws{
 var a=rE();a.species="Perch";a.lure="A, \"B\"";a.count=3;a.lat=0;a.lon=0;a.note="first\nsecond";a.photo=Data([1,2,3]);a.weather=rW(at:Date(timeIntervalSince1970:100),lat:0,lon:0,temp:13,wind:9,pressure:1011,rain:0,code:1)
 var b=a;b.id=UUID();b.count=2
 let pack=rP(entries:[a,b]);let decoded=try JSONDecoder().decode(rP.self,from:JSONEncoder().encode(pack))
 XCTAssertEqual(decoded.entries,pack.entries);XCTAssertEqual(rS(rows:[a,b]).fish,5);XCTAssertEqual(rS(rows:[a,b]).lures.first?.1,5)
 XCTAssertEqual(rS(rows:[a,b]).day(a.at,species:"Trout"),0)
 XCTAssertTrue(qCSV([a]).contains("\"A, \"\"B\"\"\""));XCTAssertTrue(qCSV([a]).contains("first\nsecond"));XCTAssertEqual(a.weather?.at,decoded.entries[0].weather?.at)
 }
 @MainActor func testA2_InterleavedVaultWritesPreserveEntries()throws {
 let first=rV();let second=rV()
 var one=rE();one.species="Unit Perch";one.lure="Unit Spoon"
 var two=rE();two.species="Unit Trout";two.lure="Unit Worm"
 first.pack.cache=rW(at:Date(timeIntervalSince1970:100),lat:0,lon:0,temp:10,wind:3,pressure:1010,rain:0,code:0)
 first.pack.cache?.fetched=Date(timeIntervalSince1970:100)
 XCTAssertTrue(first.put(one))
 second.pack.cache=rW(at:Date(timeIntervalSince1970:100),lat:0,lon:0,temp:12,wind:6,pressure:1012,rain:0,code:1)
 second.pack.cache?.fetched=Date(timeIntervalSince1970:200)
 XCTAssertTrue(second.put(two))
 let check=rV();XCTAssertTrue(check.rows.contains{$0.id==one.id});XCTAssertTrue(check.rows.contains{$0.id==two.id})
 first.delete(one)
 let after=rV();XCTAssertEqual(after.pack.cache?.fetched,Date(timeIntervalSince1970:200));XCTAssertFalse(after.rows.contains{$0.id==one.id});XCTAssertTrue(after.rows.contains{$0.id==two.id})
 let marker=try XCTUnwrap(after.pack.entries.first{$0.id==one.id});XCTAssertTrue(marker.removed);XCTAssertNil(marker.photo);XCTAssertNil(marker.lat);XCTAssertEqual(marker.note,"")
 after.delete(two)
 }
 @MainActor func testA3_LongAnnualReportPaginates()throws {
 var row=rE();row.species="Unit Perch";row.lure="Unit Spoon";row.note=String(repeating:"Field observation with a detailed description. ",count:260)
 let url=try qReport([row],year:Calendar.current.component(.year,from:row.at))
 let document=try XCTUnwrap(CGPDFDocument(url as CFURL));XCTAssertGreaterThanOrEqual(document.numberOfPages,4)
 let artifact=XCTAttachment(data:try Data(contentsOf:url),uniformTypeIdentifier:"com.adobe.pdf");artifact.name="long-note-annual-report.pdf";artifact.lifetime = .keepAlways;add(artifact)
 }
 @MainActor func testA4_PhotoEncodingAndPersistence()throws {
 let format=UIGraphicsImageRendererFormat();format.scale=1
 let original=UIGraphicsImageRenderer(size:CGSize(width:1200,height:600),format:format).image{ctx in UIColor.blue.setFill();ctx.fill(CGRect(x:0,y:0,width:1200,height:600))}
 let data=try XCTUnwrap(qJPEG(original));let decoded=try XCTUnwrap(UIImage(data:data))
 XCTAssertEqual(decoded.size.width,900,accuracy:1);XCTAssertEqual(decoded.size.height,450,accuracy:1);XCTAssertLessThan(data.count,700000)
 var row=rE();row.species="Unit Photo";row.lure="Unit Spoon";row.photo=data
 let store=rV();XCTAssertTrue(store.put(row));let restored=try XCTUnwrap(rV().rows.first{$0.id==row.id});XCTAssertEqual(restored.photo,data);store.delete(row)
 }
 func revealLatitude(_ app:XCUIApplication) -> XCUIElement {
  let field=app.textFields["latitudeInput"]
  let hide=app.buttons["Hide keyboard"].firstMatch
  if hide.isHittable {hide.tap()}
  let form=app.collectionViews.containing(.textField,identifier:"speciesInput").firstMatch
  let area=form.exists ? form:app
  let start=area.coordinate(withNormalizedOffset:CGVector(dx:0.5,dy:0.68))
  let end=area.coordinate(withNormalizedOffset:CGVector(dx:0.5,dy:0.47))
  for _ in 0..<10 {
   if field.exists && field.isHittable {return field}
   start.press(forDuration:0.12,thenDragTo:end,withVelocity:.slow,thenHoldForDuration:0.1)
  }
  return field
 }
 func testB_JournalPersistsAndEdits()throws {
 let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)","-AppleLocale","en_US","--qa-reset"];app.launch();app.launchArguments=["-AppleLanguages","(en)","-AppleLocale","en_US"]
 let add=app.buttons["addCatch"];XCTAssertTrue(add.waitForExistence(timeout:15));shot("01-journal-empty")
 add.tap();let species=app.textFields["speciesInput"];XCTAssertTrue(species.waitForExistence(timeout:5));species.tap();species.typeText("QA Perch")
 let lure=app.textFields["lureInput"];lure.tap();lure.typeText("Copper spoon")
 let lat=revealLatitude(app)
 XCTAssertTrue(lat.exists);lat.tap();lat.typeText("51.5")
 let lon=app.textFields["longitudeInput"];lon.tap();lon.typeText("-0.1")
 app.buttons["saveEntry"].tap();XCTAssertTrue(app.buttons["catch-QA Perch"].waitForExistence(timeout:8));shot("02-journal-saved")
 app.terminate();app.launch();XCTAssertTrue(app.buttons["catch-QA Perch"].waitForExistence(timeout:10))
 app.buttons["catch-QA Perch"].firstMatch.tap();XCTAssertTrue(app.buttons["Edit"].waitForExistence(timeout:5));shot("03-catch-detail")
 app.buttons["Edit"].tap();XCTAssertTrue(app.textFields["speciesInput"].waitForExistence(timeout:5))
 let editedLatitude=revealLatitude(app)
 editedLatitude.tap();let oldLatitude=editedLatitude.value as? String ?? "51.5"
 editedLatitude.typeText(String(repeating:XCUIKeyboardKey.delete.rawValue,count:oldLatitude.count)+"52.5")
 app.buttons["saveEntry"].tap();XCTAssertTrue(app.staticTexts["52.50000, -0.10000"].waitForExistence(timeout:5));app.swipeUp();shot("03b-edited-location");app.buttons["Done"].tap()
 app.buttons["Activity"].firstMatch.tap();XCTAssertTrue(app.staticTexts["Patterns from your own water"].waitForExistence(timeout:5));shot("04-calendar-and-lures");app.swipeUp();XCTAssertTrue(app.staticTexts["Lure performance"].waitForExistence(timeout:5));shot("04b-lure-performance")
 app.buttons["Map"].firstMatch.tap();XCTAssertTrue(app.staticTexts["Your places, always available"].waitForExistence(timeout:5));shot("05-offline-map")
 app.buttons["Tools"].firstMatch.tap();XCTAssertTrue(app.buttons["Export journal as CSV"].waitForExistence(timeout:5));app.buttons["Export journal as CSV"].tap();shot("06-system-export");app.terminate()
 }
 func testC_LocalizationsAndWidgets()throws{
 let app=XCUIApplication()
 for (lang,label) in [("de","DEIN WASSER. DEINE GESCHICHTE."),("fr","VOS EAUX. VOTRE HISTOIRE."),("es","TUS AGUAS. TU HISTORIA.")] {
 app.launchArguments=["-AppleLanguages","(\(lang))","-AppleLocale",lang];app.launch();XCTAssertTrue(app.staticTexts[label].waitForExistence(timeout:10));shot("locale-\(lang)");app.terminate()
 }
 app.launchArguments=["-AppleLanguages","(en)","--widget-qa"];app.launch();XCTAssertTrue(app.staticTexts["Entries"].firstMatch.waitForExistence(timeout:10));shot("07-widget-families");app.swipeUp();shot("08-widget-large-lock");app.terminate()
 }
 func testD_DeleteEntry()throws {
 let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)"];app.launch()
 guard app.buttons["catch-QA Perch"].waitForExistence(timeout:10) else{return XCTFail("Saved entry is missing")}
 app.buttons["catch-QA Perch"].firstMatch.tap()
 for _ in 0..<4 {if app.buttons["Delete entry"].isHittable{break};app.swipeUp()}
 app.buttons["Delete entry"].tap();app.buttons.matching(identifier:"Delete entry").element(boundBy:app.buttons.matching(identifier:"Delete entry").count-1).tap()
 XCTAssertTrue(app.staticTexts["A journal worth keeping"].waitForExistence(timeout:5));app.terminate();app.launch();XCTAssertFalse(app.buttons["catch-QA Perch"].exists);app.terminate()
 }
 func testE_DeniedLocationStillSaves()throws {
 let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)"];app.launch();app.buttons["addCatch"].tap()
 let s=app.textFields["speciesInput"];s.tap();s.typeText("QA Quiet outing")
 let l=app.textFields["lureInput"];l.tap();l.typeText("Worm")
 app.swipeUp()
 let locate=app.buttons["Use current location"]
 if locate.waitForExistence(timeout:4){locate.tap();let deny=app.alerts.buttons["Don’t Allow"];let deny2=app.alerts.buttons["Don't Allow"];if deny.waitForExistence(timeout:4){deny.tap()}else if deny2.exists{deny2.tap()};if app.alerts.buttons["OK"].waitForExistence(timeout:3){app.alerts.buttons["OK"].tap()}}
 app.buttons["saveEntry"].tap();if app.alerts.buttons["OK"].waitForExistence(timeout:3){app.alerts.buttons["OK"].tap()};XCTAssertTrue(app.buttons["catch-QA Quiet outing"].waitForExistence(timeout:8));shot("09-manual-entry-after-denial");app.terminate()
 }
 func testF_AnnualReport()throws {
 let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)"];app.launch();app.buttons["Tools"].firstMatch.tap()
 let report=app.buttons["Share annual report"]
 for _ in 0..<3{if report.isHittable{break};app.swipeUp()}
 XCTAssertTrue(report.exists);report.tap();shot("10-annual-report-share");app.terminate()
 }
 @MainActor func testG_OnlineWeatherAndPopulatedWidgets()async throws {
 var request=URLRequest(url:URL(string:"https://api.open-meteo.com/v1/forecast?latitude=51.5&longitude=-0.1&hourly=temperature_2m&forecast_days=1")!);request.timeoutInterval=12
 do {let (_,response)=try await URLSession.shared.data(for:request);guard (response as? HTTPURLResponse)?.statusCode==200 else{throw URLError(.badServerResponse)}}catch{throw XCTSkip("Live weather service is unavailable from this simulator: \(error.localizedDescription)")}
 let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)"];app.launch()
 app.buttons["catch-QA Quiet outing"].firstMatch.tap();app.buttons["Edit"].tap()
 let latitude=app.textFields["latitudeInput"]
 for _ in 0..<3{if latitude.isHittable{break};app.swipeUp()}
 latitude.tap();latitude.typeText(String(repeating:XCUIKeyboardKey.delete.rawValue,count:(latitude.value as? String ?? "").count)+"51.5");let longitude=app.textFields["longitudeInput"];longitude.tap();longitude.typeText(String(repeating:XCUIKeyboardKey.delete.rawValue,count:(longitude.value as? String ?? "").count)+"-0.1")
 let online=app.switches["Fetch weather automatically"]
 for _ in 0..<4{if online.isHittable{break};app.swipeUp()}
 online.tap();app.buttons["saveEntry"].tap()
 for _ in 0..<30{if !app.buttons["saveEntry"].exists{break};try await Task.sleep(nanoseconds:1_000_000_000)}
 XCTAssertFalse(app.buttons["saveEntry"].exists);XCTAssertTrue(app.buttons["Done"].waitForExistence(timeout:5))
 if app.alerts.buttons["OK"].exists{app.alerts.buttons["OK"].tap()}
 let model=app.staticTexts.matching(NSPredicate(format:"label BEGINSWITH %@","Model weather")).firstMatch
 for _ in 0..<3{if model.isHittable{break};app.swipeUp()}
 XCTAssertTrue(model.waitForExistence(timeout:5));shot("11-live-weather-snapshot")
 app.buttons["Done"].tap();app.buttons["Tools"].firstMatch.tap();app.buttons["Export journal as CSV"].tap();app.terminate()
 app.launchArguments=["-AppleLanguages","(en)","--widget-qa"];app.launch();shot("12-populated-weather-widgets");app.swipeUp();shot("13-populated-season-widget");app.terminate()
 }
 func testH_UnsignedCloudFallback()throws {
 let app=XCUIApplication();app.launchArguments=["-AppleLanguages","(en)"];app.launch();app.buttons["Tools"].firstMatch.tap()
 let toggle=app.switches["Sync journal with iCloud"]
 for _ in 0..<6{if toggle.isHittable{break};app.swipeUp()}
 XCTAssertTrue(toggle.exists);toggle.tap()
 XCTAssertTrue(app.staticTexts["iCloud is unavailable in this build. Your journal stays on this device."].waitForExistence(timeout:5));shot("14-private-sync-local-fallback");toggle.tap();app.terminate()
 }
 func shot(_ name:String){let a=XCTAttachment(screenshot:XCUIApplication().screenshot());a.name=name;a.lifetime = .keepAlways;add(a)}
}
