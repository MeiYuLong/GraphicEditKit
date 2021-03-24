//
//  GEBaseEditView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit

/// 编辑类型
enum GEEditType {
    case TEXT, IMAGE, QR_CODE, BAR_CODE
}
///: 图文编辑的主体边框按钮和手势
class GEBaseEditView: UIView {

    let contentLayoutConstant: CGFloat = 20
    let contentTextLabelLeftConstant: CGFloat = 10
    let minImageWidth: CGFloat = 100
    let minTextLabelWidth: CGFloat = 20
    var oldRadius: CGFloat = 0.0
    var rotateRadius: CGFloat = 0.0
    var editType: GEEditType = .IMAGE
    // 拖动放大的最初手势位置
    var panScaleBeginPoint: CGPoint = .zero
    
    var viewModel: GEBaseEditViewModel!
    
    var image: UIImage? {
        didSet {
            contentView.image = image
        }
    }
    
    var text: String? {
        didSet{
            contentView.text = text
        }
    }
        
    /// 呈现内容
    lazy var contentView: GEEditContentView = {
        let view = GEEditContentView(frame: CGRect.zero, type: editType)
        view.layer.borderWidth = 1
        view.layer.borderColor = GELayerColor.cgColor
        return view
    }()
    
    private lazy var topLeftView: GEEditTagView = {
        let view = GEEditTagView()
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        return view
    }()
    
    private lazy var topRightView: GEEditTagView = {
        let view = GEEditTagView()
        view.autoresizingMask = [.flexibleRightMargin, .flexibleTopMargin]
        return view
    }()
    
    private lazy var bottomLeftView: GEEditTagView = {
        let view = GEEditTagView()
        view.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        return view
    }()
    
    private lazy var bottomRightView: GEEditTagView = {
        let view = GEEditTagView()
        view.autoresizingMask = [.flexibleRightMargin, .flexibleBottomMargin]
        return view
    }()
    
