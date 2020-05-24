//
//  MyFuncs.swift
//  TestSharedCode
//
//  Created by George Bauer on 9/29/17.
//  Copyright © 2017-2019 GeorgeBauer. All rights reserved.

//  Ver 1.6.5   4/23/2019   Replace formatInt(number:, fieldLen:) with formatInt(_:, wid:)
//      1.6.4   4/12/2019   Remove forced-unwraps. Add documentation.
//      1.6.3   3/08/2019   getFileInfo: Change url param to Optional, Add func getContentsOf(dirURL: URL)
//      1.6.2   8/16/2018   Add: getContentsOf(directoryStr), getFileInfo(_ str), getFileInfo(url)
//      1.6.1   7/11/2018   Fix isNumeric for leading/trailing whitespace
//      1.6.0   6/16/2018   Add matches(for regex: String, in text: String) & isMatch(for regex: String, in text: String)
//      1.5.3   5/14/2018   Fix replaceInString
//      1.5.2   5/13/2018   Add replaceCharInString, replaceInString
//      1.5.1   5/02/2018   Add Date stuff isSameDay() timeDiffSecs()
//      1.5.0   4/22/2018   Add printDictionary(dict: [String: String],...), [String: Double], [String: Int], default:expandLevels=0,dashLen=0(auto)
//      1.4.0   4/19/2018   Add Date extensions (from VBCompatability)
//      1.3.0   4/16/2018   Move GreatCircAng, GreatCircDist, formatLatLon, formatDistDir, degToCardinal to MapLibVB
//      1.2.1   4/09/2018   Add printDictionary(dict: [String: Date], ...
//      1.2.0   3/09/2018   Add File handling funcs, formatDbl(num,places), isCharDigit
//  ------ General Purpose Subroutines ------

//TODO:- Testing: 100%
// printDictionary Dictionary not NSDictionary, Array not NSArray
// Improve test for FileAttributes.getFileInfo
// Rename matches & isMatch.
// Eliminate force-unwrap in matches

import Foundation

//MARK:- General Purpose 

//---- Format Double "%#.#f" using fieldLen, places. ----
///Format Double "%#.#f"
/// - Parameters:
///     - number: (Dbl) - number to be formatted
///     - places: (Int) - number of fractional digits
/// - Returns: String
public func formatDbl(_ number: Double, _ places: Int) -> String {
    return String(format:"%.\(places)f", number)                            //String(format:%.2f",number)
}

//---- Format Double "%#.#f" using fieldLen, places. fieldLen!=0 to right justify - Truncates ----
///Format Double "%#.#f" for a fixed field length (Monospaced font)
/// - Parameters:
///     - number:   (Dbl) - number to be formatted
///     - fieldLen: (Int) - length in characters to be filled
///     - places:   (Int) - number of fractional digits
/// - Returns: Right-justified truncated String
public func formatDbl(number: Double, fieldLen: Int = 0, places: Int) -> String {
    let str: String
    if fieldLen <= 0 {
        str = String(format:"%.\(places)f", number)                            //String(format:%.2f",number)
    } else {
        str = String(format:"%\(fieldLen).\(places)f", number).left(fieldLen)  //String(format:%6.2f",number)
    }
    return str
}

//---- Format Int using fieldLen ----
///Format Int for a fixed field length (Monospaced font)
/// - Parameters:
///     - number:   (Int) - number to be formatted
///     - fieldLen: (Int) - length in characters to be filled
/// - Returns: Right-justified truncated String
@available(*, deprecated, message: "Use formatInt(_,wid) instead")
public func formatInt(number: Int, fieldLen: Int) -> String {
    let str =  String(number)
    return str.rightJust(fieldLen)
}

