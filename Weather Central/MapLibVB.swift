//
//  MapLibVB.swift
//  Almanac
//
//  Created by George Bauer on 1/28/18.
//  Copyright © 2018,2019 GeorgeBauer. All rights reserved.

//  Ver 1.2.4 4/16/2019 Refactor. Make HSIN, aTan2 internal.  Add documentation.
//      1.2.3 8/31/2018 Fix LLtext() so it will not return "83° 60.0'"
//      1.2.2 7/08/2018 change IsDaylite Error msgBox to Print "⛔️"
//      1.2.1 5/03/2018 change .trim() refs to trimmingCharacters(in: .whitespacesAndNewlines)
//      1.2.0 4/16/2018 move here from MyFuncs: formatLatLon, formatDistDir, degToCardinal
//      1.1.3 3/01/2018 Fix MonthToText, HourMin24 now truncates secs, Eliminate OpenFileGB, GetMyDocFolder, DateText
//      1.1.2 Fix LLtext

//TODO:- Testing: 100% isDaylite need more edge condition testing

import Foundation

//---------------- 15 Functions ---------------------

//------------ 4 Spherical Geometry -----------
//GreatCircAng  (fromLat, fromLon, toLat, toLon, dist)   A to B in degrees                       ??<-
//GreatCircDist (fromLat, fromLon, toLat, toLon)         in NM                                   ok<-
//atan2         (y, x)                              Arctan of y/x (4 quadrant)              ok
//HSIN          (x)                                 HyperSine                               ?? tested as part of dist
//---------------- 4 Lat/Lon ------------------
//DecodeDegMin  (a)                                 Convert "DD MM.MM SS.SS" to Double      ok
//LatText       (Deg, Optional Res = 1)             Lat to Text Ndd*mm.m                    ok
//LonText       (Deg, Optional Res = 1)             Lon to Text Edd*mm.m                    ok
//LLtext        (Deg, Optional Res = 1)             Lat/Lon to Text dd*mm.m                 ok
//---------------- 4 Date/Time ----------------
//DeCode3LetterMon(a)                               Convert "Jan","Feb",...  to  1,2,...    ok
//HourMin24     (hr, d)                             oH:MM where d=leading char 0," ",""     ok
//IsDayLite     (Mon, iDay, iYear) -> Bool          DST Check if Daylight Savings           ??<-
//MonthToText   (mon, Optional n = 0)               Mon  6 -> "June" (n chars long)         ok
//---------------- 3 Format -------------------
//Ljust         (text, N)                           Left  Justify into N-char field         ok
//RJust         (text, N)                           Right Justify into N-char field         ok
//NumSuffix     (n)                                 "st","nd","rd","th"                     ok
//------------------------------------------

//------------------------------------------------------------------------------------------------------------------------
// MARK:- Spherical Geometry (2 public funcs)

/// Return Great Circle Direction in Degrees between 2 points.
///
/// Replace!! Uses wrong sign for Lon
///
/// Requires "dist" in NM - calculated elsewhere
/// - Parameters:
///   - fromLat: from Latitude
///   - fromLon: from Longitude
///   - toLat:   to Latitude
///   - toLon:   to Longitude
///   - dist:    distance (NM)
/// - Returns: Direction (heading) in degrees
@available(*, deprecated, message: "Replace!! Uses wrong sign for Longitude")
public func GreatCircAng(_ fromLat: Double, _ fromLon: Double, _ toLat: Double, _ toLon: Double, _ dist: Double) -> Int {
    if dist == 0 { return 0 }

    let PA = (90.0 - fromLat) / 57.2958    // A lat expessed in rads: 0 at northPole, Pi at southPole
    let PB = (90.0 - toLat)   / 57.2958    // B lat expessed in rads: 0 at northPole, Pi at southPole
    //P# = (fromLon# - toLon#) / 57.2958#
    let AB = dist / 60.0 / 57.2958

    let HSA = (HSIN(PB) - HSIN(PA - AB)) / (sin(PA) * sin(AB))
    var ACOS = 1.0 - HSA - HSA
    if ACOS >  1.0 { ACOS =  1.0 }
    if ACOS < -1.0 { ACOS = -1.0 }
    let ATAN = sqrt(1.0 / (ACOS * ACOS) - 1.0)
    var ang = Int((atan(ATAN) * 57.2958).rounded())
    if toLat <  fromLat && toLon <  fromLon { ang = 180 - ang }
    if toLat <  fromLat && toLon >= fromLon { ang = 180 + ang }
    if toLat >= fromLat && toLon >= fromLon { ang = 360 - ang }
    return ang
}//end func GreatCircAng

