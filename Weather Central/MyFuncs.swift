//
//  MyFuncs.swift
//  Weather Central
//
//  Created by George Bauer on 9/29/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//  Ver 1.1.1   2/16/2018
//  ------ General Purpose Subroutines ------
import Foundation

//MARK: General Purpose 

//---- Format Double "%#.#f" using fieldLen, places. fieldLen!=0 to right justify - Truncates ----
public func formatDbl(number: Double, fieldLen: Int = 0, places: Int) -> String {
    if fieldLen == 0 {
        return String(format:"%.\(places)f", number)                            //String(format:%.2f",number)
    } else {
        return String(format:"%\(fieldLen).\(places)f", number).left(fieldLen)  //String(format:%6.2f",number)
    }
}

//---- Format Int using fieldLen ----
public func formatInt(number: Int, fieldLen: Int) -> String {
    let str =  String(number)
    return str.rightJust(fieldLen)
}

//---- Format a String number "%#.#f" using fieldLen & places. fieldLen=0 to remove leading spaces ----
//public func formatDbl(text: String, fieldLen: Int = 0, places: Int) -> String {
//    guard var dbl = Double(text) else {return text}
//    dbl = roundToPlaces(number: dbl, places: places)
//    var w = fieldLen
//    if fieldLen == 0 { w = text.count + places + 2 }
//    let format = "%\(w).\(places)f"
//    var t = String(format:format, dbl)              //String(format:"Alt %5.0f ft",gpsAlt)
//    if fieldLen == 0 { t = t.trimmingCharacters(in: .whitespaces) }
//    return t
//}

// ------ Make Time String "17:02" or " 5:02pm" from "17","2" ------
public func makeTimeStr(hrStr: String, minStr: String, to24: Bool) -> String {
    guard let h24 = Int(hrStr) else { return "?" + hrStr + ":" + minStr + "?" }
    let mm = minStr.count < 2 ? "0" + minStr : minStr
    if to24 {
        let hh = hrStr.count < 2 ? "0" + hrStr : hrStr
        return hh + ":" + mm
    }

    var h12: Int
    var ampm = "am"
    switch h24 {
    case  0 :
        h12 = 12
    case 1...11 :
        h12 = h24
    case 12 :
        h12 = h24
        ampm = "pm"
    default:
        h12 = h24 - 12
        ampm = "pm"
    }
    let hh12 = h12 < 10 ? " \(h12)" : "\(h12)"
    return hh12 + ":" + mm + ampm
}

//---- Rounds "number" to a number of decimal "places" e.g. (3.1426, 2) -> 3.14 ----
//public func roundToPlaces(number: Double, places: Int) -> Double {
//    let divisor = pow(10.0, Double(places))
//    return (number * divisor).rounded() / divisor
//}

//---- Format an integer with leading zeros e.g. (5, 3) -> "005" ----
//public func formatIntWithLeadingZeros(_ num: Int, width: Int) -> String {
//    var a = String(num)
//    while a.count < width {
//        a = "0" + a
//    }
//    return a
//}

// ------------- returns e.g. "1 name", "2 names", "No names" -----------
public func showCount(count: Int, name: String, ifZero: String = "0") -> String {
    if count == 1 { return "1 \(name)" }
    if count == 0 {
        return "\(ifZero) \(name.pluralize(count))"
    }
    return "\(count) \(name.pluralize(count))"
}

// ---- Test if a String is a valid Integer ---
public func isStringAnInt(_ string: String) -> Bool {
    return Int(string) != nil
}
public func isStringAnInt(_ char: Character) -> Bool {
    return Int(String(char)) != nil
}

// ---- Test if a String is a valid Number ---
public func isNumeric(_ string: String) -> Bool {
    return Double(string) != nil
}

//MARK: Dictionaries
// =================== for Printing Dictionaries =====================
public func formatDictionaryAny(title: String, obj: AnyObject, decimalPlace: Int = 1, titleLen: Int = 10, fillStr: String = ".") -> String {
    var str = "???"
    if obj is String {
        str = obj as! String
    } else if obj is Double {
        let num = obj as! Double
        str = String(num)
    }
    return formatDictionaryStr(title: title, str: str, titleLen: titleLen, fillStr: fillStr)
}

