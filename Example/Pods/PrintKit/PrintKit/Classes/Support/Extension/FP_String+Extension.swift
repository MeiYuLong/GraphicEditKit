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
        guard let bundle = Bundle(path: bundlePath + "/PrintKit.bundle") else {
            return self
        }
        var finalBundle: Bundle = bundle
        if let languages = UserDefaults.standard.value(forKey: "AppleLanguages") as? [String],
           let first = languages.first,
           let bundlePath = bundle.path(forResource: first, ofType: "lproj"),
           let bundle1 = Bundle(path: bundlePath)  {
            finalBundle = bundle1
        }
        if let language = UserDefaults.standard.value(forKey: "Language") as? String, !language.isEmpty,
           let bundlePath = bundle.path(forResource: language, ofType: "lproj"),
           let bundle1 = Bundle(path: bundlePath) {
            finalBundle = bundle1
        }
        let content = NSLocalizedString(self, tableName: "PrintLocalizable", bundle: finalBundle, value: "", comment: "")
        return content
    }
    
    
}
