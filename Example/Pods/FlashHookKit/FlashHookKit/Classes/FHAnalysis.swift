//
//  FHAnalysis.swift
//  FlashHookKit
//
//  Created by yulong mei on 2021/5/25.
//

import Foundation

public class FHAnalysis {
    public static let shared = FHAnalysis()
    
    public typealias FHAnalysisHander = (FHEnvent) -> Void
    private var analysisHander: FHAnalysisHander?
    
    public func register(hander: @escaping FHAnalysisHander) {
        self.analysisHander = hander
    }
    
    public func logEvent(event: FHEnvent) {
        debugPrint("--- FHAnalysis \(event.name) , params: \(event.param) --- ")
        self.analysisHander?(event)
    }
}
