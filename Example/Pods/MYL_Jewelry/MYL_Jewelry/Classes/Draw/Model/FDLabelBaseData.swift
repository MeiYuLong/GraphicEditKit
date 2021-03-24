//
//  FDLabelBaseData.swift
//  MYL_Jewelry
//
//  Created by yulong mei on 2021/3/10.
//

import Foundation

/// 绘制小标签基础数据
public class FDLabelBaseData {
    
    /// 寄件人地址缩写
    public var src_abbreviation: String?
    
    /// 寄件人姓名
    public var src_name: String?
    
    /// 寄件人电话
    public var src_phone: String?
    
    /// 寄件人详细地址
    public var src_detail_address: String?
    
    /// 寄件乡
    public var src_district_name: String?
    
    /// 寄件市
    public var src_city_name: String?
    
    /// 寄件省
    public var src_province_name: String?
    
    /// 寄件邮编
    public var src_postal_code: String?
    
    /// 收件人地址缩写
    public var dst_abbreviation: String?
    
    /// 收件人姓名
    public var dst_name: String?
    
    /// 收件人电话
    public var dst_phone: String?
    
    /// 收件人详细地址
    public var dst_detail_address: String?
    
    /// 收件乡
    public var dst_district_name: String?
    
    /// 收件市
    public var dst_city_name: String?
    
    /// 收件省
    public var dst_province_name: String?
    
    /// 收件邮编
    public var dst_postal_code: String?
    
    /// 备注
    public var remark: String?
    
    public init() {}
}

/// Flashexpress打印运单数据
public class FDTicketLabelData: FDLabelBaseData {
    
    /// 使用COD
    public var cod_enabled: Int = 0
    
    /// COD金额
    public var cod_amount: Int = 0
    
    /// 运单编号
    public var meow_pno: String?
}
