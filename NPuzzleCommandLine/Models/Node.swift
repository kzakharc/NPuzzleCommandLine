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
    
    var parentValue: Int?
    
    init(value: Int, coordinates: CGPoint) {
        self.value = value
        self.coordinates = coordinates
    }
}
