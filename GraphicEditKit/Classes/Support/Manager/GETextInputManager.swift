//
//  GETextInputManager.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import Foundation

//MARK: 文字框输入时键盘和文字处理,维护一个单例，管理多个FTPEditContentView的文字输入
class GETextInputManager {

    public var inputType: GEInputType = .Text {
        didSet{
            textInputView.inputType = inputType
        }
    }
    
    public lazy var textInputView: GEKeyboardInputView = {
        let view = GEKeyboardInputView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: 70), inputType: inputType)
        view.inputType = inputType
        view.confirmClosure = { [weak self](text) in
            self?.inputDone(text: text)
        }
        view.resignFirstClosure = { [weak self] in
            self?.resignFirst()
        }
        return view
    }()
    
    // 定义输入回调处理
    typealias InputDoneHandler = (String) -> Void
    var inputDoneHandler: InputDoneHandler?
    
    // 定义输入回调处理
    typealias ResignFirstHandler = () -> Void
    var resignFirstHandler: ResignFirstHandler?
    
    static let shared = GETextInputManager()
    
    init() {}
    
    public func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillhiden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    public func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 键盘弹出将要输入 当输入框为第一响应者时，editContentView也需要边框
    /// - Parameter view: 触发出入的ContentView
    public func startInputText(text: String, inputType: GEInputType, done: @escaping InputDoneHandler, resignFirst: @escaping ResignFirstHandler) {
        self.inputDoneHandler = done
        if let resignhadler = self.resignFirstHandler {
            resignhadler()
        }
        self.resignFirstHandler = resignFirst
        self.inputType = inputType
        
        self.addObserver()
        UIApplication.shared.delegate?.window??.addSubview(textInputView)
        textInputView.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
        }
        textInputView.text = text ==  "ge.Double_click".GE_Locale ? "" : text
    }

    /// 点击确定 输入结束
    /// - Parameter text: 输入的内容
    public func inputDone(text: String) {
        self.inputDoneHandler?(text)
        textInputView.removeFromSuperview()
        self.removeObserver()
    }
    
    /// 被动结束输入，即点击其他模块和视图 （包括单击self.editContentView），editContentView会统一resignFirst
    /// 当单击self.editContentView，editContentView会先resignFirst，再becomeFirst
    public func resignFirst() {
        self.resignFirstHandler?()
        self.removeObserver()
        UIView.animate(withDuration: 0.3) {
            self.textInputView.transform = CGAffineTransform.init(translationX: 0, y: 0)
        }
        textInputView.removeFromSuperview()
    }
}

// MARK: 键盘监听 控制输入框高度
extension GETextInputManager{

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            UIView.animate(withDuration: 0.5) {
                self.textInputView.transform = CGAffineTransform.init(translationX: 0, y: -keyboardRect.size.height)
            }
        }
    }
    
    @objc func keyboardWillhiden(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        if let _ = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            UIView.animate(withDuration: 0.5) {
                self.textInputView.transform = CGAffineTransform.init(translationX: 0, y: 0)
            }
        }
    }
}
