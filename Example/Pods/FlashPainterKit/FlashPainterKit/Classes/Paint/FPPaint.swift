//
//  FPPaint.swift
//  FlashPainterKit
//
//  Created by yulong mei on 2021/9/24.
//

import Foundation

internal class FPPaint {
    
    static let shared = FPPaint()
    
    var multiple:CGFloat = 1
    var barcodeHeight: CGFloat = 85
    var dcNameWidth: CGFloat = 65
    var edge: CGFloat = 5
    var dcNameEdge: CGFloat = 7
    var barcodeFontSize:CGFloat = 26
    var dcNameFontSize: CGFloat = 22
    var namePhoneFontSize: CGFloat = 20
    var remarkFontSize: CGFloat = 20
    
    var addressFontSize: CGFloat = 20
    var bgWidth = 380
    var bgHeight = 400
    
    var bgSize: CGSize = .zero
    
    let textColor = UIColor.black
    let lineColor = UIColor.black
    
    var x: CGFloat = 0
    var y: CGFloat = 0
    
    var bgView = UIView()
    
    init() {
        bgSize = CGSize.init(width: bgWidth, height: bgHeight)
        bgView.backgroundColor = UIColor.white
        bgView.frame = CGRect.init(x: 0, y: 0, width: bgSize.width, height: bgSize.height)
    }
    
//    /// 365Print绘制
//    public func draw365Label(data: FDLabelBaseData, _ bottomMargin: CGFloat) -> UIImage {
//        x = 0
//        y = 0
//        let _ = bgView.subviews.map{ $0.removeFromSuperview() }
//        self.drawAddressInfo(data: data, type: .SRC)
//        self.drawAddressInfo(data: data, type: .DST)
//        self.drawRemark(data: data)
//        return self.drawImage()
//    }
    
    /// Flash PNO绘制
    public func drawPNOLabel(data: FPTicketLabelData, _ bottomMargin: CGFloat = 0) -> UIImage {
        x = 0
        y = 0
        let _ = bgView.subviews.map{ $0.removeFromSuperview() }
        self.drawCOD(data: data)
        self.drawBarCode(data: data)
        self.drawAddressInfo(data: data, type: .SRC)
        self.drawAddressInfo(data: data, type: .DST)
        self.drawRemark(data: data)
        self.drawBottomLogo(image: nil, web: "Flashexpress.com")
        return self.drawImage()
    }
    
    private func drawImage(_ bottomMargin: CGFloat = 0) -> UIImage {
        //重新计算总高度
        bgView.frame = CGRect.init(x: 0, y: 0, width: bgSize.width, height: y + bottomMargin)
        
        UIGraphicsBeginImageContext(bgView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        //currentView 当前的view 创建一个基于位图的图形上下文并指定大小为
        bgView.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext();//返回一个基于当前图形上下文的图片
        UIGraphicsEndImageContext();//移除栈顶的基于当前位图的图形上下文
        return image ?? UIImage()
    }
    
}

//MARK: FlashExpress绘制小标签(COD、BarCode、 寄件人信息、 收件人信息、 备注、 底部Logo)
extension FPPaint {
    
    /// 绘制COD
    /// - Parameter data: FDTicketLabelData
    private func drawCOD(data: FPTicketLabelData) {
        let codEnable = data.cod_enabled
        let codAmount = data.cod_amount
        if codEnable == 1 && codAmount > 0 {
            let codLabel = UILabel()
            codLabel.text = "COD"
            codLabel.textAlignment = .center
            codLabel.font = UIFont.boldSystemFont(ofSize: barcodeFontSize)
            codLabel.textColor = textColor
            codLabel.frame = CGRect.init(x: 0, y: 0, width: bgView.width, height: 0)
            bgView.addSubview(codLabel)
            codLabel.sizeToFit()
            codLabel.minX = (bgView.width - codLabel.width)/2
            y = codLabel.maxY + edge
        }
    }
    
    /// 绘制条形码
    /// - Parameter data: FDTicketLabelData
    private func drawBarCode(data: FPTicketLabelData) {
        guard let meow_pno = data.meow_pno, !meow_pno.isEmpty else { return }
        let barcode = meow_pno
        let newBarcode = FP_BarcodeTools.secretPno(origin: barcode)
        let barcodeImage = FP_BarcodeTools.generateBarCode(IDCodeString: newBarcode)
        let imageView = UIImageView.init(image: barcodeImage)
        imageView.frame = CGRect.init(x: 10, y: y, width: bgView.width-20, height: barcodeHeight)
        bgView.addSubview(imageView)
        
        //barcode
        let barcodeLabel = UILabel()
        barcodeLabel.text = barcode
        barcodeLabel.font = UIFont.boldSystemFont(ofSize: barcodeFontSize)
        barcodeLabel.textColor = textColor
        barcodeLabel.frame = CGRect.init(x: 0, y: 0, width: bgView.width, height: 0)
        bgView.addSubview(barcodeLabel)
        barcodeLabel.sizeToFit()
        
        x = (bgView.width - barcodeLabel.width)/2
        y = imageView.maxY + edge
        barcodeLabel.minX = x
        barcodeLabel.minY = y
        y = barcodeLabel.maxY+edge
    }
    
