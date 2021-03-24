//
//  GEImageCropViewController.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit
import JPImageresizerView

class GEImageCropViewController: GEBaseViewController {

    var image: UIImage?
    
    var configure: JPImageresizerConfigure!
    var imageresizerView: JPImageresizerView!
    
    var cropImageClosure: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadSubView()
    }
    
    private func loadSubView() {
        self.navigationItem.title = "ge.Crop_image".GE_Locale
        self.ge_createLeftButtonWithImageName("icon_nav_back", target: self)
        self.ge_createButtonWithTitle("ge.sure".GE_Locale, target: self)
        configure = JPImageresizerConfigure.defaultConfigure(with: self.image ?? UIImage.ge_bundle(named: "Cyberpunk_1")!, make: nil)
        view.backgroundColor = configure.bgColor
        self.automaticallyAdjustsScrollViewInsets = false
        configure.frameType = .classicFrameType
        
        var contentInsets = UIEdgeInsets.init(top: 15, left: 15, bottom: 100, right: 15)
        contentInsets.bottom += safeWindowAreaInsetsBottom()
        configure.contentInsets = contentInsets
        configure.viewFrame = UIScreen.main.bounds
        imageresizerView = JPImageresizerView(configure: configure, imageresizerIsCanRecovery: { (isCanRecovery) in
            
        }, imageresizerIsPrepareToScale: { (isPrepareToScale) in
            
        })
        self.view.insertSubview(imageresizerView, at: 0)
        configure = nil
    }
    
    override func ge_onRightBarClick(_ sender: UIBarButtonItem) {
        imageresizerView.cropPicture(withCacheURL: URL.init(string: "")) { (url, error) in
            
        } complete: { (image, url, result) in
            guard let img = image else {
                return
            }
            self.cropImageClosure?(img)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
