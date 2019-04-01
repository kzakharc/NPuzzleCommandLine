//
//  Node.swift
//  NPuzzleCommandLine
//
//  Created by Kateryna Zakharchuk on 3/31/19.
//  Copyright © 2019 Kateryna Zakharchuk. All rights reserved.
//

import Foundation

final class Node {
    
    var value: Int
    var coordinates: CGPoint
    var g = 0
    
    var parentValue: Int?
    
    init(value: Int, coordinates: CGPoint) {
        self.value = value
        self.coordinates = coordinates
    }
}

extension Node: Equatable {
    static func == (lhs: Node, rhs: Node) -> Bool {
        if lhs.value == rhs.value && lhs.coordinates == rhs.coordinates {
            return true
        }
        return false
    }
}