    /// 绘制寄件人信息
    /// - Parameter data: FDLabelBaseData
    private func drawAddressInfo(data: FPLabelBaseData, type: FPAddressInfoType = .SRC) {
        
        var srcTag = data.src_title
        var dstTag = data.dst_title
        if let src_abbreviation = data.src_abbreviation, !src_abbreviation.isEmpty {
            srcTag = "\(srcTag)\n\(src_abbreviation)"
        }
        if let dst_abbreviation = data.dst_abbreviation, !dst_abbreviation.isEmpty {
            dstTag = "\(dstTag)\n\(dst_abbreviation)"
        }
        let tagText = type == .SRC ? srcTag : dstTag
        
        let name = (type == .SRC ? data.src_name : data.dst_name) ?? ""
        let phone = (type == .SRC ? data.src_phone : data.dst_phone) ?? ""
        let detailAddress = (type == .SRC ? data.src_detail_address : data.dst_detail_address) ?? ""
        let district = (type == .SRC ? data.src_district_name : data.dst_district_name) ?? ""
        let city = (type == .SRC ? data.src_city_name : data.dst_city_name) ?? ""
        let province = (type == .SRC ? data.src_province_name : data.dst_province_name) ?? ""
        let postCode = (type == .SRC ? data.src_postal_code : data.dst_postal_code) ?? ""
        
        //line1  横一
        let line1 = UIView()
        line1.backgroundColor = lineColor
        line1.frame = CGRect.init(x: 2, y: y, width: bgView.width-4, height: 1)
        bgView.addSubview(line1)
        
        //from 寄
        let fromLabel = UILabel()
        fromLabel.textAlignment = .center
        fromLabel.font = UIFont.boldSystemFont(ofSize: dcNameFontSize)
        fromLabel.textColor = textColor
        fromLabel.numberOfLines = 2
        fromLabel.text = tagText
        fromLabel.frame = CGRect.init(x: 0, y: line1.maxY + dcNameEdge + 2.5*multiple, width: dcNameWidth, height: 0)
        bgView.addSubview(fromLabel)
        fromLabel.sizeToFit()
        x = (dcNameWidth - fromLabel.width)/2
        fromLabel.minX = x
        
        //line2 横二
        let line2 = UIView()
        line2.backgroundColor = UIColor.black
        line2.frame = CGRect.init(x: 2, y: fromLabel.maxY + dcNameEdge + 2.5*multiple, width: bgSize.width-4, height: 1)
        bgView.addSubview(line2)
        
        //line3  竖二
        let line3 = UIView()
        line3.backgroundColor = UIColor.black
        line3.frame = CGRect.init(x: dcNameWidth, y: line1.minY, width: 1, height: line2.minY - line1.minY)
        bgView.addSubview(line3)
        
        //name
        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: namePhoneFontSize)
        nameLabel.textColor = textColor
        nameLabel.numberOfLines = 2
        nameLabel.text = "\(name)"
        nameLabel.frame =  CGRect.init(x: line3.maxX + edge, y: line1.maxY + edge, width: bgView.width - dcNameWidth - edge*2, height: 0)
        bgView.addSubview(nameLabel)
        nameLabel.sizeToFit()
        
        //phone
        let phoneLabel = UILabel()
        phoneLabel.font = UIFont.boldSystemFont(ofSize: namePhoneFontSize)
        phoneLabel.textColor = textColor
        phoneLabel.numberOfLines = 1
        phoneLabel.text = "\(phone)"
        phoneLabel.frame = CGRect.init(x: nameLabel.minX, y: nameLabel.maxY, width: bgView.width - dcNameWidth - edge*2, height: 0)
        bgView.addSubview(phoneLabel)
        phoneLabel.sizeToFit()
        
        //重新计算name和phone的位置，使其垂直居中
        let height = line2.maxY - line1.maxY
        let top = (height - phoneLabel.height - nameLabel.height-3)/2 + line1.maxY
        nameLabel.minY = top
        phoneLabel.minY = nameLabel.maxY + 3
        
