//
//  Device.swift
//  imHome
//
//  Created by Kevin Xu on 2/9/15. Updated on 6/20/15.
//  Copyright (c) 2015 Alpha Labs, Inc. All rights reserved.
//

import UIKit

// MARK: - Device Structure

struct Device {

    // MARK: - Singletons

//    static var TheCurrentDevice: UIDevice {
//        struct Singleton {
//            static let device = UIDevice.current
//        }
//        return Singleton.device
//    }

    static var currentDeviceVersion: Float {
        struct Singleton {
            static let version = Float(UIDevice.current.systemVersion) ?? 0.0
        }
        return Singleton.version
    }

    static var currentDeviceHeight: CGFloat {
        struct Singleton {
            static let height = CGFloat(UIScreen.main.bounds.size.height)
        }
        return Singleton.height
    }

    static var currentDeviceWidth: CGFloat {
        struct Singleton {
            static let width = CGFloat(UIScreen.main.bounds.size.width)
        }
        return Singleton.width
    }

    // MARK: - Device Idiom Checks

    static var deviceType: String {
        if isPhone() {
            return "iPhone"
        } else if isPad() {
            return "iPad"
        }
        return "Not iPhone nor iPad"
    }

    static var debugOrRelease: String {
        #if DEBUG
            return "Debug"
        #else
            return "Release"
        #endif
    }

    static var simulatorOrDevice: String {
        #if targetEnvironment(simulator)
            return "Simulator"
        #else
            return "Device"
        #endif
    }

//    static var CURRENT_DEVICE: String {
//        return GBDeviceInfo.deviceInfo().modelString
//    }

    static func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    static func isPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    static func isDebug() -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    static func isRelease() -> Bool {
        return !isDebug()
    }

    static func isSimulator() -> Bool {
        return simulatorOrDevice == "Simulator"
    }

    static func isDevice() -> Bool {
        return simulatorOrDevice == "Device"
    }

    // MARK: - Device Version Checks

    enum Versions: Float {
        case Five = 5.0
        case Six = 6.0
        case Seven = 7.0
        case Eight = 8.0
        case Nine = 9.0
    }

    static func isVersion(version: Versions) -> Bool {
        return currentDeviceVersion >= version.rawValue && currentDeviceVersion < (version.rawValue + 1.0)
    }

    static func isVersionOrLater(version: Versions) -> Bool {
        return currentDeviceVersion >= version.rawValue
    }

    static func isVersionOrEarlier(version: Versions) -> Bool {
        return currentDeviceVersion < (version.rawValue + 1.0)
    }

    static var CURRENT_VERSION: String {
        return "\(currentDeviceVersion)"
    }


    // MARK: - Device Size Checks

    enum Heights: CGFloat {
        case Inches_3_5 = 480
        case Inches_4   = 568
        case Inches_4_7 = 667
        case Inches_5_5 = 736
        case Inches_5_8 = 812
        case Inches_9_7 = 1024
    }

    static func isSize(height: Heights) -> Bool {
        return currentDeviceHeight == height.rawValue
    }

    static func isSizeOrLarger(height: Heights) -> Bool {
        return currentDeviceHeight >= height.rawValue
    }

    static func isSizeOrSmaller(height: Heights) -> Bool {
        return currentDeviceHeight <= height.rawValue
    }

    static var CURRENT_SIZE: String {
        if IS_3_5_INCHES() {
            return "3.5 Inches"
        } else if IS_4_INCHES() {
            return "4.0 Inches"
        } else if IS_4_7_INCHES() {
            return "4.7 Inches"
        } else if IS_5_5_INCHES() {
            return "5.5 Inches"
        }
        return "\(currentDeviceHeight) Points"
    }

    // MARK: Retina Check

//    static func IS_RETINA() -> Bool {
//        return UIScreen.mainScreen.respondsToSelector("scale")
//    }

    // MARK: 3.5 Inch Checks

    static func IS_3_5_INCHES() -> Bool {
        return isPhone() && isSize(height: .Inches_3_5)
    }

    static func IS_3_5_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_3_5)
    }

    static func IS_3_5_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrSmaller(height: .Inches_3_5)
    }

    // MARK: 4 Inch Checks

    static func IS_4_INCHES() -> Bool {
        return isPhone() && isSize(height: .Inches_4)
    }

    static func IS_4_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_4)
    }

    static func IS_4_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrSmaller(height: .Inches_4)
    }

    // MARK: 4.7 Inch Checks

    static func IS_4_7_INCHES() -> Bool {
        return isPhone() && isSize(height: .Inches_4_7)
    }

    static func IS_4_7_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_4_7)
    }

    static func IS_4_7_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_4_7)
    }

    // MARK: 5.5 Inch Checks

    static func IS_5_5_INCHES() -> Bool {
        return isPhone() && isSize(height: .Inches_5_5)
    }

    static func IS_5_5_INCHES_OR_LARGER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_5_5)
    }

    static func IS_5_5_INCHES_OR_SMALLER() -> Bool {
        return isPhone() && isSizeOrLarger(height: .Inches_5_5)
    }

    // MARK: - International Checks

//    static var CURRENT_REGION: String? {
//        //return NSLocale.currentLocale.objectForKey(NSLocaleCountryCode) as! String
//    }
}