//---- Format Int using field length ----
///Format Int for a fixed field length (Monospaced font)
/// - Parameters:
///     - number: (Int) - number to be formatted
///     - wid:    (Int) - length in characters to be filled
/// - Returns:    Right-justified truncated String
public func formatInt(_ number: Int, wid: Int) -> String {
    let str = String(number)
    return str.rightJust(wid)
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

//---- makeTimeStr ----
/// Make Time String "17:02" or " 5:02pm" from "17", "2"
/// - Parameters:
///     - hrStr:  (String) - hours
///     - minStr: (String) - minutes
///     - to24:   (Bool)   - true for 24-hr clock
/// - Returns: String
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
// USE INSTEAD: print(String(format: "%.3f", totalWorkTimeInHours))
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

//---- showCount ----
/// returns e.g. "1 name", "2 names", "No names"
/// - Parameters:
///     - count: (Int) - number of items
///     - name: (String) - name of item
///     - ifZero: (String) - optional substitute for "0"
/// - Returns: String
public func showCount(count: Int, name: String, ifZero: String = "0") -> String {
    if count == 1 { return "1 \(name)" }
    if count == 0 {
        return "\(ifZero) \(name.pluralize(count))"
    }
    return "\(count) \(name.pluralize(count))"
}

// ---- Test if a String is a valid Integer ---
/// true if String converts to Int

/// Not really needed, as optional unwrapping is required anyway
/// - Parameter string: The String to be tested.
/// - Returns: Bool
public func isStringAnInt(_ string: String) -> Bool {
    return Int(string) != nil
}

// ---- Test if a Character is a valid Digit ---
/// true if Character is a digit
///
/// Replace with char.isWholeNumber
/// - Parameter Character: The Character to be tested.
/// - Returns: Bool
public func isCharDigit(_ char: Character) -> Bool {
    return char.isWholeNumber
}

// ---- Test if a String is a valid Number ---
/// true if String converts to Double
/// - Parameter string: The String to be tested.
/// - Returns: Bool
public func isNumeric(_ string: String) -> Bool {
    return Double(string.trimmingCharacters(in: .whitespaces)) != nil
}

// ---- replaceCharInString ----
/// Return a String with a single Character changed
/// - Parameter string: The original String
/// - Parameter pos: Int index of the Character to be replaced
/// - Parameter newChar: The replacement Character
/// - Returns: String
public func replaceCharInString(string: String, pos: Int, newChar: Character) -> String {
    let newString = String(string.prefix(pos)) + String(newChar) + string.dropFirst(pos + 1)
    return newString
}

// ---- replaceCharInString ----
/// Return a String with a group of Characters replaced
/// - Parameter string: The original String
/// - Parameter strToInsert: The replacement String
/// - Parameter from: Beginning Int index of String to be replaced
/// - Parameter length:The length of String to be replaced
/// - Returns: String
public func replaceInString(string: String, strToInsert: String, from: Int, length: Int) -> String {
    let newStr = String(string.prefix(from)) + strToInsert + string.suffix(string.count - length - from)
    return newStr
}

// MARK:- Date Handling

// ---- isSameDay ----
/// Returns true if the date portion of 2 Dates is the same
/// - Parameter date1: The first Date
/// - Parameter date2: The second Date
/// - Returns: Bool
public func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
    let dateC1 = date1.getComponents()
    let dateC2 = date2.getComponents()
    let sameDay = dateC1.day == dateC2.day && dateC1.month == dateC2.month && dateC1.year == dateC2.year
    return sameDay
}

/// Calculate time dif between 2 Dates in secs. Negative if Date2 < Date1
/// - Parameter date1: The first Date
/// - Parameter date2: The second Date
/// - Returns: Difference in seconds
public func timeDiffSecs(date1: Date, date2: Date) -> Double {
    let difference = date2.timeIntervalSince(date1)
    return difference
}

// MARK:- File Handling

//---- fileExists -
///Determine if a file exists
/// - Parameter url: file URL
/// - Returns:  true if exists
public func fileExists(url: URL) -> Bool {
    let fileExists = FileManager.default.fileExists(atPath: url.path)
    return fileExists
}

//---- folderExists -
///Determine if a folder exists
/// - Parameter url: folder URL
/// - Returns:  true if exists
public func folderExists(url: URL) -> Bool {
    var isDirectory: ObjCBool = false
    let folderExists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    return folderExists
}

