//
//  ViewDetailInfo.swift
//  xia4ipad
//
//  Created by Guillaume on 18/11/2015.
//  Copyright © 2015 Guillaume. All rights reserved.
//

import UIKit

class ViewDetailInfos: UIViewController {
    
    var dbg = debug(enable: true)
    
    var tag: Int = 0
    var zoom: Bool = false
    var lock: Bool = false
    var detailTitle: String = ""
    var detailDescription: String = ""
    var xml: AEXMLDocument = AEXMLDocument()
    var index: Int = 0
    var fileName: String = ""
    var filePath: String = ""
    weak var viewPhotoController: ViewPhoto?

    @IBOutlet weak var btnZoom: UISwitch!
    @IBOutlet weak var btnLock: UISwitch!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    
    @IBAction func btnCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnDone(sender: AnyObject) {
        // Save the detail in xml
        if let detail = xml["xia"]["details"]["detail"].allWithAttributes(["tag" : "\(tag)"]) {
            for d in detail {
                d.attributes["zoom"] = "\(btnZoom.on)"
                d.attributes["locked"] = "\(btnLock.on)"
                d.attributes["title"] = txtTitle.text
                d.value = txtDesc.text
            }
        }
        let _ = writeXML(xml, path: "\(filePath).xml")
        viewPhotoController?.details["\(tag)"]?.locked = btnLock.on
        btnLock.resignFirstResponder()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add border to description
        
        txtDesc.layer.borderWidth = 1
        txtDesc.layer.cornerRadius = 5
        txtDesc.layer.borderColor = UIColor.grayColor().CGColor
        
        btnZoom.setOn(self.zoom, animated: true)
        btnLock.setOn(self.lock, animated: true)
        txtTitle.text = self.detailTitle
        txtDesc.text = self.detailDescription
        
        // autofocus
        txtTitle.becomeFirstResponder()
        txtTitle.backgroundColor = UIColor.clearColor()
        
        // Avoid keyboard to mask bottom

        let width: CGFloat = UIScreen.mainScreen().bounds.width - 100
        var height: CGFloat = UIScreen.mainScreen().bounds.height / 2
        height -= (UIDevice.currentDevice().orientation.rawValue < 2) ? 100 : 20
        self.preferredContentSize = CGSizeMake(width, height)
        
    }
    
}
