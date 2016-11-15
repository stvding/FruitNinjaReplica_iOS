//
//  FruitBrain.swift
//  animation
//
//  Created by stvding on 2016/9/25.
//  Copyright © 2016年 shellCom. All rights reserved.
//

import Foundation


class FruitBrain {
    enum FruitState {
        case whole
        case leftPiece
        case rightPiece
    }
    
    var state: FruitState

    init(newFruitState:FruitState) {
        switch newFruitState {
        case .whole:
            state = .whole
        case .leftPiece:
            state = .leftPiece
        case .rightPiece:
            state = .rightPiece
        }
    }
}