    private lazy var tap: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapHandle(_ :)))
        return gesture
    }()
    
    private lazy var doubleTap: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandle(_ :)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    private lazy var panGap: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panHandle(_:)))
        return gesture
    }()

    private lazy var pinch: UIPinchGestureRecognizer = {
        let gesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchHandle(_:)))
        return gesture
    }()
    
    private lazy var rotation: UIRotationGestureRecognizer = {
        let gesture = UIRotationGestureRecognizer(target: self, action: #selector(rotationHandle(_:)))
        return gesture
    }()
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            self.becomeActive()
        }
        return result
    }
    
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        self.resignActive()
        return result
    }
    
    init(frame: CGRect = .zero, type: GEEditType) {
        self.editType = type
        super.init(frame: frame)
        
        self.loadData()
        self.loadSubViews()
        self.layoutSubview()
        self.addGestures()
    }
    
    private func loadData() {
        viewModel = GEBaseEditViewModel()
    }
    
    private func loadSubViews() {
        self.isOpaque = false
        self.isUserInteractionEnabled = true
        self.addSubview(contentView)
        
        topLeftView.imageName = "icon_edit_delete"
        self.addSubview(topLeftView)
        
        topRightView.imageName = "icon_edit_spin"
        self.addSubview(topRightView)
        
        bottomRightView.imageName = "icon_edit_zoom"
        self.addSubview(bottomRightView)
        
        topLeftView.imageName = "icon_edit_delete"
        self.addSubview(topLeftView)
        
        topRightView.imageName = "icon_edit_spin"
        self.addSubview(topRightView)
        
        bottomLeftView.imageName = "icon_edit_crop"
        self.addSubview(bottomLeftView)
        
        bottomRightView.imageName = "icon_edit_zoom"
        self.addSubview(bottomRightView)
        
        switch editType {
        case  .QR_CODE, .BAR_CODE:
            break
        case .TEXT, .IMAGE:
            self.setCropModule()
            break
        }
    }
    
    private func layoutSubview() {
        
        contentView.snp.makeConstraints { (make) in
            make.top.left.equalTo(contentLayoutConstant)
            make.bottom.right.equalTo(-contentLayoutConstant)
        }
        topLeftView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        topRightView.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        bottomRightView.snp.makeConstraints { (make) in
            make.bottom.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.saveOrginData()
    }
    
    public func saveOrginData() {
        let frame = self.frame
        let contentFrame = CGRect(x: frame.origin.x + 20, y: frame.origin.y + 20, width: frame.width - 2 * contentLayoutConstant, height: frame.height - 2 * contentLayoutConstant)
        let layerData = GEImageTextLayer()
        layerData.x = contentFrame.origin.x
        layerData.y = contentFrame.origin.y
        layerData.width = contentFrame.width
        layerData.height = contentFrame.height
        switch editType {
        case .TEXT:
            layerData.type = 1
        default:
            layerData.type = 0
        }
        viewModel.data = layerData
        viewModel.orginImage = image
    }

    private func addGestures() {
        // 点击聚焦
        self.addGestureRecognizer(tap)
        
        // 双击编辑
        self.addGestureRecognizer(doubleTap)
        
        // 拖拽位置
        self.addGestureRecognizer(panGap)
        
        // 捏合🤏缩放
        self.addGestureRecognizer(pinch)
        
        // 旋转
        self.addGestureRecognizer(rotation)
        
        // 点击删除
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteTapHandle(_ :)))
        topLeftView.addGestureRecognizer(deleteTap)
        
        // 拖动旋转
        let panRotateGap = UIPanGestureRecognizer(target: self, action: #selector(panRotateHandle(_:)))
        topRightView.addGestureRecognizer(panRotateGap)
        topRightView.isUserInteractionEnabled = true
        
        //添加锚点
        self.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.5)
        
        // 拖动缩放
        let panGap3 = UIPanGestureRecognizer(target: self, action: #selector(panScaleHandle(_:)))
        bottomRightView.addGestureRecognizer(panGap3)
        bottomRightView.isUserInteractionEnabled = true
        panGap.require(toFail: panGap3)
    
    }
    
    /// 添加裁剪模块
    private func setCropModule() {
        
        bottomLeftView.imageName = editType == GEEditType.TEXT ? "icon_edit_edit" : "icon_edit_crop"
        self.addSubview(bottomLeftView)
        bottomLeftView.snp.makeConstraints { (make) in
            make.bottom.left.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        
        // 点击聚焦
        let cropTap = UITapGestureRecognizer(target: self, action: #selector(cropTapHandle(_ :)))
        bottomLeftView.addGestureRecognizer(cropTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addContent(_ view: UIView) {
        contentView.addSubview(view)
        view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    // subView超出view范围处理
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == nil {
            for subView in self.subviews{
                let myPoint = subView.convert(point, to: self)
                if subView.bounds.contains(myPoint) {
                    return subView
                }
            }
        }
        return view
    }

}


//MARK: 边框和tag状态
extension GEBaseEditView {
    
    public func becomeActive(){
        self.superview?.bringSubviewToFront(self)
        topLeftView.isHidden = false
        topRightView.isHidden = false
        bottomLeftView.isHidden = false
        bottomRightView.isHidden = false
        
        panGap.isEnabled = true
        pinch.isEnabled = true
        rotation.isEnabled = true
        
        contentView.layer.borderWidth = 1
    }
    
    public  func resignActive() {
        topLeftView.isHidden = true
        topRightView.isHidden = true
        bottomLeftView.isHidden = true
        bottomRightView.isHidden = true
        
        panGap.isEnabled = false
        pinch.isEnabled = false
        rotation.isEnabled = false
        
        contentView.layer.borderWidth = 0
    }
    
    /// 缩放时取消四个tagView的缩放, 平移、旋转不变
    /// - Parameter transform: self的transform
    private func tagsViewCancelTransform(transform: CGAffineTransform) {
        
        topLeftView.transform = self.transform.inverted()
        topRightView.transform = self.transform.inverted()
        bottomLeftView.transform = self.transform.inverted()
        bottomRightView.transform = self.transform.inverted()
    }
}

//MARK: 手势
extension GEBaseEditView {
    
    /// 点击View 获取焦点
    /// - Parameter sender: UITapGestureRecognizer
    @objc func tapHandle(_ sender: UITapGestureRecognizer) {
        if self.canBecomeFirstResponder && !self.isFirstResponder {
            let _ = self.becomeFirstResponder()
        }
        switch editType {
        case .IMAGE:
            self.continueEditImage()
        default:
            GEImageEditManager.shared.endEditStatus()
        }
    }
    
    @objc func doubleTapHandle(_ sender: UITapGestureRecognizer) {
        switch editType {
        case .IMAGE:
            self.editContentImage()
        default:
            break
        }
    }
    
    @objc func panHandle(_ sender: UIPanGestureRecognizer) {
        // 在父视图中的偏移量
        let translation = sender.translation(in: self.superview)
        if sender.state == .changed {
            self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
            //归零
            sender.setTranslation(CGPoint.zero, in: self.superview)
            viewModel.orgin = CGPoint(x: self.frame.origin.x - contentLayoutConstant, y: self.frame.origin.y - contentLayoutConstant)
        }
    }
    
    func distanceBetweenTwoPoint(point1: CGPoint, point2: CGPoint) -> Float {
        
        return sqrtf(powf(Float(point1.x - point2.x), 2) + powf(Float(point1.y - point2.y), 2))
    }
    
    func getRotateRadius(a: Float, b: Float) -> CGFloat {
        let result = (powf(a, 2) + powf(b, 2) - sqrtf(powf(a, 2) + powf(b, 2))) / 2 * a * b
        return CGFloat(cosf(result))
    }
    
    @objc func panRotateHandle(_ sender: UIPanGestureRecognizer) {
        let touchPoint:CGPoint = sender.location(in: self)
        let superTouchPoint = sender.location(in: self.superview)
        let centerPoint:CGPoint = self.center;
        let state = sender.state;
        switch state {
        case .began:
            let yDistance = touchPoint.y - centerPoint.y;
            let xDistance = touchPoint.x - centerPoint.x
            let radious =  atan2(yDistance, xDistance)
            oldRadius = radious
            rotateRadius = 0
            break
        case .changed:
            let yDistance = touchPoint.y - centerPoint.y;
            let xDistance = touchPoint.x - centerPoint.x
            let radious =  atan2(yDistance, xDistance)
            let movedRadious = radious - oldRadius

            if abs(centerPoint.x - superTouchPoint.x) < 50 && abs(centerPoint.y - superTouchPoint.y) < 50 {
                return
            }
            rotateRadius += movedRadious
            oldRadius = radious;
            self.transform = self.transform.rotated(by: rotateRadius)
            viewModel.rotate = rotateRadius
            break
        case.ended:
            break;
        default:
            break;
        }
    }
    
    @objc func panScaleHandle(_ sender: UIPanGestureRecognizer) {

        let location = sender.location(in: self)
        switch sender.state {
        case .began:
            panScaleBeginPoint = location
            break
        case .changed:
            let size = self.frame.size
            var scale: CGFloat = 0.0
            let changeX = location.x - panScaleBeginPoint.x
            let changeY = location.y - panScaleBeginPoint.y

            scale = (size.height + changeY) / size.height / 2
            scale += (size.width + changeX) / size.width / 2
            if size.width * scale < minImageWidth {
                scale = 1.0
            }
            self.transform = self.transform.scaledBy(x: scale, y: scale)
            viewModel.scale = scale
            self.tagsViewCancelTransform(transform: self.transform)
        default:
            break
        }
    }
    
    @objc func pinchHandle(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            if self.frame.size.width * sender.scale > minImageWidth {
                self.transform = self.transform.scaledBy(x: sender.scale, y: sender.scale)
                viewModel.scale = sender.scale
                self.tagsViewCancelTransform(transform: self.transform)
                sender.scale = 1
            }
        }
    }
    
    @objc func rotationHandle(_ sender: UIRotationGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            self.transform = self.transform.rotated(by: sender.rotation)
            viewModel.rotate = sender.rotation
            sender.rotation = 0.0
        }
    }
    
    
    @objc func deleteTapHandle(_ sender: UITapGestureRecognizer) {
        UIApplication.shared.delegate?.window??.becomeFirstResponder()
        self.superview?.resignFirstResponder()
        self.removeFromSuperview()
        UIApplication.shared.delegate?.window??.endEditing(true)
        
    }
    
    @objc func cropTapHandle(_ sender: UITapGestureRecognizer) {
        GEImageCropManager.shared.startImageCrop(image: contentView.image) { [weak self] (image) in
            guard let self = self else { return }
            let orignFrame = self.frame
            let imageSize = image.size
            let aspectRatio = imageSize.width / imageSize.height
            let size = CGSize(width: 300, height: 300 / aspectRatio)
            self.frame = CGRect(x: orignFrame.origin.x, y: orignFrame.origin.y, width: size.width, height: size.height)
            self.image = image
            self.viewModel.orginImage = image
            self.viewModel.currentImage = image
            let _ = self.becomeFirstResponder()
        }
    }
    
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension GEBaseEditView {
    /// 编辑图片
    private func editContentImage() {
        guard let model = self.viewModel else {
            return
        }
        GEImageEditManager.shared.startEditImage(viewModel: model) { (image, brightness, contrast) in
            DispatchQueue.main.async { [weak self] in
                self?.image = image
                self?.viewModel.currentImage = image
                if let brightness = brightness {
                    self?.viewModel.brightness = brightness
                }
                if let contrast = contrast {
                    self?.viewModel.contrast = contrast
                }
            }
        } resignFirst: { [weak self] in
            self?.resignActive()
        }
        // 当编辑框为第一响应者时，editView也需要边框)
        let _ = self.becomeFirstResponder()
    }
    
    /// 图片在编辑状态时切换BaseEditView主视图
    private func continueEditImage() {
        guard let model = self.viewModel else {
            return
        }
        GEImageEditManager.shared.continueEdit(viewModel: model) { (image, brightness, contrast) in
            DispatchQueue.main.async { [weak self] in
                self?.image = image
                self?.viewModel.currentImage = image
                if let brightness = brightness {
                    self?.viewModel.brightness = brightness
                }
                if let contrast = contrast {
                    self?.viewModel.contrast = contrast
                }
            }
        } resignFirst: { [weak self] in
            self?.resignActive()
        }
    }
}
