//
//  GEPrintPreviewOperationView.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit

class GEPrintPreviewOperationView: UIView {

    var items: [String]? {
        didSet {
            self.loadData()
            self.loadView()
        }
    }
    var title: String? {
        didSet {
            self.titleLabel.text = title
        }
    }
    var itemSize: CGSize = CGSize.zero
    var itemSpacing: CGFloat = 16.0
    var selectedIndex: Int? {
        didSet {
            guard let cells = self.cells, let index = selectedIndex, index < cells.count else { return }
            self.clickButton(button: cells[index])
        }
    }
    var clickItem: ((_ index: Int) -> Void)?
    
    private var selectedButton: UIButton?
    private var cells: [UIButton]?
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 12)
        view.textColor = UIColor(red: 0.19, green: 0.19, blue: 0.20, alpha: 1)
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        guard let items = items else { return }
        var array :[UIButton] = []
        for item in items {
            array.append(self.getButton(title: item))
        }
        cells = array

    }
    
    func loadView() {
        for view in self.subviews { view.removeFromSuperview() }
        guard let cells = cells else { return }
        self.addSubview(titleLabel)
        for cell in cells {
            self.addSubview(cell)
        }
    }
    
    func layoutSubview() {
        titleLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 18)
        guard let cells = cells else { return }
        for i in 0..<cells.count {
            let x: CGFloat = (itemSpacing + itemSize.width) * CGFloat(i)
            let y: CGFloat = 8 + 18
            let button = cells[i]
            button.frame = CGRect(x: x, y: y, width: itemSize.width, height: itemSize.height)
        }
    }
}

//MARK: Logic
extension GEPrintPreviewOperationView {
    private func getButton(title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(GEThemeColor, for: .normal)
        button.setTitleColor(.white, for: .selected)
        let normalImage = UIImage.ge_createImage(color: .white)?.resizableImage(withCapInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), resizingMode: UIImage.ResizingMode.stretch)
        let selectedImage = UIImage.ge_createImage(color: GEThemeColor)?.resizableImage(withCapInsets: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8), resizingMode: UIImage.ResizingMode.stretch)
        button.setBackgroundImage(normalImage, for: .normal)
        button.setBackgroundImage(selectedImage, for: .selected)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = GEThemeColor.cgColor
        button.addTarget(self, action: #selector(clickButton(button:)), for: .touchUpInside)
        return button
    }
    
    @objc private func clickButton(button:UIButton) {
        guard selectedButton != button else { return }
        guard let cells = cells, let index = cells.firstIndex(of: button) else { return }
        selectedButton?.isSelected = false
        selectedButton = button
        selectedButton?.isSelected = true
        selectedIndex = index
        self.clickItem?(index)
    }
}
