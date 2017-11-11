//
//  MaintainCallLog.swift
//  Weather Central
//
//  Created by George Bauer on 10/11/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//
//  funcs and globals for maintaining CallLog (to enforce per minute & per day limits)
//  SHOULD BE CHANGED TO A CLASS!

import Foundation

//MARK: --- Global Constants and Variables ---
let gMaxCallsPerDay = 500

var gDateStartup   = Date()
var gDateLastRun   = Date()
var gDateLastCall  = Date()
var gYmdLastCallET = 0
var gNumCallsToday = 0

// callLog holds the Time of each of the last 10 calls
var callLog = [Date(),Date(),Date(),Date(),Date(), Date(),Date(),Date(),Date(),Date()]

//MARK: --- Call this function before making a WU API call --
public func CallLogInit() {
    // 1 Read perm
    gDateLastRun   = UserDefaults.standard.object(forKey: "dateLastRun"  ) as? Date ?? Date()
    gDateLastCall  = UserDefaults.standard.object(forKey: "dateLastCall" ) as? Date ?? Date()
    gYmdLastCallET = UserDefaults.standard.object(forKey: "ymdLastCallET") as? Int  ?? 0
    gNumCallsToday = UserDefaults.standard.object(forKey: "numCallsToday") as? Int  ?? 0
    callLog[0]     = Date(timeIntervalSinceNow: -61)     // init the time of last call to more than a munute ago
    
    _ = checkDailyLimit()
    
    UserDefaults.standard.set(Date(), forKey: "dateLastRun")
    
    let secHowLong = Date().timeIntervalSince(gDateLastRun)
    if secHowLong <= 99 {
        print ("\nIt's been \(Int(secHowLong)) seconds since last run.\n")
    } else {
        let minHowLong = secHowLong / 60.0
        if minHowLong <= 99 {
            print ("\nIt's been\(String(format: "%5.1f", minHowLong)) minutes since last run.\n")
        } else {
            let hrHowLong = minHowLong / 60.0
            print ("\nIt's been\(String(format: "%5.1f", hrHowLong)) hours since last run.\n")
            
        }
    }//end else secHowLong <= 99
    
}//end func CallLogInit

//MARK: --- Call this function before making a WU API call --
// ------ Check to see if this call would exceed 10/minute or 500/day
public func tryToLogCall(makeCall: Bool) -> (isOK:Bool, numCallsLastMinute: Int, msg: String) {
    var numCallsLastMinute = 0
    for date in callLog {
        let secSince = Date().timeIntervalSince(date)
        if secSince >= 60.0 {break}
        numCallsLastMinute += 1
        if numCallsLastMinute >= 9 {
            let strWait = "in \(Int(61.99 - secSince)) seconds"
            
            return (false, numCallsLastMinute, strWait) }
    }
    
    if !checkDailyLimit()          { return (false, numCallsLastMinute, "tomorrow") }

    // It's all good, So make the call. Assuming you do, let's log it.:
    for index in stride(from: 9, through: 1, by: -1) {
        callLog[index] = callLog[index - 1]
    }
    if makeCall {
        callLog[0] = Date()
        gNumCallsToday += 1
        numCallsLastMinute += 1
        gDateLastCall = Date()
        UserDefaults.standard.set(gNumCallsToday, forKey: "numCallsToday")
        UserDefaults.standard.set(gDateLastCall,  forKey: "dateLastCall")
    }
    return (true, numCallsLastMinute, "")
}//end func


//MARK: --- Supporting functions ---
// ------ Check number of calls today against daily limit (resetting daily limit if new day) ------
public func checkDailyLimit() -> Bool {
    let dateET = getTimeEastern(localDate: Date())
    let ymdNowET = CalcYmd(date: dateET)
    print("ymdNowET = \(ymdNowET)")
    
    if ymdNowET != gYmdLastCallET {              // It's a brand new day!
        print("was \(gYmdLastCallET) ET, now is \(ymdNowET) ET.  Reset numCallsToday to 0")
        gNumCallsToday = 0
        gYmdLastCallET = ymdNowET
        UserDefaults.standard.set(gYmdLastCallET, forKey: "ymdLastCallET")
        UserDefaults.standard.set(gNumCallsToday, forKey: "numCallsToday")
    }
    return gNumCallsToday < gMaxCallsPerDay
}//end func


// ------ get DateTime in the Eastern Timezone from a local DateTime ------
public func getTimeEastern(localDate: Date) -> Date {
    let timeZoneET = TimeZone(abbreviation: "EST")!
    
    let timeZoneCurrent = TimeZone.current // ??????????????????
    //let timeZoneCurrent = TimeZone(abbreviation: "PST")! // ??? This is a test for Dustin
    
    let offsetSecsET = (timeZoneET.secondsFromGMT())
    let offsetSecsCurrent = (timeZoneCurrent.secondsFromGMT())
    let offsetDif:TimeInterval = Double(offsetSecsET - offsetSecsCurrent)
    let dateET = Date(timeInterval: offsetDif, since: localDate)
    return dateET
}//end func

// ------ Create the Int YYYYMMDD from a date ------
public func CalcYmd(date:Date) -> Int {
    //: Using the current calendar, get the components
    let unitFlags:Set<Calendar.Component> = [ .year, .month, .day, .hour, .minute, .second, .calendar, .timeZone]
    let dateComponentsNow = Calendar.current.dateComponents(unitFlags, from: date)
    let ymdNow = dateComponentsNow.day! + 100 * (dateComponentsNow.month! + 100 * dateComponentsNow.year!)
    return ymdNow
}//end func
