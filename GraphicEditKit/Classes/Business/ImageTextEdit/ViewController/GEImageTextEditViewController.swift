//
//  GEImageTextEditViewController.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit
import MBProgressHUD
import IQKeyboardManagerSwift
import FlashHookKit

/// 图文编辑的类型
public enum GEImageTextAddType: Int {
    case Image = 2
    case QRCode = 3
    case BarCode = 4
}

public class GEImageTextEditViewController: GEBaseViewController {

    let toolHeight: CGFloat = 68.0
    let toolContentHeight: CGFloat = 193.0
    var toolTotalHeight: CGFloat = 0.0
    var toolShowStatusY: CGFloat = 0.0
    var toolHideStatusY: CGFloat = 0.0
    var maxHeight: CGFloat = 0.0
    
    var navHeight: CGFloat {
        get {
            return self.navigationController?.navigationBar.frame.height ?? 0.0
        }
    }
    private var startTime = Date()
    
    /// 文本编辑View
    private lazy var textEditView: GETextEditView = {
        let view = self.createTextEditView()
        return view
    }()
    
    /// 图片编辑View
    private lazy var imageEditView: GEImageEditView = {
        let view = self.loadImageEditView()
        return view
    }()
    
    /// 工具栏
    private lazy var toolBar: GEToolBar = {
        let view = GEToolBar()
        view.items = getToolItems()
        view.didSelectedCell = {[weak self, weak view] (index) in
            self?.toolBarSelected(index: index)
        }
        view.shouldSelectedCell = { [weak self] (index) in
            return self?.toolBarShouldSelected(index: index) ?? false
        }
        return view
    }()
    
    private lazy var imagePicker: UIImagePickerController = {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        return picker
    }()
    
    /// 背景画布，TextView
    private lazy var scrollTextView: GECanvasTextView = {
        let view = GECanvasTextView()
        view.placeholder = "ge.please_input".GE_Locale
        view.willBecomeFirstResponderClosure = { [weak self] in
            if !(self?.scrollTextView.isFirstResponder ?? false) {
                // 如果scrollTextView是第一响应者 则不需要收起键盘，调试时在iOS12手机上键盘弹起时
                UIApplication.shared.delegate?.window??.endEditing(true)
            }
        }
        view.resignFirstResponderClosure = { [weak self] in
            self?.removeTextViewInputView()
        }
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .white
        return view
    }()
    
    /// 锯齿View
    lazy var bgView: GEJaddedLayerView = {
        let view = GEJaddedLayerView()
        view.backgroundColor = GEBGColor
        return view
    }()
    
    public var addType: GEImageTextAddType?
    
    public override func viewDidLoad() {
        IQKeyboardManager.shared.disabledToolbarClasses = [GEImageTextEditViewController.self]
        super.viewDidLoad()
        self.loadSubview()
        self.loadData()
        self.layoutSubview()
        
        self.addObserver()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let type = self.addType {
            let _ = self.toolBarShouldSelected(index: type.rawValue)
            self.addType = nil
        }
    }
    
    override func ge_onLeftBarClick(_ sender: UIBarButtonItem) {
        UIApplication.shared.delegate?.window??.endEditing(true)
        if hasContent() {
            let alert = UIAlertController.init(title: "", message: "ge.Are_you_sure".GE_Locale, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "ge.sure".GE_Locale, style: .default) { [weak self](_) in
                self?.buriedPointEvent()
                self?.navigationController?.popViewController(animated: true)
            }
            let cancelAction = UIAlertAction.init(title: "ge.cancel".GE_Locale, style: .cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }else {
            self.buriedPointEvent()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /// 埋点
    private func buriedPointEvent() {
        let second = Calendar.current.dateComponents([.second], from: startTime, to: Date()).second
        FHAnalysis.shared.logEvent(event: .imageTextEditing_B0001(image_text_print_time: second ?? 0))
    }
        
//    public override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        IQKeyboardManager.shared.enable = false
//        IQKeyboardManager.shared.enableAutoToolbar = false
//    }
//
//    public override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = true
//    }
    
    func loadData() {
        toolTotalHeight = toolHeight + toolContentHeight
        toolShowStatusY = self.view.bounds.height - toolTotalHeight - self.navHeight() - self.statusBarHeight() - self.safeWindowAreaInsetsBottom()
        toolHideStatusY = self.view.bounds.height - toolHeight - self.navHeight() - self.statusBarHeight() - self.safeWindowAreaInsetsBottom()
        maxHeight = UIScreen.main.bounds.size.height * 15
    }
    
    func loadSubview() {
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "ge.Image-Text_printing".GE_Locale
        self.ge_createLeftButtonWithImageName("icon_nav_back", target: self)
        self.createRightBarItems()
        self.view.backgroundColor = GEBGColor
        self.view.addSubview(bgView)
        bgView.addSubview(scrollTextView)
        GEImageEditManager.shared.toolBar = toolBar
        GETextStyleEditManager.shared.toolBar = toolBar
        self.view.addSubview(toolBar)
    }
    
    func layoutSubview() {
        toolBar.frame = CGRect(x: 0, y: toolHideStatusY, width: self.view.bounds.width, height: toolHeight)
        
        bgView.snp.makeConstraints { (make) in
            make.top.left.equalTo(10)
            make.right.equalTo(-10)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-(toolHeight - 20))
            }else{
                make.bottom.equalTo(self.bottomLayoutGuide.snp.bottom).offset(-(toolHeight - 20))
            }
        }
        
        scrollTextView.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
            make.left.right.equalToSuperview()
        }
    }
    
