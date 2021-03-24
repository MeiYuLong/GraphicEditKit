//
//  GEString+Extension.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/18.
//

import Foundation

extension String {
    class NoUser {}
    var GE_Locale: String {
        guard let bundlePath = Bundle(for: NoUser.self).resourcePath else { return self }
        guard let bundle = Bundle(path: bundlePath + "/GraphicEditKit.bundle") else {
            return self
        }
        let content = NSLocalizedString(self, tableName: "GELocalizable", bundle: bundle, value: "", comment: "")
        return content
    }
}
