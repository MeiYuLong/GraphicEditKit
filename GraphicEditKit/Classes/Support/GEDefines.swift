//
//  GEDefines.swift
//  GPUImage
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation

func GE_IsASIIC(_ string: String) -> Bool {
    if string.isEmpty {
        return false
    }
    let regex = "[\\x00-\\xff]*"
    let predicate = NSPredicate.init(format: "SELF MATCHES %@", regex)
    let result = predicate.evaluate(with: string)
    return result
}