    private func createRightBarItems() {
        
        let barItem1 = UIBarButtonItem.init(image: UIImage.ge_bundle(named: "icon_nav_print_default")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(preview))
        let barItem2 = UIBarButtonItem.init(image: UIImage.ge_bundle(named: "icon_nav_delete_default")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(clearAllContent))
        self.navigationItem.rightBarButtonItems = [barItem1, barItem2]
    }
    
    @objc private func clearAllContent() {
        if hasContent() {
            let alert = UIAlertController.init(title: "", message: "ge.Are_you_sure_clear".GE_Locale, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "ge.sure".GE_Locale, style: .default) { [weak self](_) in
                self?.scrollTextView.text = ""
                let _ = self?.scrollTextView.subviews.map{
                    if $0 is GEBaseEditView {
                        $0.removeFromSuperview()
                    }
                }
            }
            let cancelAction = UIAlertAction.init(title: "ge.cancel".GE_Locale, style: .cancel, handler: nil)
            alert.addAction(action)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    /// 是否绘制或者输入内容
    /// - Returns: Bool
    private func hasContent() -> Bool {
        var hasSubContent = false
        for view in scrollTextView.subviews {
            if view is GEBaseEditView {
                hasSubContent = true
            }
        }
        if scrollTextView.text.isEmpty && !hasSubContent {
            return false
        }else {
            return true
        }
    }
    
    public func showHUD(_ detail: String)  {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.mode = .text
        hud.label.text = nil
        hud.detailsLabel.text = detail
        hud.hide(animated: true, afterDelay: 1.5)
    }
    
    /// 打印预览
    @objc private func preview() {
        UIApplication.shared.delegate?.window??.endEditing(true)
        if self.scrollTextView.isFirstResponder {
            let _ = self.scrollTextView.resignFirstResponder()
        }
        self.scrollTextView.placeholder = ""
        if !hasContent() {
            showHUD("ge.Content_cannot_be_empty".GE_Locale)
            return
        }
        guard let image = screenShot() else {  return }
        let vc = GEPrintPreviewViewController()
        vc.image = image
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// 工具栏BarItem
    /// - Returns: [GEToolBarItem]
    private func getToolItems() -> [GEToolBarItem] {
        let item0 = GEToolBarItem()
        item0.text = "ge.text".GE_Locale
        item0.selectedText = "ge.text".GE_Locale
        item0.image = UIImage.ge_bundle(named: "icon_tool_text_default")
        item0.selectedImage = UIImage.ge_bundle(named: "icon_tool_text_selected")
        item0.textColor = UIColor.gray
        item0.selectedTextColor = GEThemeColor
        
        let item1 = GEToolBarItem()
        item1.text = "ge.text_box".GE_Locale
        item1.selectedText = "ge.text_box".GE_Locale
        item1.image = UIImage.ge_bundle(named: "icon_tool_textbox_default")
        item1.selectedImage = UIImage.ge_bundle(named: "icon_tool_textbox_selected")
        item1.textColor = UIColor.gray
        item1.selectedTextColor = GEThemeColor

        let item2 = GEToolBarItem()
        item2.text = "ge.picture".GE_Locale
        item2.selectedText = "ge.picture".GE_Locale
        item2.image = UIImage.ge_bundle(named: "icon_tool_img_default")
        item2.selectedImage = UIImage.ge_bundle(named: "icon_tool_img_selected")
        item2.textColor = UIColor.gray
        item2.selectedTextColor = GEThemeColor

        let item3 = GEToolBarItem()
        item3.text = "ge.QR_code".GE_Locale
        item3.selectedText = "ge.QR_code".GE_Locale
        item3.image = UIImage.ge_bundle(named: "icon_tool_qrcode_default")
        item3.selectedImage = UIImage.ge_bundle(named: "icon_tool_qrcode_selected")
        item3.textColor = UIColor.gray
        item3.selectedTextColor = GEThemeColor

        let item4 = GEToolBarItem()
        item4.text = "ge.Bar_code".GE_Locale
        item4.selectedText = "ge.Bar_code".GE_Locale
        item4.image = UIImage.ge_bundle(named: "icon_tool_barcode_default")
        item4.selectedImage = UIImage.ge_bundle(named: "icon_tool_barcode_selected")
        item4.textColor = UIColor.gray
        item4.selectedTextColor = GEThemeColor
        
        let item5 = GEToolBarItem()
        item5.text = ""
        item5.selectedText = ""
        item5.image = UIImage.ge_bundle(named: "icon_tool_close_selected")
        item5.selectedImage = UIImage.ge_bundle(named: "icon_tool_close_selected")
        item5.textColor = UIColor.gray
        item5.selectedTextColor = GEThemeColor
        let width = item5.image?.size.width ?? 0.0
        item5.itemWidth = width > 0 ? width + 15 : width
        return [item0,item1,item2,item3,item4,item5]
    }
    
    public func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    public func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        self.removeObserver()
//        GEPrintService.shared.releasePrinter()
    }
    
    public override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// 截图
    /// - Returns: Image
    public func screenShot() -> UIImage? {
        let currentOffset = scrollTextView.contentOffset
        var maxSize = scrollTextView.getMaxContentSize()
        if maxSize.height > maxHeight {
            self.overHeightAlert()
            return nil
        }
        maxSize.height = CGFloat(ceilf(Float(maxSize.height)))
        scrollTextView.contentOffset = .zero
        scrollTextView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.height.equalTo(maxSize.height)
            make.left.right.equalToSuperview()
        }
        self.view.updateConstraintsIfNeeded()
        self.view.layoutIfNeeded()
        
        UIGraphicsBeginImageContextWithOptions(maxSize, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.clear(CGRect(x: 0, y: 0, width: maxSize.width, height: maxSize.height))
        context.setFillColor(UIColor.red.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: maxSize.width, height: maxSize.height))
        if #available(iOS 13, *) {
            let tempView = UIView(frame: CGRect(x: 0, y: 0, width: maxSize.width, height: maxSize.height))
            tempView.addSubview(scrollTextView)
            tempView.layer.render(in: context)
            tempView.removeFromSuperview()
            bgView.addSubview(scrollTextView)
        } else {
            scrollTextView.layer.render(in: context)
        }
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        scrollTextView.contentOffset = currentOffset
        scrollTextView.snp.remakeConstraints { (make) in
            make.top.equalTo(5)
            make.bottom.equalTo(-5)
            make.left.right.equalToSuperview()
        }
        return image
    }
    