// TODO: Needs more tests!
/// Return Great Circle Distance Point-A to Point-B in Nautical Miles.
///
/// - Parameters:
///   - fromLat: from Latitude
///   - fromLon: from Longitude
///   - toLat: to Latitude
///   - toLon: to Longitude
/// - Returns: distance (NM)
public func GreatCircDist(_ fromLat: Double, _ fromLon: Double, _ toLat: Double, _ toLon: Double) -> Double {
    //let radToDeg = 180.0 / 3.1415926       // 57.2958

    let PA = (90.0 - fromLat)  / 57.2958    // A lat expessed in rads: 0 at northPole, Pi at southPole
    let PB = (90.0 - toLat)    / 57.2958    // B lat expessed in rads: 0 at northPole, Pi at southPole
    let lonDifRad =  (fromLon - toLon) / 57.2958    // lon diff expressed in rads

    let HSAB = HSIN(lonDifRad) * sin(PA) * sin(PB) + HSIN(PA - PB)
    let ABCOS = 1.0 - HSAB - HSAB                                 // ABCOS = 1 - 2*HSAB
    let ABTAN = sqrt(1.0 / (ABCOS * ABCOS) - 1.0)
    return atan(ABTAN) * 57.2958 * 60.0
}//end func GreatCircDist

/// Return the arctan of dy/dx (0 to 2*pi).
internal func aTan2(_ dy: Double, _ dx: Double) -> Double {
    var theta: Double

    if abs(dx) < 0.00001 {
        if dy < 0 {
            theta = -.pi/2.0
        } else {
            theta = .pi/2.0
        }
    } else {
        theta = atan(dy / dx)
        if dx < 0  { theta = theta + .pi }
    }//endif

    if theta < 0.0 { theta = theta + .pi * 2.0 }
    return theta
}//end func atan2

///---- HSIN - HyperSine
private func HSIN(_ x: Double) -> Double {
    return (1.0 - cos(x)) / 2.0
}//end func

//------------------------------------------------------------------------------------------------------------------------
//MARK:- Lat/Lon (4 funcs)

