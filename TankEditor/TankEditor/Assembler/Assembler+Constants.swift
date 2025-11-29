//
//  Assembler+Constants.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 29.11.2025.
//

import Foundation

extension Assembler {
    
    //WARNING! it is not enough to change name here - you also have to edit PackageTemplate.txt
    static let RESULT_NAME = "UserCode"
    static var DYLIB_NAME: String { "lib\(RESULT_NAME).dylib" }
    static var DSYM_NAME: String { "\(DYLIB_NAME).dSYM" }
}
