//
//  ThrowingFruitBehavior.swift
//  animation
//
//  Created by stvding on 2016/10/24.
//  Copyright © 2016年 shellCom. All rights reserved.
//

import UIKit

class TossingBehavior: UIDynamicBehavior {
    let gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior()
        gravity.magnitude = 0.8
        return gravity
    }()
    
//    let throwing = UIPushBehavior(items: [], mode: .Instantaneous)
    
    let itemBehavior: UIDynamicItemBehavior = {
        let dib = UIDynamicItemBehavior()
        dib.allowsRotation = true
        return dib
    }()
    
    let collision: UICollisionBehavior = {
        let collider = UICollisionBehavior()
        collider.collisionMode = UICollisionBehaviorMode.Boundaries
        return collider
    }()
    
    override init() {
        super.init()
        addChildBehavior(collision)
        addChildBehavior(gravity)
//        addChildBehavior(throwing)
        addChildBehavior(itemBehavior)
    }
    
    func setBottomLine(p1: CGPoint, p2: CGPoint) {
        collision.addBoundaryWithIdentifier("bottomLine", fromPoint: p1, toPoint: p2)
    }
    
    func addItem(item: UIDynamicItem, angularVelocity: CGFloat) {
        gravity.addItem(item)
        itemBehavior.addItem(item)
        itemBehavior.addAngularVelocity(angularVelocity, forItem: item)
        collision.addItem(item)
    }
    
    func removeItem(item: UIDynamicItem) {
        gravity.removeItem(item)
        itemBehavior.removeItem(item)
        collision.removeItem(item)
    }
    
    func getVelocity(item: UIDynamicItem) -> (CGPoint, CGFloat) {
        return (itemBehavior.linearVelocityForItem(item), itemBehavior.angularVelocityForItem(item))
    }
    
    func setVeloctiy(item: UIDynamicItem, linear: CGPoint, angular: CGFloat) {
        itemBehavior.addLinearVelocity(linear, forItem: item)
        itemBehavior.addAngularVelocity(angular, forItem: item)
        
    }
    
}
