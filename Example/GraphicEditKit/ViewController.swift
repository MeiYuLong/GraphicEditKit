//
//  ViewController.swift
//  GraphicEditKit
//
//  Created by longjiao914@126.com on 03/16/2021.
//  Copyright (c) 2021 longjiao914@126.com. All rights reserved.
//

import UIKit
import GraphicEditKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func go2GraphicEdit(_ sender: Any) {
        
        let graphicEdit = GEImageTextEditViewController()
        self.navigationController?.pushViewController(graphicEdit, animated: true)
    }
    
    @IBAction func qrCodeAction(_ sender: Any) {
        let graphicEdit = GEImageTextEditViewController()
        graphicEdit.addType = .QRCode
        self.navigationController?.pushViewController(graphicEdit, animated: true)
    }
    
    @IBAction func imageAction(_ sender: Any) {
        let graphicEdit = GEImageTextEditViewController()
        graphicEdit.addType = .Image
        self.navigationController?.pushViewController(graphicEdit, animated: true)
    }
    
    @IBAction func barCodeAction(_ sender: Any) {
        let graphicEdit = GEImageTextEditViewController()
        graphicEdit.addType = .BarCode
        self.navigationController?.pushViewController(graphicEdit, animated: true)
    }
    
}

