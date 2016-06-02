//
//  Util.swift
//  xia4ipad
//
//  Created by Guillaume on 07/12/2015.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>
//
//
//  @author : guillaume.barre@ac-versailles.fr
//

import UIKit

func buildShape(fill: Bool, color: UIColor, tag: Int, points: [Int: UIImageView], parentView: AnyObject, ellipse: Bool = false, locked: Bool = false) {
    var shapeArg: Int = 0
    let shapeTag = tag + 100
    if fill {
        shapeArg = (ellipse) ? 3 : 1
    }
    else {
        shapeArg = (ellipse) ? 2 : 0
    }
    var xMin: CGFloat = UIScreen.mainScreen().bounds.width
    var xMax: CGFloat = 0
    var yMin: CGFloat = UIScreen.mainScreen().bounds.height
    var yMax: CGFloat = 0
    // Get dimensions of the shape
    for subview in parentView.subviews {
        if subview.tag == tag {
            let xMinSubview = subview.frame.origin.x
            let yMinSubview = subview.frame.origin.y
            let xMaxSubview = subview.frame.origin.x + 10
            let yMaxSubview = subview.frame.origin.y + 10
            if ( xMinSubview < xMin ) {
                xMin = xMinSubview
            }
            if ( yMinSubview < yMin ) {
                yMin = yMinSubview
            }
            if ( xMaxSubview > xMax ) {
                xMax = xMaxSubview
            }
            if ( yMaxSubview > yMax ) {
                yMax = yMaxSubview
            }
        }
    }
    let shapeFrame = CGRectMake(xMin, yMin, xMax - xMin, yMax - yMin)
    
    // Build the shape
    let myView = ShapeView(frame: shapeFrame, shape: shapeArg, points: points, color: color)
    myView.backgroundColor = UIColor(white: 0, alpha: 0)
    myView.tag = shapeTag
    parentView.addSubview(myView)
    
    // Shape is locked ?
    if locked {
        let lock = UIImage(named: "lock")
        let lockView = UIImageView(image: lock!)
        lockView.center = CGPointMake(shapeFrame.midX, shapeFrame.midY)
        lockView.tag = shapeTag
        lockView.layer.zPosition = 105
        lockView.alpha = 0.5
        parentView.addSubview(lockView)
    }
}

func checkXML (xml: AEXMLDocument) -> AEXMLDocument {
    for child in xml["xia"].all! {
        // Look for readonly child
        if let readonly = child["readonly"].value {
            if (readonly != "true" && readonly != "false") {
                xml["xia"].addChild(name: "readonly", value: "false", attributes: ["code" : "1234"])
            }
        }
        // Look for image child (to store image title & description)
        if child["image"].attributes["title"] == nil {
            xml["xia"].addChild(name: "image", value: "", attributes: ["title" : "", "desctription" : ""])
        }
        // Look for the default show details attributes
        if child["details"].attributes["show"] == nil {
            xml["xia"]["details"].attributes["show"] = "true"
        }
            
    }
    if let xmlDetails = xml["xia"]["details"]["detail"].all {
        for detail in xmlDetails {
            if detail.attributes["locked"] == nil {
                detail.attributes["locked"] = "false"
            }
        }
    }
    
    for element in xmlElements {
        if (xml["xia"][element].value != nil && xml["xia"][element].value! == "element <\(element)> not found") {
            xml["xia"].addChild(name: element)
            if (element == "creator" && xml["xia"]["author"].value != nil) {
                xml["xia"][element].value = xml["xia"]["author"].value!
                if xml["xia"]["author"].value! != "element <author> not found" {
                    xml["xia"]["author"].removeFromParent()
                }
            }            
        }
    }
    
    return xml
}

func convertStringToCGFloat(txt: String) -> CGFloat {
    let cgFloat: CGFloat?
    if let double = Double("\(txt)") {
        cgFloat = CGFloat(double)
    }
    else {
        let d = txt.stringByReplacingOccurrencesOfString(",", withString: ".")
        cgFloat = (Double("\(d)") == nil) ? -12345.6789 : CGFloat(Double("\(d)")!)
    }
    return cgFloat!
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func getCenter() -> CGPoint{
    var point = CGPointMake(0, 0)
    let screenWidth = UIScreen.mainScreen().bounds.width
    let screenHeight = UIScreen.mainScreen().bounds.height

    if ( screenHeight == 1024 && screenWidth != 1366 ) { // device is portrait and not iPad Pro
        point.x = (screenWidth - 540) / 2 + 100
        point.y = (screenHeight - 620) / 2 + 100
    }
    else {
        point.x = (screenWidth - 800) / 2 + 100
        point.y = (screenHeight - 600) / 2 + 100
    }
    return point
}

func getXML(path: String, check: Bool = true) -> AEXMLDocument {
    let data = NSData(contentsOfFile: path)
    var xml: AEXMLDocument!
    do {
        try xml = AEXMLDocument(xmlData: data!)
    }
    catch {
        dbg.pt("\(error)")
    }
    return (check) ? checkXML(xml) : xml
}

func pointInPolygon(points: [Int: UIImageView], touchPoint: CGPoint) -> Bool {
    // translate from C : http://alienryderflex.com/polygon/
    let polyCorners = points.count
    var j = polyCorners - 1
    var oddNodes:Bool = false
    
    for i in 0 ..< polyCorners {
        if ( (points[i]!.center.y < touchPoint.y && points[j]!.center.y >= touchPoint.y
            || points[j]!.center.y < touchPoint.y && points[i]!.center.y >= touchPoint.y)
            && (points[i]!.center.x <= touchPoint.x || points[j]!.center.x <= touchPoint.x) ) {
                if ( points[i]!.center.x + (touchPoint.y - points[i]!.center.y) / (points[j]!.center.y - points[i]!.center.y) * (points[j]!.center.x - points[i]!.center.x) < touchPoint.x ) {
                    oddNodes = !oddNodes
                }
        }
        j=i
    }
    
    return oddNodes
}

func writeXML(xml: AEXMLDocument, path: String) -> Bool {
    var error = true
    do {
        try xml.xmlString.writeToFile(path, atomically: true, encoding: NSUTF8StringEncoding)
        error = false
    }
    catch {
        dbg.pt("\(error)")
    }
    return error
}

