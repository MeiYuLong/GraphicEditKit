//
//  FPPrintTool.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/2.
//

import Foundation

class FPPrintTool {
    
    static public func hex2String(data: Data) -> String {
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    static public func revDataCheckStatus(data: Data) -> String {
        let bytes = [UInt8](data)
        guard let first = bytes.first else { return "" }
        return "\(first)"
    }
    
    static public func converDataToHexStr(data: Data) -> String {
        if data.count == 0 { return "" }
        var result = ""
        for (i,byte) in data.enumerated() {
            let hexStr = String(format: "%02X", byte)
            result += hexStr
            if i == data.count / 2 - 1 {
                result += " "
            }else {
                result += ":"
            }
        }
        let upResult = result.uppercased()
        let results = upResult.components(separatedBy: " ")
        return results.count > 0 ? results[0] : upResult
    }
    
    //MARK: V1.34检查版本号 高于 > 1.53 不能打印
    /// 返回true可以继续打印
    static public func checkVersion(version: String) -> Bool{
        guard !version.isEmpty else { return false }
        var result = true
        var num = String.init(version)
        num.remove(at: num.startIndex)
        let versions = num.split(separator: "_")
        if versions.count >= 1 {
            if let versionF = Float(versions[0]) {
                if versionF >= 1.53 {
                    result = false
                }
            }
        }
        return result
    }
}