    private func scaleToSize(img: UIImage, width: CGFloat, scale: CGFloat = UIScreen.main.scale) -> UIImage {
        let orginSize = img.size
        let WHScale = orginSize.width / orginSize.height
        let newHeight = width / WHScale
        let newSize = CGSize(width: width, height: newHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        img.draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg ?? img
    }
    
    private func overHeightAlert() {
        let alert = UIAlertController.init(title: "", message: "ge.If_you_input_content".GE_Locale, preferredStyle: .alert)
        let action = UIAlertAction.init(title:"ge.sure".GE_Locale, style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }

}

//MARK: TextViewInputView设置、工具栏内容控制、工具栏按钮事件
extension GEImageTextEditViewController {
    
    /// ToolBar 选中事件
    /// - Parameter index: Index
    private func toolBarSelected(index: Int?) {
        if let index = index, index == 0 || index == 1 || index == 2 {
            var contentView: UIView
            switch index {
            case 0:
                if self.scrollTextView.isFirstResponder {
                    self.scrollTextView.inputView = nil
                }
                contentView = self.textEditView
                self.setTextViewInputView()
            case 1:
                contentView = GETextStyleEditManager.shared.textBoxEditView()
                self.showToolBarContent(content: contentView)
            case 2:
                contentView = self.imageEditView
                self.imageEditView.brightness = GEImageEditManager.shared.getBrightness()
                self.imageEditView.contrast = GEImageEditManager.shared.getContrast()
                self.showToolBarContent(content: contentView)
            default:
                break
            }
        } else {
            if self.scrollTextView.isFirstResponder {
                let _ = self.scrollTextView.resignFirstResponder()
            }
            self.hideToolBarContent()
            GEImageEditManager.shared.active = false
        }
    }
    
    /// ToolBar 是否允许选中
    /// - Parameter index: Index
    /// - Returns: Result
    private func toolBarShouldSelected(index: Int?) -> Bool {
        if index == 0 { return true }
        if self.scrollTextView.isFirstResponder {
            let _ = self.scrollTextView.resignFirstResponder()
        }
        switch index {
        case 1:
            self.addTextBox()
        case 2:
            if GEImageEditManager.shared.active {
                return true
            }else {
                self.chooseImage()
                return false
            }
        case 3:
            self.addQRView()
        case 4:
            self.addBarView()
        default:
            break
        }
        self.hideToolBarContent()
        GEImageEditManager.shared.active = false
        return false
    }
    
    /// 获取当前编辑的位置
    private func getEditLocation() {
        var editViewFrame: CGRect = .zero
        for view in scrollTextView.subviews {
            if view is GEBaseEditView {
                if view.isFirstResponder {
                    editViewFrame = view.frame
                }
            }
        }
        let contentOffsetY = scrollTextView.contentOffset.y
        if editViewFrame.maxY > contentOffsetY + scrollTextView.frame.height {
            let offsetY = editViewFrame.maxY - (scrollTextView.bounds.height + contentOffsetY)  + contentOffsetY
            let offset = CGPoint(x: 0, y: offsetY)
            self.scrollTextView.setContentOffset(offset, animated: true)
        }
    }
    
    private func setTextViewInputView() {
        let _ = self.scrollTextView.resignFirstResponder()
        UIView.animate(withDuration: 0.1) {
            self.textEditView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.toolContentHeight)
            self.scrollTextView.inputView = self.textEditView
            let _ = self.scrollTextView.becomeFirstResponder()
        }
    }
    
    private func removeTextViewInputView() {
        let _ = self.scrollTextView.resignFirstResponder()
        self.textEditView.frame = .zero
        self.scrollTextView.inputView = nil
        toolBar.frame = CGRect(x: 0, y: toolHideStatusY, width: self.view.bounds.width, height: toolHeight)
        self.view.addSubview(toolBar)
        let _ = self.scrollTextView.resignFirstResponder()
    }
    
    /// 弹出工具栏内容
    /// - Parameter content: 工具栏展示内容
    private func showToolBarContent(content: UIView) {
        toolBar.show(contentView: content, frame: CGRect(x: 0, y: toolShowStatusY, width: self.view.bounds.width, height: toolTotalHeight))
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.scrollTextView.snp.remakeConstraints { (make) in
                make.top.equalTo(5)
                make.bottom.equalTo(self?.toolBar.snp.top ?? -5)
                make.left.right.equalToSuperview()
            }
        } completion: { [weak self] (_) in
            self?.scrollTextView.updateConstraints()
            self?.view.layoutIfNeeded()
            self?.getEditLocation()
        }

    }
    
