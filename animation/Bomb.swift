//
//  Bomb.swift
//  animation
//
//  Created by stvding on 2016/11/14.
//  Copyright © 2016年 shellCom. All rights reserved.
//

import UIKit

class Bomb: UIView {
    let throwing = UIPushBehavior(items: [], mode: .Instantaneous)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        throwing.addItem(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.size.width / 2 - 2
        
        
        let fruit = UIBezierPath(arcCenter: center,
                                 radius: radius,
                                 startAngle: 0.0,
                                 endAngle: CGFloat(2*M_PI),
                                 clockwise: false)
        fruit.lineWidth = 3.0
        
        UIColor.blackColor().set()
        fruit.stroke()
        
        UIColor.blackColor().set()
        fruit.fill()
    }
    
    func throwIt(force: CGVector){
        throwing.pushDirection = force
    }
    
}
