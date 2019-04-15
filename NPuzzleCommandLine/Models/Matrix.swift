//
//  Matrix.swift
//  NPuzzleCommandLine
//
//  Created by Kateryna Zakharchuk on 4/15/19.
//  Copyright © 2019 Kateryna Zakharchuk. All rights reserved.
//

import Foundation

final class Matrix {
    
    var array: [[Int]]
    var g = 0
    
    var parentMatrix: Matrix? = nil
    var currentF = 0
    
    init(with array: [[Int]]) {
        self.array = array
    }

}

extension Matrix: Equatable {
    static func == (lhs: Matrix, rhs: Matrix) -> Bool {
        return (lhs.array == rhs.array && lhs.g == rhs.g && lhs.parentMatrix == rhs.parentMatrix)
    }
}

extension Matrix: Comparable {
    static func < (lhs: Matrix, rhs: Matrix) -> Bool {
        return lhs.currentF < rhs.currentF
    }
}

extension Array where Element == Equatable {
    
}
