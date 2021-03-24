//
//  GEToolBar.swift
//  GraphicEditKit
//
//  Created by yulong mei on 2021/3/17.
//

import UIKit

class GEToolBarItem {
    var image: UIImage?
    var text: String?
    
    var selectedImage: UIImage?
    var selectedText: String?
    
    var textColor: UIColor?
    var selectedTextColor: UIColor?
    
    var itemWidth: CGFloat = 0.0
}

class GEToolBarCell: UIButton {
    var item: GEToolBarItem? {
        didSet {
            self.loadData()
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadData()
        self.loadView()
        self.layoutSubview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        guard let item = item else { return }
        self.setTitle(item.text, for: .normal)
        self.setTitle(item.selectedText, for: .selected)
        self.setTitleColor(item.textColor, for: .normal)
        self.setTitleColor(item.selectedTextColor, for: .selected)
        self.setImage(item.image, for: .normal)
        self.setImage(item.selectedImage, for: .selected)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        if item.text == "" {
            self.imagePosition(style: .right, spacing: 0)
        }else {
            self.imagePosition(style: .top, spacing: 0)
        }
        
    }
    
    func loadView() {
        
    }
    
    func layoutSubview() {

    }
}

class GEToolBar: UIView {

    private(set) var selectedIndex: Int? {
        didSet {
            
        }
    }
    var didSelectedCell: ((_ index: Int?) -> Void)?
    var shouldSelectedCell: ((_ index: Int?) -> Bool)?
    var items: [GEToolBarItem]? {
        didSet {
            self.loadData()
        }
    }
    var contentView: UIView?
    private lazy var backgroundView: UIView = {
        let image = UIImage.ge_bundle(named: "bg_tools")?.resizableImage(withCapInsets: UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20), resizingMode: UIImage.ResizingMode.stretch)
        let view = UIImageView(image: image)
        view.isUserInteractionEnabled = true
        return view
    }()

    private var currentCell: GEToolBarCell?
    public var currentIndex: Int? {
        get {
            return selectedIndex
        }
    }
    
    private var cells: [GEToolBarCell]? {
        didSet {
            self.layoutSubview()
        }
    }
    
    private lazy var bottomLineView: UIView = {
        let view = UIView()
        view.backgroundColor = GEThemeColor
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadView()
        self.loadData()
        self.layoutSubview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadData() {
        guard let items = items, items.count > 0 else { return }
        var newCells = [GEToolBarCell]()
        for item in items {
            let cell = GEToolBarCell()
            cell.item = item
            cell.addTarget(self, action: #selector(clickCell(cell:)), for: .touchUpInside)
            newCells.append(cell)
        }
        cells = newCells
        self.loadView()
    }
    
    func loadView() {
        for view in self.subviews { view.removeFromSuperview() }
        guard let cells = cells, cells.count > 0 else { return }
        self.addSubview(backgroundView)
        for cell in cells {
            backgroundView.addSubview(cell)
        }
        backgroundView.addSubview(bottomLineView)
    }
    
    func layoutSubview() {
        guard let items = items else { return }
        guard let cells = cells, cells.count > 0 else { return }
        backgroundView.frame = self.bounds
        var autoWidthCount: Int = 0
        var customWidth: CGFloat = 0

        for item in items {
            if item.itemWidth <= 0 {
                autoWidthCount = autoWidthCount + 1
            } else {
                customWidth = customWidth + item.itemWidth
            }
        }
        var width: CGFloat = (self.frame.width - customWidth) / CGFloat(autoWidthCount)
        let height: CGFloat = 48.0
        let y: CGFloat = 16.0
        for i in 0..<cells.count {
            let cell = cells[i]
            let item = items[i]
            let x: CGFloat = CGFloat(i) * width
            if item.itemWidth > 0 { width = item.itemWidth }
            cell.frame = CGRect(x: x, y: y, width: width, height: height)
        }
        
        if let cell = currentCell {
            let blHight: CGFloat = 2.0
            let blWidth: CGFloat = 20.0
            let y = y + height - blHight
            bottomLineView.frame = CGRect(x: 0, y: y, width: blWidth, height: blHight)
            bottomLineView.center = CGPoint(x: cell.center.x, y: bottomLineView.center.y)
            bottomLineView.isHidden = false
        } else {
            bottomLineView.isHidden = true
        }

    }

}

//MARK: Logic
extension GEToolBar {
    @objc func clickCell(cell:GEToolBarCell) {
        guard let index = cells?.firstIndex(of: cell) else { return }
        let isAllow: Bool = shouldSelectedCell?(index) ?? true
        guard isAllow else { return }
        currentCell?.isSelected = false
        if currentCell != cell {
            currentCell = cell
            currentCell?.isSelected = true
            selectedIndex = index
        } else {
            currentCell = nil
            selectedIndex = nil
        }
        didSelectedCell?(selectedIndex)
        self.layoutSubview()
    }
    
    func show(contentView: UIView, frame: CGRect) {
        self.contentView?.removeFromSuperview()
        self.contentView = contentView
        self.addSubview(contentView)
        contentView.frame = CGRect(x: 0, y: 64.0, width: frame.width, height: frame.height - 64.0)
        UIView.animate(withDuration: 0.3) {
            self.frame = frame
        }
    }
    
    func hide(frame: CGRect) {
        UIView.animate(withDuration: 0.3) {
            self.frame = frame
        } completion: { (isCompletion) in
            self.contentView?.removeFromSuperview()
            self.contentView = nil
        }
        cancelSelected()
    }
    
    func cancelSelected() {
        currentCell?.isSelected = false
        currentCell = nil
        selectedIndex = nil
        self.layoutSubview()
    }
    
    func hide() {
        cancelSelected()
        guard let content = self.contentView else {
            return
        }
        let contentHeight = content.frame.size.height
        var frame = self.frame
        frame.size.height -= contentHeight
        frame.origin.y += contentHeight
        UIView.animate(withDuration: 0.3) {
            self.frame = frame
        } completion: { (isCompletion) in
            self.contentView?.removeFromSuperview()
            self.contentView = nil
        }
    }
    
    func setSelected(index: Int) {
        guard let cell = cells?[index] else { return }
        currentCell?.isSelected = false
        if currentCell != cell {
            currentCell = cell
            currentCell?.isSelected = true
            selectedIndex = index
        } else {
            currentCell = nil
            selectedIndex = nil
        }
        didSelectedCell?(selectedIndex)
        self.layoutSubview()
    }
}
