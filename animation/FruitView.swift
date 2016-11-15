//
//  FruitView.swift
//  animation
//
//  Created by stvding on 2016/9/24.
//  Copyright © 2016年 shellCom. All rights reserved.
//

import UIKit

class FruitView: UIView {
    private var fruitBrain: FruitBrain!
    private var linearVelocity: CGPoint = CGPoint.zero
    private var angluarVelocity: CGFloat = 0
    var throwing: UIPushBehavior = UIPushBehavior(items: [], mode: .Instantaneous)
    
    
    init(thisState: FruitBrain.FruitState, frame:CGRect) {
        super.init(frame: frame)
        fruitBrain = FruitBrain(newFruitState: thisState)
        throwing.addItem(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = bounds.size.width / 2 - 2
        
        switch fruitBrain.state {
        case .whole:
            //            print("whole!")
            let fruit = UIBezierPath(arcCenter: center,
                                     radius: radius,
                                     startAngle: 0.0,
                                     endAngle: CGFloat(2*M_PI),
                                     clockwise: false)
            fruit.lineWidth = 3.0
            
            UIColor.blackColor().set()
            fruit.stroke()
            
            UIColor.yellowColor().set()
            fruit.fill()
        case .leftPiece:
            //            print("leftPiece!")
            let leftPiece = UIBezierPath(arcCenter: center,
                                         radius: radius,
                                         startAngle: CGFloat(M_PI*1.5),
                                         endAngle: CGFloat(M_PI/2),
                                         clockwise: false)
            leftPiece.lineWidth = 3.0
            UIColor.blackColor().set()
            leftPiece.stroke()
            UIColor.whiteColor().set()
            leftPiece.fill()
        case .rightPiece:
            //            print("rightPiece!")
            let rightPiece = UIBezierPath(arcCenter: center,
                                          radius: radius,
                                          startAngle: CGFloat(M_PI/2),
                                          endAngle: CGFloat(M_PI*1.5),
                                          clockwise: false)
            rightPiece.lineWidth = 3.0
            UIColor.blackColor().set()
            rightPiece.stroke()
            UIColor.blueColor().set()
            rightPiece.fill()
        }
    }
    
    func split() -> (FruitView,FruitView){
        let leftFruit = FruitView(thisState: .leftPiece, frame: self.frame)
        let rightFruit = FruitView(thisState: .rightPiece, frame: self.frame)
        
        leftFruit.backgroundColor = UIColor.clearColor()
        rightFruit.backgroundColor = UIColor.clearColor()
        return (leftFruit,rightFruit)
    }
    
    func getState() -> FruitBrain.FruitState {
        return fruitBrain.state
    }
    
    func saveVelocity(behavior: TossingBehavior) {
        let velocity = behavior.getVelocity(self)
        linearVelocity = velocity.0
        angluarVelocity = velocity.1
    }
    
    func getVelocity() -> (CGPoint, CGFloat) {
        return (linearVelocity, angluarVelocity)
    }
    
    func throwIt(force: CGVector){
        throwing.pushDirection = force
//        throwing.active = true
    }
  
}
