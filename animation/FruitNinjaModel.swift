//
//  FruitNinjaModel.swift
//  animation
//
//  Created by stvding on 2016/10/5.
//  Copyright © 2016年 shellCom. All rights reserved.
//

import Foundation
class FruitNinjaModel {
    static var bestScore = 0
    var life: Int
    var fruitDropped: Int
    var state: gameState
    var combo: Int = 0
//    var mode: gameMode
    var score: Int {
        didSet{
            if score > FruitNinjaModel.bestScore{
                FruitNinjaModel.bestScore = score
            }
        }
    }
    
    enum gameMode {
        case arcade
        case classic
    }
    
    enum gameState {
        case playing
        case pausing
        case over
    }
    
    init(lifeToBeginWith: Int) {
        life = lifeToBeginWith
        fruitDropped = 0
        score = 0
        state = .playing
//        mode = gameToPlay
    }

}