public func formatDictionaryDbl(title: String, num: Double, decimalPlace: Int = 1, titleLen: Int = 10, fillStr: String = ".") -> String {
    let str = String(num)
    return formatDictionaryStr(title: title, str: str, titleLen: titleLen, fillStr: fillStr)
}

public func formatDictionaryInt(title: String, num: Int, titleLen: Int = 10, fillStr: String = ".") -> String {
    let str = String(num)
    return formatDictionaryStr(title: title, str: str, titleLen: titleLen, fillStr: fillStr)
}

public func formatDictionaryStr(title: String, str: String, titleLen: Int = 10, fillStr: String = ".") -> String {
    if title == "" {
        return "\(str)"
    }
    var nSpace = titleLen - title.count + 2
    if nSpace < 0 { nSpace = 0 }
    let space = String(repeating: fillStr, count: nSpace)
    return "\(title) \(space) \(str)"
}

//=========================================================================================
public func printDictionary(dict: [String: AnyObject]?, expandLevels: Int, dashLen: Int, title: String) {
    guard let d = dict else { print("\n\(title) is nil!"); return }
    let dictNS = d as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionary(dict: [String: AnyObject], expandLevels: Int, dashLen: Int, title: String) {
        let dictNS = dict as NSDictionary
        printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
        return
    }

//=========================================================================================
public func printDictionaryNS(dictNS: NSDictionary,expandLevels: Int, dashLen: Int, title: String) {
    var length = dashLen
    var type = "base"
    if expandLevels > 0 { type = "expanded" }
    print("========================== \(title) \(type) ===========================")
    
    if expandLevels == 0 {
        var isFirst = true
        var a1 = ""
        if length < 2 { length = 22 }
        for (key, value) in dictNS {
            if !isFirst { a1 += "\n" }
            isFirst = false
            var str2 = "????"
            let str1 = String(describing: key)
            if var str0 = value as? String {
                str0 = str0.replacingOccurrences(of: "\n", with: " ")
                var s: NSString = str0 as NSString
                if s.length > 60 {
                    s = s.substring(to: 59) as NSString
                    s = s.appending("...") as NSString
                }
                str2 = "\"" + (s as String) + "\""
                //} else if let db = value as? Int {
                //    str2 = String(db)
            } else if let db = value as? Double {
                str2 = String(db)
            } else if value is NSArray {
                let n = (value as! NSArray).count
                str2 = "(Array) with \(n) " + "item".pluralize(n)
            } else if value is NSDictionary {
                let n = (value as! NSDictionary).count
                str2 = "{Dictionary} with \(n) " + "item".pluralize(n)
            }
            a1 += str1 + getDashes(key: str1, length: length) + "> " + str2
        }// next
        print(a1)
        
    } else {
        if length < 2 { length = 14 }
        for (key, value) in dictNS {
            //print("\(key) --> \(value) ")
            let sKey = key as! String
            print(sKey + getDashes(key: sKey, length: length) + ">", value)
        }//next
    }
    print("======================== end \(title) \(type) =========================\n")
    if expandLevels > 0 { print() }
}

// Helper for printDictionaryNS
func getDashes(key: String, length: Int) -> String {
    let dashes: NSString = " ---------------------------------"
    var i = length - key.count
    if i < 2 { i = 2 }
    if i > dashes.length { i = dashes.length }
    return dashes.substring(to: i)
}

//=========================================================================================

//MARK: Great Circle Distance & Direction
//Returns Angle (heading) from A to B.  Needs Distance to be calculated 1st, and used as input.
func greatCircAng(ALat: Double, ALon: Double, BLat: Double, BLon: Double, Dist: Double) -> Int {
    if Dist == 0 { return 0 }
    let degPerRad = 57.2958
    let PA = (90.0 - ALat) / degPerRad
    let PB = (90.0 - BLat) / degPerRad
    let AB = Dist /  60.0  / degPerRad
    
    let HSA = (hSin(PB) - hSin(PA - AB)) / (sin(PA) * sin(AB))
    
    var ACOS = 1.0 - HSA - HSA
    if ACOS > 1.0 { ACOS = 1.0}
    if ACOS < -1.0 { ACOS = -1.0}
    let ABTAN = sqrt(1.0 / (ACOS * ACOS) - 1.0)
    
    var iDeg = Int(atan(ABTAN) * degPerRad)
    if BLat <  ALat && BLon >  ALon { iDeg = 180 - iDeg}
    if BLat <  ALat && BLon <= ALon { iDeg = 180 + iDeg}
    if BLat >= ALat && BLon <= ALon { iDeg = 360 - iDeg}
    return iDeg
    
}//End func GreatCircAng


//GREAT-CIRCLE DISTANCE in NM Point-A Lat/Lon to Point-B Lat/Lon
public func greatCircDist(ALat: Double, ALon: Double, BLat: Double, BLon: Double) -> Double {
    let degPerRad = 57.2958
    let PA = (90.0 - ALat) / degPerRad
    let PB = (90.0 - BLat) / degPerRad
    let P  = (ALon - BLon) / degPerRad
    
    let HSAB = hSin(P) * sin(PA) * sin(PB) + hSin(PA - PB)
    let ABCOS = 1.0 - HSAB - HSAB                           //AB_COS = 1 - 2 * HS_AB
    let ABTAN = sqrt(1.0 / (ABCOS * ABCOS) - 1.0)
    return atan(ABTAN) * degPerRad * 60.0
}//End func

// HyperSine
func hSin(_ ang: Double) -> Double {
    return (1.0 - cos(ang)) / 2.0
}//End func

// format lat/lon to e.g. "N28.51° W081.55°"
public func formatLatLon(lat: Double, lon: Double, places: Int) -> String {
    var ns = "N"
    var alat = lat
    if lat < 0 {
        alat = -alat
        ns = "S"
    }
    let fieldLenLat = places + 3
    var latStr = formatDbl(number: alat,fieldLen: fieldLenLat , places: places)
    latStr = latStr.replacingOccurrences(of: " ", with: "0")
    latStr = ns + latStr + "°"
    
    var ew = "E"
    var alon = lon
    if lon < 0 {
        alon = -alon
        ew = "W"
    }
    let fieldLenLon = places + 4
    var lonStr = formatDbl(number: alon,fieldLen: fieldLenLon, places: places)
    lonStr = lonStr.replacingOccurrences(of: " ", with: "0")
    lonStr = ew + lonStr + "°"
    
    return latStr + " " + lonStr
}

// From a pair of Lat/Lon's, return distance(mi or nm), direction, cardinal direction , and string e.g."14.2mi NNW"
public func formatDistDir(latFrom: Double, lonFrom: Double, latTo: Double, lonTo: Double,
                          doMi: Bool = true, doDeg: Bool = false)
                            -> (dist: Double, deg: Int, cardinal: String, strDistDir: String) {
        var distStr = "     "
        var abrev = "nm"
        let distNM = greatCircDist(ALat: latFrom, ALon: lonFrom, BLat: latTo, BLon: lonTo)
        var dist = distNM
        if doMi {
            dist = distNM * 1.15
            abrev = "mi"
        }
        let dirDeg = greatCircAng(ALat: latFrom, ALon: lonFrom, BLat: latTo, BLon: lonTo, Dist: distNM)
        let dirCard = degToCardinal(deg: dirDeg, points: 16)
        var dirStr = dirCard
        if doDeg {
            dirStr = "\(dirDeg)°"
        }
        if dist < 99 {
            distStr = formatDbl(number: dist, fieldLen: 5, places: 1)
        } else {
            distStr = formatDbl(number: dist, fieldLen: 5, places: 0)
        }
        
        let distDirStr = "\(distStr)\(abrev) \(dirStr)"
        return (dist, dirDeg, dirCard, distDirStr)
}

// Return cardinal point (e.g. "NNW") from compass degrees. Use a 4, 8, or 16 point system.
public func degToCardinal(deg: Int, points: Int = 8) -> String {
    let cardinals1 = ["N",      "E",      "S",      "W",      "N"]
    let cardinals2 = ["N ","NE","E ","SE","S ","SW","W ","NW","N "]
    let cardinals3 = ["N  ","NNE","NE ","ENE","E  ","ESE","SE ","SSE","S  ","SSW","SW ","WSW","W  ","WNW","NW ","NNW","N  "]
    if points == 4 {
        return cardinals1[(deg + 45)/90]
    } else if points == 8 {
        return cardinals2[(deg + 22)/45]
    } else if points == 16 {
        return cardinals3[(deg * 10 + 112)/225]
    } else {
        return "?"
    }
}


/**/