/// Convert a "Ndd mm.mm" string into a Real number
///
/// North is positive, East is positive
/// - Parameter strDegMin: String like "N28 33.5"
/// - Returns: Double like 28.55
public func DecodeDegMin(_ strDegMin: String) -> Double {
    let errorVal = 0.0                          //??? Change to -999 for error detection
    var str = strDegMin.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if str.count < 2 { return errorVal }

    let a1 =  String(str.prefix(1))
    var multiplier = 1.0
    if "-NSEW".contains(a1){
        str = String(str.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        if a1 == "S" || a1 == "W"  || a1 == "-" { multiplier = -1.0 }
    }

    let separators = CharacterSet(charactersIn: " °\"'")            // space and chars for deg,min,sec as seperators
    let comps = str.components(separatedBy: separators)               // Separate the components
    let components = comps.filter { (x) -> Bool in !x.isEmpty }     // Use filter to eliminate empty strings.
    let nComponents = components.count

    let aDeg = components[0]
    let valDeg = Double(aDeg) ?? errorVal
    if nComponents < 2 { return multiplier * valDeg }               // 1 component  (deg)

    let aMin = components[1]
    guard let valMin = Double(aMin) else { return errorVal }
    if nComponents < 3 { return multiplier * (valDeg + valMin/60) } // 2 components (deg min)

    let aSec = components[2]
    guard let valSec = Double(aSec) else { return errorVal }
    return multiplier * (valDeg + valMin/60 + valSec/3600)          // 3 components (deg min sec)
}//end func DecodeDegMin

/// Convert Latitude Degrees into "NDD MM.Mmmm" or "SDD MM.Mmmm" format
///
/// - Parameters:
///   - deg: Latitude - degrees
///   - res: Decimal places in Minutes
/// - Returns: String
public func LatText(_ deg: Double, _ res: Int = 1) -> String {
    //Calls LLtest
    var str: String
    if deg < 0.0 {
        str = "S" + LLtext(deg, res)
    } else {
        str = "N" + LLtext(deg, res)
    }
    return str
}//end func LatText

/// LonText - Convert Numerical Deg into "EDD MM.Mmmm" or "WDD MM.Mmmm" format - Lon sign is correct
/// Convert Longitude Degrees into "EDD MM.Mmmm" or "WDD MM.Mmmm" format
///
/// - Parameters:
///   - deg: Latitude - degrees
///   - res: Decimal places in Minutes
/// - Returns: String
public func LonText(_ deg: Double, _ res: Int = 1) -> String {
    //Calls LLtest
    let str: String
    if deg < 0.0 {
        str = "W" + LLtext(deg, res)
    } else {
        str = "E" + LLtext(deg, res)
    }
    return str
}//end func

/// Convert dblDeg into "DD°MM.Mmmm" format
///
/// - Parameters:
///   - deg: Latitude - degrees
///   - res: Decimal places in Minutes
/// - Returns: String
public func LLtext(_ dblDeg: Double, _ res: Int = 1) -> String {
    let td = abs(dblDeg)
    let formater = NumberFormatter()
    formater.minimumIntegerDigits  = 2
    formater.minimumFractionDigits = res
    formater.maximumFractionDigits = res
    var intDeg = Int(td)
    let minutes = (td - Double(intDeg)) * 60.0
    var formattedMin = formater.string(from: minutes as NSNumber) ?? "??"      //????? Change to not use NumberFormatter
    if formattedMin.hasPrefix("60") {
        formattedMin = formater.string(from: 0.0 as NSNumber) ?? "??"
        intDeg += 1
    }
    return "\(intDeg)° \(formattedMin)'"
}//end func LLtext

//------------------------------------------------------------------------------------------------------------------------
//MARK:- Date/Time (4 funcs)

/// Make "hh:mm" from hr.  Truncates seconds.
///
/// - Parameters:
///   - hr:    Double
///   - char: fill char for hr 1-9 "0" or " ", defaults to none
/// - Returns: String like "9:23"
public func HourMin24(_ hr: Double, _ char: String = "") -> String {
    let iHour   = Int(hr)
    let iMin    = Int((hr - Double(iHour)) * 60.0)
    let strLeft = String("\(char)\(iHour)".suffix(2))
    let strRght = String("0\(iMin)".suffix(2))
    return strLeft + ":" + strRght
}//end func HourMin24

/// returns true if Daylight Savings Time in US on a particular Month,Day,Year (Fixed for post 2007 rules)
///
/// - Parameters:
///   - month: Int (if 0 use today's date)
///   - day:   Int
///   - year:  Int (2 or 4 digits)
/// - Returns: true if Daylight Savings Time in US
public func IsDayLite(_ month: Int, _ day: Int, _ year: Int) -> Bool {
    //iMonth=0 means "do it for today", Funtion then returns correct iMonth,iDay,iYear
    //2-digit iYear means 1980-2079; 4-digit iYear is returned
    var iMonth = month
    var iDay   = day
    var iYear  = year
    //------ Get correct date with 4-digit year -------
    if month == 0 {
        let unitFlags:Set<Calendar.Component> = [ .year, .month, .day, .hour, .minute, .second, .calendar, .timeZone]
        let dateComponents = Calendar.current.dateComponents(unitFlags, from: Date())
        iMonth = dateComponents.month ?? 0
        iDay   = dateComponents.day   ?? 0
        iYear  = dateComponents.year  ?? 0
    } else if iMonth <= 12 {
        if iYear < 80 {
            iYear = iYear + 2000
        } else if iYear < 100 {
            iYear = iYear + 1900
        }//endif
    } else {
        print("\n⛔️ IsDaylite could not translate the date \(iMonth)/\(iDay)/\(iYear)\n")
        return false
    }
    var dateComponents = DateComponents(calendar:Calendar.current, year: iYear, month: iMonth, day: iDay)
    //let valid = dateComponents.isValidDate
    guard let date = dateComponents.date else {
        print("\n⛔️ IsDaylite could not translate the date \(iMonth)/\(iDay)/\(iYear)\n")
        return false
    }
    let unitFlags:Set<Calendar.Component> = [ .year, .month, .day, .hour, .minute, .second, .calendar, .timeZone, .weekday]
    dateComponents = Calendar.current.dateComponents(unitFlags, from: date)
    guard let weekday = dateComponents.weekday else {
        print("\n⛔️ IsDaylite could not translate the date \(iMonth)/\(iDay)/\(iYear)\n")
        return false
    }
    let dayofWeek = weekday - 1
    //let dayofWeek = Weekday(CDate(iMonth, iDay, iYear)) - 1

    if iYear < 2007 {       //************ old rules up to 2007
        if iMonth > 4 && iMonth < 10 {
            return true                         // 5,6,7,8,9
        } else if iMonth < 4 || iMonth > 10 {
            return false                        // 1,2,3, 11,12
        }//endif

        // Starts first Sunday of Apr
        if iMonth == 4 && iDay - dayofWeek > 0   { return true }
        // Ends last Sunday of Oct
        if iMonth == 10 && iDay - dayofWeek < 25 { return true }

    } else {                //************ new rules starting 2007
        if iMonth > 3 && iMonth < 11 {
            return true                         // 4,5,6,7,8,9,10
        } else if iMonth < 3 || iMonth > 11 {
            return false                        // 1,2, 12
        }//endif

        // Starts 2nd Sunday of March
        if iMonth == 3 {
            if iDay - dayofWeek > 7  { return true }
        } else if iMonth == 11 {
            // Ends 1st Sunday of November
            if iDay - dayofWeek <= 0 { return true }
        }
    }
    return false
}//end func IsDayLite

/// Converts "Jan" to 1, etc.
///
/// If 1st 3 chars don't match: return 0
public func DeCode3LetterMon(_ strMon: String) -> Int {
    if strMon.count >= 3 {
        switch strMon.prefix(3).uppercased() {
        case "JAN":
            return 1
        case "FEB":
            return 2
        case "MAR":
            return 3
        case "APR":
            return 4
        case "MAY":
            return 5
        case "JUN":
            return 6
        case "JUL":
            return 7
        case "AUG":
            return 8
        case "SEP":
            return 9
        case "OCT":
            return 10
        case "NOV":
            return 11
        case "DEC":
            return 12
        default:
            return 0
        }//end Select
    }//endif
    return 0
}//end func DeCode3LetterMon

/// Convert Month# to text (n letters long)
///
/// If length=0: use actual length.
///
///If length=4: put period at end of most.
///
/// Jan, Jan., Janu, Janua
///
/// - Parameters:
///   - month: Numerical Month
///   - length: Number of Characters in output (up to 9)
/// - Returns: String
public func MonthToText(_ month: Int, _ length: Int = 0) -> String {
    var name: String

    switch month {
    case 1:
        name = "January  "
    case 2:
        name = "February "
    case 3:
        name = "March    "
    case 4:
        name = "April    "
    case 5:
        name = "May      "
    case 6:
        name = "June     "
    case 7:
        name = "July     "
    case 8:
        name = "August   "
    case 9:
        name = "September"
    case 10:
        name = "October  "
    case 11:
        name = "November "
    case 12:
        name = "December "
    default:
        name = "?\(month)?"
    }//end Select
    if length > 0 {
        if length == 4 {                     // n = 4
            switch month {
            case 5,6,7,9:
                name = name.left(4)
            default:
                name = name.left(3) + "."
            }
        } else {
            name = String(name.prefix(length))        // n = 1,2,3,  5,6,7,...
        }//endif
    } else {
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)              // n <= 0
    }//endif
    return name
}//end func MonthToText