    /// 隐藏工具栏
    private func hideToolBarContent() {
        if self.scrollTextView.inputView == self.textEditView {
            self.removeTextViewInputView()
        }else {
            toolBar.hide(frame: CGRect(x: 0, y: toolHideStatusY, width: self.view.bounds.width, height: toolHeight))
            UIView.animate(withDuration: 0.3) {  [weak self] in
                self?.scrollTextView.snp.remakeConstraints { (make) in
                    make.top.equalTo(5)
                    make.bottom.equalTo(-5)
                    make.left.right.equalToSuperview()
                }
            }
        }
    }
    
    /// 添加文本框
    @objc func addTextBox() {
        
        let size = CGSize(width: 200,height: 80)
        let frame = scrollTextView.getContentBottomPoint(size: size)
        if frame.maxY > maxHeight {
            self.overHeightAlert()
            return
        }
        let view = GEBaseTextEditView(frame:  frame,type: .TEXT)
        self.scrollTextView.addSubview(view)
        let _ = view.becomeFirstResponder()
    }
    
    /// 选择图片
    @objc func chooseImage() {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    /// 添加QRCode
    @objc func addQRView() {
        GETextInputManager.shared.startInputText(text: "", inputType: .QRCode, done: { [weak self](text) in
            if !text.isEmpty {
                self?.createQRCode(text: text)
            }
        }, resignFirst: {})
    }
    
    /// 添加BarCode
    @objc func addBarView() {
        GETextInputManager.shared.startInputText(text: "", inputType: .BarCode, done: { [weak self](text) in
            if !text.isEmpty {
                self?.createBarCode(text: text)
            }
        }, resignFirst: {})
    }
    
    func addImageFromLibary(image: UIImage) {
        let scaleImage = scaleToSize(img: image, width: 300)
        let aspectRatio = scaleImage.size.width / scaleImage.size.height
        let size = CGSize(width: 300, height: 300 / aspectRatio)
        let frame = scrollTextView.getContentBottomPoint(size: size)
        if frame.maxY > maxHeight {
            self.overHeightAlert()
        }else {
            let view = GEBaseEditView(frame:  frame,type: .IMAGE)
            view.image = scaleImage
            self.scrollTextView.addSubview(view)
            let _ = view.becomeFirstResponder()
        }
    }
    
    func createBarCode(text: String) {
        let barSize = CGSize(width: 320, height: 150)
        let image = GECodeTool.BarCodeWithTitle(code: text, size: barSize)
        let aspectRatio = image.size.width / image.size.height
        let size = CGSize(width: 320, height: 320 / aspectRatio)
        let frame = scrollTextView.getContentBottomPoint(size: size)
        if frame.maxY > maxHeight {
            self.overHeightAlert()
        }else {
            let view = GEBaseEditView(frame:  frame,type: .BAR_CODE)
            view.image = image
            self.scrollTextView.addSubview(view)
            let _ = view.becomeFirstResponder()
        }
    }
    
    func createQRCode(text: String) {
        let image = GECodeTool.QRCode(QRContent: text, QRImageSize: 300)
        let aspectRatio = image.size.width / image.size.height
        let size = CGSize(width: 320, height: 320 / aspectRatio)
        let frame = scrollTextView.getContentBottomPoint(size: size)
        if frame.maxY > maxHeight {
            self.overHeightAlert()
        }else {
            let view = GEBaseEditView(frame:  frame,type: .QR_CODE)
            view.image = image
            self.scrollTextView.addSubview(view)
            let _ = view.becomeFirstResponder()
        }
    }
}

//MARK: UIImagePicker Delegate
extension GEImageTextEditViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
                self?.addImageFromLibary(image: image)
            }
        }
    }
    
}


