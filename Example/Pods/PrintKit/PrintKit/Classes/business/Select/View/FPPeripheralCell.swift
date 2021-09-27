//
//  FPPeripheralCell.swift
//  flashprint
//
//  Created by yulong mei on 2021/3/2.
//

import UIKit

class FPPeripheralCell: FP_BaseeTableViewCell {

    public var title: String? {
        didSet{
            titleLabel.text = title
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        loadSubView()
        layoutSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadSubView() {
        self.backgroundColor = .white
        contentView.addSubview(titleLabel)
    }
    
    private func layoutSubview() {
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.top.equalTo(8)
            make.bottom.equalTo(-8)
        }
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = FPMainTitleColor
        label.text = "---"
        return label
    }()
}
