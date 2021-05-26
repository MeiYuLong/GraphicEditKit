//
//  FHEvent.swift
//  FlashHookKit
//
//  Created by yulong mei on 2021/5/25.
//

import Foundation

/// 事件埋点，统一管理 （default param --[account: mobile]）
public enum FHEnvent {
    /// A01_注册登录页 新用户的注册
    case signIn_A0101
    
    /// A00_应用程序 老用户的启动次数
    case applicationProgram_A0000
    
    /// A02_主页 图文编辑页面的访问次数
    case imageTextEditing_A0201
    
    /// B00_图文编辑页 页面整体停留时间 ( image_text_print_time 秒)
    case imageTextEditing_B0001(image_text_print_time: Int)
    
    /// B01_打印预览页 图文编辑页面的打印情况 (打印时间print_time, 打印模式print_mode：Image_Text图文/Text文本, 打印长度print_length（单位：厘米）)
    case printNow_B0101(print_time: String, print_mode: String, print_length: String)
    
    /// A02_主页 快递单打印页面访问
    case expressBillPrinting_A0202
    
    /// C00_快递单打印页 快递单功能的总打印使用 （print_time，  print_length）
    case printing_C0001(print_time: String, print_length: String)
    
    /// C01_历史打印页 历史打印
    case print_C0101
}

protocol FHLogEnvent {
    var name: String { get }
     var param: [String: Any] { get }
}

extension FHEnvent: FHLogEnvent {
    public var name: String {
        switch self {
        case .signIn_A0101:
            return "A0101_sign_in"
        case .applicationProgram_A0000:
            return "A0000_application_program"
        case .imageTextEditing_A0201:
            return "A0201_Image_Text_editing"
        case .imageTextEditing_B0001(_):
            return "B0001_Image_Text_editing"
        case .printNow_B0101(_, _, _):
            return "B0101_print_now"
        case .expressBillPrinting_A0202:
            return "A0202_Express_bill_printing"
        case .printing_C0001(_, _):
            return "C0001_Printing"
        case .print_C0101:
            return "C0101_Printing"
        default:
            return ""
        }
    }
    
    public var param: [String : Any] {
        switch self {
        case .signIn_A0101,
             .applicationProgram_A0000,
             .imageTextEditing_A0201,
             .expressBillPrinting_A0202,
             .print_C0101:
            return [:]
            
        case let .imageTextEditing_B0001(image_text_print_time):
            return ["image_text_print_time": image_text_print_time]
        case let .printNow_B0101(print_time, print_mode, print_length):
            return ["print_time": print_time, "print_mode": print_mode, "print_length": print_length]
        case let .printing_C0001(print_time, print_length):
            return ["print_time": print_time, "print_length": print_length]
        default:
            return [:]
        }
    }
    
}