// MARK: 键盘监听 控制工具栏高度
extension GEImageTextEditViewController {

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        if let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            if self.scrollTextView.isFirstResponder {
                let frame = self.toolBar.frame
                let newFrame = CGRect(x: 0, y: toolHideStatusY - keyboardRect.size.height + safeWindowAreaInsetsBottom(), width: frame.width, height: frame.height)
                UIView.animate(withDuration: 0.2) { [weak self] in
                    self?.toolBar.frame = newFrame
                    self?.scrollTextView.snp.remakeConstraints { (make) in
                        make.top.equalTo(5)
                        make.bottom.equalTo(self?.toolBar.snp.top ?? -5)
                        make.left.right.equalToSuperview()
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let rect = CGRect(x: 0, y: toolHideStatusY, width: view.bounds.width, height: toolHeight)
        UIView.animate(withDuration: 0.2) {  [weak self] in
            self?.toolBar.frame = rect
            self?.scrollTextView.snp.remakeConstraints { (make) in
                make.top.equalTo(5)
                make.bottom.equalTo(-5)
                make.left.right.equalToSuperview()
            }
        }
    }
    
    private func keyboardHidden() {
        self.removeObserver()
    }
}

// MARK: Text Style Handle
extension GEImageTextEditViewController {
    
    private func createTextEditView() -> GETextEditView {
        let editTextView = GETextEditView(frame: .zero)
        editTextView.textFontSizeChanged = { [weak self](size) in
            self?.fontSizeChange(size)
        }
        editTextView.textStyleChanged = { [weak self] (style, isSelected) in
            self?.textStyleChange(style, isSelected)
        }
        editTextView.textHeadIndentChanged = { [weak self] (size) in
            self?.textHeadIndentChange(size)
        }
        editTextView.textAlignmentChanged = { [weak self] (alignment) in
            self?.textAlignmentChange(alignment)
        }
        editTextView.textLineSpacingChanged = { [weak self] (spacing) in
            self?.textLineSpacingChange(spacing)
        }
        return editTextView
    }
    
    private func fontSizeChange(_ size: CGFloat) {
        guard let (editRange, selectedRange) = getEditRange() else { return }
        guard let attri = self.scrollTextView.attributedText else { return }
        let mutable = GETextService.setAttributedString(attri, fontSize: size, range: editRange)
        self.scrollTextView.attributedText = mutable
        if selectedRange.length > 0 {
            self.scrollTextView.selectedRange = selectedRange
        }
    }
    
    private func textStyleChange(_ style: GETextStyleEditView.TextStyle, _ isSelected: Bool) {
        guard let (editRange, selectedRange) = getEditRange() else { return }
        guard let attri = self.scrollTextView.attributedText else { return }
        var mutable: NSAttributedString
        switch style {
        case .bold:
            mutable = GETextService.setAttributedString(attri, isBold: isSelected, range: editRange)
        case .obliqueness:
            mutable = GETextService.setAttributedString(attri, isObliqueness: isSelected, range: editRange)
        case .strikethrough:
            mutable = GETextService.setAttributedString(attri, isStrikethrough: isSelected, range: editRange)
        case .underline:
            mutable = GETextService.setAttributedString(attri, isUnderline: isSelected, range: editRange)
        }
        self.scrollTextView.attributedText = mutable
        if selectedRange.length > 0 {
            self.scrollTextView.selectedRange = selectedRange
        }
    }
    
    private func textHeadIndentChange(_ size: CGFloat) {
        guard let (editRange, selectedRange) = getEditRange() else { return }
        guard let attri = self.scrollTextView.attributedText else { return }
        let mutable = GETextService.setAttributedString(attri, headIndent: size, range: editRange)
        self.scrollTextView.attributedText = mutable
        if selectedRange.length > 0 {
            self.scrollTextView.selectedRange = selectedRange
        }
    }
    
    private func textAlignmentChange(_ alignment: NSTextAlignment) {
        guard let (editRange, selectedRange) = getEditRange() else { return }
        guard let attri = self.scrollTextView.attributedText else { return }
        let mutable = GETextService.setAttributedString(attri, alignment: alignment, range: editRange)
        self.scrollTextView.attributedText = mutable
        if selectedRange.length > 0 {
            self.scrollTextView.selectedRange = selectedRange
        }
    }
    
    private func textLineSpacingChange(_ lineSpacing: CGFloat) {
        guard let (editRange, selectedRange) = getEditRange() else { return }
        guard let attri = self.scrollTextView.attributedText else { return }
        let mutable = GETextService.setAttributedString(attri, lineSpacing: lineSpacing, range: editRange)
        self.scrollTextView.attributedText = mutable
        if selectedRange.length > 0 {
            self.scrollTextView.selectedRange = selectedRange
        }
    }
    
    /// 获取编辑Range
    /// - Returns: （编辑Range, 当前选中的Range）
    private func getEditRange() -> (NSRange, NSRange)? {
        if self.scrollTextView.text.count < 1 {
            return nil
        }
        let range: NSRange = self.scrollTextView.selectedRange
        var targetRange: NSRange = range
        if targetRange.length < 1 {
            targetRange = NSRange(location: 0, length: self.scrollTextView.text.utf16.count)
        }
        return (targetRange,range)
    }
}

//MARK: Image 编辑 Handel
extension GEImageTextEditViewController {
    
    private func loadImageEditView() -> GEImageEditView {
        let imageEditView = GEImageEditView(frame: .zero)
        imageEditView.brightnessChangedClosure = { [weak self] (brightness) in
            self?.brightnessChanged(brightness)
        }
        imageEditView.contrastChangedClosure = { [weak self] (contrast) in
            self?.contrastChanged(contrast)
        }
        return imageEditView
    }
    
    /// 亮度
    /// - Parameter brightness: 亮度
    private func brightnessChanged(_ brightness: Float) {
        GEImageEditManager.shared.editImageEnd(brightness: brightness, contrast: nil)
    }
    
    /// 对比度
    /// - Parameter contrast: 对比度
    private func contrastChanged(_ contrast: Float) {
        GEImageEditManager.shared.editImageEnd(brightness: nil, contrast: contrast)
    }
}