//---- getContentsOf(directoryStr:)
///Get filePaths for Contents Of DirectoryPath
/// - Parameter directoryStr: DirectoryPath (String))
/// - Returns:  Array of filePaths
func getContentsOf(directoryStr: String) -> [String] {
    let url = URL(fileURLWithPath: directoryStr)
    do {
        let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options:  [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        let filePaths = urls.map{ return $0.path}
        return filePaths
    } catch {
        return []
    }
}

//------ getContentsOf(directoryURL:)
///Get URLs for Contents Of DirectoryURL
/// - Parameter dirURL: DirectoryURL (URL)
/// - Returns:  Array of URLs
func getContentsOf(dirURL: URL) -> [URL] {
    do {
        let urls = try FileManager.default.contentsOfDirectory(at: dirURL, includingPropertiesForKeys: [], options:  [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        return urls
    } catch {
        return []
    }
}

//????? incorporate both getFileInfo() funcs into struct as inits
public struct FileAttributes: Equatable {
    let url:            URL?
    var name        = "????"
    var creationDate:     Date?
    var modificationDate: Date?
    var size        = 0
    var isDir       = false
    
    //------ getFileInfo - returns attributes of fileName (file or folder) as a FileAttributes struct
    ///Get file info for a file path
    /// - Parameter str: file path
    /// - Returns:  FileAttributes instance
    static func getFileInfo(_ str: String) -> FileAttributes {
        let url = URL(fileURLWithPath: str)
        return getFileInfo(url: url)
    }

    //------ getFileInfo - returns attributes of url (file or folder) as a FileAttributes struct
    ///Get file info for a URL
    /// - Parameter url: file URL
    /// - Returns:  FileAttributes instance
    static func getFileInfo(url: URL?) -> FileAttributes {
        if let url = url {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                let name             = url.lastPathComponent
                let creationDate     = attributes[FileAttributeKey(rawValue: "NSFileCreationDate")]     as? Date
                let modificationDate = attributes[FileAttributeKey(rawValue: "NSFileModificationDate")] as? Date
                let size             = attributes[FileAttributeKey(rawValue: "NSFileSize")]             as? Int ?? 0
                let fileType         = attributes[FileAttributeKey(rawValue: "NSFileType")] as? String
                let isDir            = (fileType?.contains("Dir")) ?? false
                return FileAttributes(url: url, name: name, creationDate: creationDate, modificationDate: modificationDate, size: size, isDir: isDir)
            } catch {   // FileManager error
                return FileAttributes(url: nil, name: "???", creationDate: nil, modificationDate: nil, size: 0, isDir: false)
            }
        } else {   // url = nil
            return FileAttributes(url: nil, name: "???", creationDate: nil, modificationDate: nil, size: 0, isDir: false)
        }
    }
}// end struct FileAttributes


// MARK:---- Regular Expression (RegEx) ----
//TODO: Error Handling, Rename to: getRegexMatches, isRegexMatch
//---- Regular Expressions Matches ----
///Gets an array of RegEx matching stings
///- parameter regex: The RegEx pattern used in the search
///- parameter text: The String to be searched
///- Returns: Array of Strings
func matches(for regex: String, in text: String) -> [String] {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
        let finalResult = results.map {
            String(text[Range($0.range, in: text) ?? text.startIndex..<text.endIndex])
        }
        return finalResult
    } catch let error {
        print("⛔️invalid regex: \"\(regex)\" \(error.localizedDescription)")
        return []
    }
}

//---- Regular Expressions Matches ----
///returns true if a RegEx matching pattern is found in the text
///- parameter regex: The RegEx pattern used in the search
///- parameter text: The String to be searched
func isMatch(for regex: String, in text: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let result = regex.firstMatch(in: text, options: [], range: NSRange(text.startIndex..., in: text))
        return result != nil
    } catch let error {
        print("⛔️invalid regex: \"\(regex)\" \(error.localizedDescription)")
        return false
    }
}

