//
//  GEButton.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/5/31.
//

import UIKit

class GEButton: UIButton {

    var action: GEAlertAction?
    {
        didSet {
            guard let action = action else { return }
            switch action.style {
            case .cancel:
                isSelected = false
            case .confirm:
                isSelected = true
            case .delete:
                isSelected = true
                self.layer.borderColor = GEDeleteRedColor.cgColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setTitleColor(.white, for: .selected)
        self.setTitleColor(GEThemeColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        self.layer.borderWidth = 1
        self.layer.borderColor = GEThemeColor.cgColor
    }
    
    override var isSelected: Bool {
        didSet{
            var selectedColor = GEThemeColor
            if let action = action, action.style == .delete {
                selectedColor = GEDeleteRedColor
            }
            self.backgroundColor = isSelected ? selectedColor : .white
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