//------------------------------------------------------------------------------------------------------------------------
//MARK:- Formatting (3 funcs)

/// Left Justify text into a field, truncating if necessary.
public func LJust(_ text: String, _ fieldLen: Int) -> String {
    let str: String
    if fieldLen > text.count {
        str = text + String(repeating: " ", count: fieldLen - text.count)
    } else {
        str = String(text.prefix(fieldLen))
    }
    return str
}//end func

/// Right Justify text into an n spaced field, truncating if necessary.
public func RJust(_ text: String, _ fieldLen: Int) -> String {
    let str: String
    if text.count < fieldLen {
        str = String(repeating: " ", count: fieldLen - text.count) + text
    } else {
        str = String(text.prefix(fieldLen))
    }
    return str
}//end func

/// Return the ordinal suffix (st,nd,rd,th) for an Int.
public func NumSuffix(_ num: Int) -> String {
    let lastDigit = num % 10        // lastDigit= last digit (1,2,3, etc)

    if lastDigit >= 1 && lastDigit <= 3 {       // 1st 2nd 3rd
        let last2 = num % 100                   // last2 = last 2 digits (12,13,14, etc)
        if last2 < 11 || last2 > 13 {           // Not 11th, 12th, or 13th
            switch lastDigit {
            case 1:
                return "st"         //1st but not 11th
            case 2:
                return "nd"         //2nd but not 12th
            default:
                return "rd"         //3rd but nor 13th
            }//end switch
        }//endif
    }//endif
    return "th"
}//end func NumSuffix