// MARK:- Printing Dictionaries
// =================== for Printing Dictionaries =====================
public func formatDictionaryAny(title: String, obj: AnyObject, decimalPlace: Int = 1, titleLen: Int = 10, fillStr: String = ".") -> String {
    var str = "???"
    if obj is String {
        str = obj as? String ?? "???"
    } else if obj is Double {
        let num = obj as? Double ?? 0.0
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
    var nFill = titleLen - title.count + 2
    if nFill < 0 { nFill = 0 }
    let fill = String(repeating: fillStr, count: nFill)
    return "\(title) \(fill) \(str)"
}

//=========================================================================================
public func printDictionary(dict: [String: AnyObject]?, expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    guard let dic = dict else { print("\n\(title) is nil!"); return }
    let dictNS = dic as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionary(dict: [String: AnyObject], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
        let dictNS = dict as NSDictionary
        printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
        return
    }

//=========================================================================================
public func printDictionary(dict: [String: String], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    let dictNS = dict as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionary(dict: [String: Int], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    let dictNS = dict as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionary(dict: [String: Double], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    let dictNS = dict as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionary(dict: [String: Date], expandLevels: Int = 0, dashLen: Int = 0, title: String) {
    let dictNS = dict as NSDictionary
    printDictionaryNS(dictNS: dictNS, expandLevels: expandLevels, dashLen: dashLen, title: title)
    return
}

//=========================================================================================
public func printDictionaryNS(dictNS: NSDictionary,expandLevels: Int, dashLen: Int, title: String) {
    var length = dashLen
    let type = expandLevels > 0 ? "expanded": "base"
    print("========================== \(title) \(type) ===========================")
    
    if expandLevels == 0 {
        if length == 0 {        // Automatic Length calculation
            for (key, _) in dictNS {
                let keyLen = String(describing: key).count + 1
                if keyLen > length { length = keyLen }
            }
        }
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
                var str3 = str0
                if str3.count > 60 {
                    str3 = str3.prefix(59).appending("...")
                }
                str2 = "\"" + (str3 as String) + "\""
                //} else if let db = value as? Int {
                //    str2 = String(db)
            } else if let db = value as? Double {
                str2 = String(db)
            } else if let db = value as? Date {
                str2 = db.ToString("MM/dd/yyyy hh:mm:ss a zzz")
            } else if value is NSArray {
                let itemCount = (value as? NSArray)?.count ?? 0
                str2 = "(Array) with \(itemCount) " + "item".pluralize(itemCount)
            } else if value is NSDictionary {
                let itemCount = (value as? NSDictionary)?.count ?? 0
                str2 = "{Dictionary} with \(itemCount) " + "item".pluralize(itemCount)
            }
            a1 += str1 + getDashes(key: str1, length: length) + "> " + str2
        }// next
        print(a1)
        
    } else {                                    // expandLevels > 0
        if length < 2 { length = 14 }
        for (key, value) in dictNS {
            //print("\(key) --> \(value) ")
            let sKey = key as? String ?? "???"
            print(sKey + getDashes(key: sKey, length: length) + ">", value)
        }//next
    }
    print("======================== end \(title) \(type) =========================\n")
    if expandLevels > 0 { print() }
}//end func

// Helper for printDictionaryNS
func getDashes(key: String, length: Int) -> String {
    let dashCount = max(1, length - key.count - 1)
    let dashes = String(repeatElement("-", count: dashCount))
    return " " + dashes
}

//MARK:- Date Extensions
extension Date {

    //---- Date.ToString
    ///Convert to String using formats like "MM/dd/yyyy hh:mm:ss"
    /// - parameter format: String like "MM/dd/yyyy hh:mm:ss"
    func ToString(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let out = dateFormatter.string(from: self)
        return out
    }

    //---- Date.getComponents -
    ///Get DateComponents .year, .month, .day, .hour, .minute, .second, calendar, .timeZone, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear
    func getComponents() -> DateComponents {
        let unitFlags:Set<Calendar.Component> = [ .year, .month, .day, .hour, .minute, .second, .calendar, .timeZone, .weekday, .weekdayOrdinal, .quarter, .weekOfMonth, .weekOfYear ]
        let dateComponents = Calendar.current.dateComponents(unitFlags, from: self)
        return dateComponents
    }

    //???? forced unwrap, timezone?
    ///returns a Date stripped of time (i.e. just after midnight) for the local timezone
    var DateOnly: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateStr = dateFormatter.string(from: self)
        let date = dateFormatter.date(from: dateStr) ?? self
        return date
    }

}//end Date extension


/**/
