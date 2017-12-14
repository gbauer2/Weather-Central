//
//  OtherExtensions.swift
//  Weather Central
//
//  Created by George Bauer on 12/13/17.
//  Copyright © 2017 GeorgeBauer. All rights reserved.
//

import Foundation

//print("double:\(lat.format(".3"))")
extension Double {
    func format(fmt: String) -> String {
        return String(format: "%\(fmt)f", self)
    }
}