        //详细地址 省市乡
        let region = "\(detailAddress + " ")" +
                        "\(district + " ")" +
                        "\(city + " ")" +
                        "\(province + " ")" +
                        "\(postCode)"
        let regionLabel = UILabel()
        regionLabel.font = UIFont.boldSystemFont(ofSize: addressFontSize)
        regionLabel.numberOfLines = 5
        regionLabel.text = region
        regionLabel.textColor = textColor
        regionLabel.frame = CGRect.init(x: edge, y: line2.maxY + edge, width: bgView.width - edge*2, height: 0)
        bgView.addSubview(regionLabel)
        regionLabel.sizeToFit()
        
        //line4  横三
        let line4 = UIView()
        line4.backgroundColor = UIColor.black
        line4.frame = CGRect.init(x: 2, y: regionLabel.maxY+edge, width: line1.width, height: 1)
        bgView.addSubview(line4)
        //line5  竖1
        let line5 = UIView()
        line5.backgroundColor = UIColor.black
        line5.frame = CGRect.init(x: 2, y: line1.maxY, width: 1, height: line4.minY - line1.maxY)
        bgView.addSubview(line5)
        //line6 竖3
        let line6 = UIView()
        line6.backgroundColor = UIColor.black
        line6.frame = CGRect.init(x: line4.maxX - 1, y: line1.maxY, width: line5.width, height: line5.height)
        bgView.addSubview(line6)
        
        y = line6.maxY+edge
    }
    
    /// 绘制备注区域
    /// - Parameter data: FDLabelBaseData
    private func drawRemark(data: FPLabelBaseData) {
        guard let remark = data.remark, !remark.isEmpty  else { return }
        //remarkLine1 横一
        let remarkLine1 = UIView()
        remarkLine1.backgroundColor = UIColor.black
        remarkLine1.frame = CGRect.init(x: 2, y: y, width: bgSize.width-4, height: 1)
        bgView.addSubview(remarkLine1)
        
        let remarkLabel = UILabel()
        remarkLabel.frame = CGRect(x: edge, y: remarkLine1.maxY + edge, width: bgView.width - edge*2, height: 0)
        remarkLabel.text = remark
        remarkLabel.textColor = textColor
        remarkLabel.font = UIFont.boldSystemFont(ofSize: remarkFontSize)
        remarkLabel.numberOfLines = 0
        bgView.addSubview(remarkLabel)
        remarkLabel.sizeToFit()
        
        //remarkLine1 横二
        let remarkLine2 = UIView()
        remarkLine2.backgroundColor = UIColor.black
        remarkLine2.frame = CGRect.init(x: 2, y: remarkLabel.maxY + edge, width: bgSize.width-4, height: 1)
        bgView.addSubview(remarkLine2)
        
        //remarkLine3  竖1
        let remarkLine3 = UIView()
        remarkLine3.backgroundColor = UIColor.black
        remarkLine3.frame = CGRect.init(x: 2, y: remarkLine1.maxY, width: 1, height: remarkLine2.minY - remarkLine1.maxY)
        bgView.addSubview(remarkLine3)
        
        //remarkLine4 竖2
        let remarkLine4 = UIView()
        remarkLine4.backgroundColor = UIColor.black
        remarkLine4.frame = CGRect.init(x: remarkLine1.maxX - 1, y: remarkLine1.maxY, width: 1, height: remarkLine3.height)
        bgView.addSubview(remarkLine4)
        
        y = remarkLine2.maxY
    }
    
    /// 绘制底部Logo区域
    /// - Parameters:
    ///   - image: Logo
    ///   - web: web 地址
    private func drawBottomLogo(image: UIImage?, web: String?) {
        //logo
        let defaultIcon = UIImage.make(name: "logo") ?? UIImage()
        let logoImageView = UIImageView()//495*147
        logoImageView.image = image ?? defaultIcon
        let logoHeight = 50
        logoImageView.frame = CGRect.init(x: 0, y: Int(y + edge), width: Int(495*logoHeight/147), height: logoHeight)
        bgView.addSubview(logoImageView)
        
        //flashexpress.com
        let networkLabel = UILabel()
        networkLabel.font = UIFont.italicSystemFont(ofSize: addressFontSize)
        networkLabel.text = web ?? "FlashExpress.com"
        networkLabel.textColor = textColor
        networkLabel.frame = CGRect.init(x: 0, y: y + edge + 10, width: bgView.width - edge*2, height: 0)
        bgView.addSubview(networkLabel)
        networkLabel.sizeToFit()
        networkLabel.minX = bgView.width - networkLabel.width - edge
        
        y = logoImageView.maxY
    }
}
