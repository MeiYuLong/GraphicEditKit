//
//  FP_String+Extension.swift
//  FlashPrinter
//
//  Created by yulong mei on 2021/3/24.
//

import Foundation

extension String {
    class NoUser {}
    var FP_Locale: String {
        guard let bundlePath = Bundle(for: NoUser.self).resourcePath else { return self }
        guard let bundle = Bundle(path: bundlePath + "/FlashPrinter.bundle") else {
            return self
        }
        let content = NSLocalizedString(self, tableName: "FPLocalizable", bundle: bundle, value: "", comment: "")
        return content
    }
}
