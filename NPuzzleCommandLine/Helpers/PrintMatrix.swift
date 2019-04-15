//
//  PrintMatrix.swift
//  NPuzzleCommandLine
//
//  Created by Kateryna Zakharchuk on 4/15/19.
//  Copyright © 2019 Kateryna Zakharchuk. All rights reserved.
//

import Foundation

func printAllWay(with matrix: Matrix) {
    
    var width = 2
    if matrix.array.count > 3 && matrix.array.count <= 10 {
        width = 3
    } else if matrix.array.count > 10 && matrix.array.count < 16 {
        width = 4
    } else if matrix.array.count >= 16 {
        width = 5
    }

    matrix.array.enumerated().forEach({ (_, smallArray) in
        smallArray.enumerated().forEach({ (index, element) in
            if index == 0 || index % matrix.array.count == 0 {
                print(String(format:"%\(width)d", element), terminator: "")
            } else if (index + 1) % matrix.array.count == 0 {
                print(String(format:"%\(width)d", element))
            } else {
                print(String(format:"%\(width)d", element), terminator: "")
            }
        })
    })
    printBorder(size: matrix.array.count)
}

func printBorder(size: Int) {
    var lenth = size + 2
    while lenth > 0 {
        lenth -= 1
        lenth == 0 ? print("➖") : print("➖", terminator: "")
    }
}
