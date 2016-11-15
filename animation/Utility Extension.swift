//
//  Utility Extension.swift
//  animation
//
//  Created by stvding on 2016/11/4.
//  Copyright © 2016年 shellCom. All rights reserved.
//

import UIKit

extension Int{
    static func random(min: Int, max: Int) -> Int {
        return Int(
            arc4random_uniform(UInt32(max))
                + UInt32(min)
        )
    }
}

extension CGFloat{
    static func random(min: Int, max: Int) -> CGFloat {
        return CGFloat(
            arc4random_uniform(UInt32(max))
                + UInt32(min)
        )
    }
}

extension UIColor{
    class var random: UIColor{
        switch arc4random()%5 {
        case 0: return UIColor.blueColor()
        case 1: return UIColor.greenColor()
        case 2: return UIColor.cyanColor()
        case 3: return UIColor.redColor()
        case 4: return UIColor.yellowColor()
        default: return UIColor.blackColor()
        }
    }
}

extension CGRect {
    var mid: CGPoint { return CGPoint(x: midX, y: midY) }
    var upperLeft: CGPoint { return CGPoint(x: minX, y: minY) }
    var lowerLeft: CGPoint { return CGPoint(x: minX, y: maxY) }
    var upperRight: CGPoint { return CGPoint(x: maxX, y: minY) }
    var lowerRight: CGPoint { return CGPoint(x: maxX, y: maxY) }
    
    init(center: CGPoint, size: CGSize) {
        let upperLeft = CGPoint(x: center.x-size.width/2, y: center.y-size.height/2)
        self.init(origin: upperLeft, size: size)
    }
}

extension UIBezierPath {
    class func lineFrom(from: CGPoint, to:CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(from)
        path.addLineToPoint(to)
        return path
    }
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}
