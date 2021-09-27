//
//  GEPrintPreviewViewController.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit
import MBProgressHUD
import PrintKit
import FlashHookKit

/// 打印预览界面
class GEPrintPreviewViewController: GEBaseViewController {

    var image: UIImage? {
        didSet {
            let imagea = GEImageService.imageModel(image: scaleToOriginSize(img:  self.image))
            self.imageView.image = imagea
            self.bottomView.lenth = (imagea?.size.height ?? 0.0) * 0.0122
        }
    }
    
    private var printModels: [GEPrintModel] = []
    
    private var picModel: GEPrintPreviewToolView.PrintModel = .text
    private var picDepth: GEPrintPreviewToolView.PrintDensity = .miderate

    private lazy var bottomView: GEPrintPreviewToolView = {
        let view = GEPrintPreviewToolView()
        view.model = .image
        view.depth = .miderate
        view.copies = 1
        view.lenth = 10.0
        view.clickPrint = { [weak self] in
            self?.clickPrint()
        }
        view.clickInfo = {
            view.show()
        }
        view.clickCancel = { [weak self] in
            view.hide()
            self?.reloadImageView()
        }
        view.clickSubmit = { [weak self] in
            view.hide()
            self?.picModel = view.model
            self?.picDepth = view.depth
            self?.reloadImageView()
        }
        return view
    }()
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.isUserInteractionEnabled = true
//        view.contentMode = .scaleAspectFit
        return view
    }()
    private lazy var bgView: GEJaddedLayerView = {
        let view = GEJaddedLayerView()
        view.backgroundColor = GEBGColor
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSubview()
        self.loadData()
        self.view.backgroundColor = GEBGColor
        self.title = "ge.Image-Text_printing".GE_Locale
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.layoutSubview()
    }
    
    func loadData() {
        
    }
    
    func loadSubview() {
        self.ge_createLeftButtonWithImageName("icon_nav_back", target: self)
        self.view.addSubview(bgView)
        self.view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        self.view.addSubview(bottomView)
    }
    
    func layoutSubview() {
        bgView.frame = CGRect(x: 10, y: 10, width: self.view.frame.width - 20, height: self.view.frame.height - 10)
        var bottomViewHeight = self.safeAreaInsetsBottom() + 64
        if bottomView.isShow {
            bottomViewHeight = bottomViewHeight + bottomView.contentHeight
        }
        
        bottomView.frame = CGRect(x: 0, y: self.view.frame.height - bottomViewHeight, width: self.view.frame.width, height: bottomViewHeight)
        scrollView.frame = CGRect(x: 10, y: 15, width: self.view.frame.width - 20, height: self.view.frame.height - bottomViewHeight - 15 + 16)
        
        var imageViewHeight: CGFloat = 0
        let imageViewWidth: CGFloat = scrollView.frame.width

        if let image = self.image {
            imageViewHeight = imageViewWidth * image.size.height / image.size.width
        }
        imageView.frame = CGRect(x: 0, y: 10, width: imageViewWidth, height: imageViewHeight)
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: imageViewHeight + 20)
    }

}

//MARK: 打印逻辑
extension GEPrintPreviewViewController {
    
    private func buriedPointEvent() {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateStr = format.string(from: date)
        FHAnalysis.shared.logEvent(event: .printNow_B0101(print_time: dateStr, print_mode: picModel == .text ? "Text" : "Image_Text", print_length: String(format: "%.1f", self.bottomView.lenth)))
    }
    
    /// 刷新ImageView
    func reloadImageView() {
        if picModel == .image {
            imageView.image = GEImageService.imageModel(image: scaleToOriginSize(img:  self.image))
        } else {
            imageView.image = GEImageService.textModel(image: self.image)
        }
    }
    /// 点击打印
    private func clickPrint() {
        self.formatData()
        FPPrintManager.shared.start()
        self.checkPrintData()
    }
    
    private func formatData() {
        self.printModels.removeAll()
        var thickness: Int
        switch self.bottomView.depth {
        case .light:
            thickness = 0
        case .miderate:
            thickness = 1
        case .dark:
            thickness = 2
        }
        guard let img = scaleToOriginSize(img: self.imageView.image) else { return }
        let copies = bottomView.copies
        for i in 0...copies-1 {
            let model = GEPrintModel(index: i, total: copies, status: false, image: img, thickness: thickness)
            self.printModels.append(model)
        }
    }
    
    /// 检查打印数据，
    private func checkPrintData() {
        for model in self.printModels {
            if !model.status {
                self.printData(model: model)
                return
            }
        }
    }
    
    /// 开始打印
    /// - Parameter model: 打印的数据
    private func printData(model: GEPrintModel) {
        var data = model
        let index = model.index
        let total = model.total
        FPPrintManager.shared.print(image: model.image, thickness: model.thickness, index: index + 1, total: model.total) { [weak self] (status) in
            debugPrint("FPPrintManager.shared.print Status Monitor: ---", status)
            guard let self = self else { return }
            switch status {
            case .PRINTER_PRINT_OK:
                data.status = true
                self.printModels[index] = data
            case .PRINTER_PRINT_END:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if index + 1 == total {
                        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                        hud.detailsLabel.text = "Print 结束!"
                        hud.mode = .text
                        hud.hide(animated: true, afterDelay: 1.5)
                    }else {
                        self.checkPrintData()
                    }
                }
            case .PRINTER_PRINT_STOP:
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                hud.detailsLabel.text = "Print 结束!"
                hud.mode = .text
                hud.hide(animated: true, afterDelay: 1.5)
            default:
                break
            }
        }
    }
    
    /// image size真是尺寸 = size * scale
    private func scaleToOriginSize(img: UIImage?) -> UIImage? {
        guard let image = img, image.size.width != 380 else {
            return img
        }
        let orginSize = image.size
        // 宽高要为整数，如果不为整数，可能出现一个没有色值的边线，抖动算法和二值化时，没有色值等于黑色
        let newSize = CGSize(width: 380, height: ceil(orginSize.height / orginSize.width * 380))

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg
    }
}

//MARK: Delegate
extension GEPrintPreviewViewController {
    public func showHUD(_ detail: String)  {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.label.text = nil
        hud.detailsLabel.text = detail
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    public func showAlert(_ detail: String)  {
        let alert = UIAlertController.init(title: "", message: detail, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "ge.sure".GE_Locale, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}