//=========================================================================================

//MARK:- Format Lat/Lon, dist/Dir (3 funcs)

/// Format lat/lon to e.g. "N28.51° W081.55°"
///
/// North & East are positive numbers
/// - Parameters:
///   - lat: latitude (degrees)
///   - lon: longitude (degrees)
///   - places: decimal places
/// - Returns: String  e.g. "N28.51° W081.55°"
public func formatLatLon(lat: Double, lon: Double, places: Int) -> String {
    var ns = "N"
    var myLat = lat
    if lat < 0 {
        myLat = -myLat
        ns = "S"
    }
    let fieldLenLat = places + 3
    var latStr = formatDbl(number: myLat,fieldLen: fieldLenLat , places: places)
    latStr = latStr.replacingOccurrences(of: " ", with: "0")
    latStr = ns + latStr + "°"

    var ew = "E"
    var myLon = lon
    if lon < 0 {
        myLon = -myLon
        ew = "W"
    }
    let fieldLenLon = places + 4
    var lonStr = formatDbl(number: myLon, fieldLen: fieldLenLon, places: places)
    lonStr = lonStr.replacingOccurrences(of: " ", with: "0")
    lonStr = ew + lonStr + "°"

    return latStr + " " + lonStr
}

/// From a pair of Lat/Lon's, return distance(mi or nm), direction, cardinal direction , and string e.g."14.2mi NNW"
///
/// - Parameters:
///   - latFrom: from Latitude
///   - lonFrom: from Longitude
///   - latTo:   to Latitude
///   - lonTo:   to Longitude
///   - doMi:    true -> miles, false -> NM
///   - doDeg:   true -> degrees, false -> compass points
/// - Returns:   tuple (dist, dirDeg, dirCard, distDirStr)
public func formatDistDir(latFrom: Double, lonFrom: Double, latTo: Double, lonTo: Double,
                           doMi: Bool = true, doDeg: Bool = false)
    -> (dist: Double, deg: Int, cardinal: String, strDistDir: String) {
        var abrev = "nm"
        let distNM = GreatCircDist( latFrom, lonFrom, latTo, lonTo)
        var dist = distNM
        if doMi {
            dist = distNM * 1.15
            abrev = "mi"
        }
        let dirDeg = GreatCircAng( latFrom, lonFrom, latTo, lonTo, distNM)
        let dirCard = degToCardinal(deg: dirDeg, points: 16)
        var dirStr = dirCard
        if doDeg {
            dirStr = "\(dirDeg)°"
        }
        let distStr: String
        if dist < 99 {
            distStr = formatDbl(number: dist, fieldLen: 5, places: 1)
        } else {
            distStr = formatDbl(number: dist, fieldLen: 5, places: 0)
        }

        let distDirStr = "\(distStr)\(abrev) \(dirStr)"
        return (dist, dirDeg, dirCard, distDirStr)
}

/// Return cardinal point (e.g. "NNW") from compass degrees.
///
/// Uses a 4, 8, or 16 point system.
/// - Parameters:
///   - deg: Dierction in degrees
///   - points: Number of cardinal points (4, 8, 16)
/// - Returns: String
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
    }
    return "?"
}


