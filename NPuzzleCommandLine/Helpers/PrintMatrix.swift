//
//  PrintMatrix.swift
//  NPuzzleCommandLine
//
//  Created by Kateryna Zakharchuk on 4/15/19.
//  Copyright © 2019 Kateryna Zakharchuk. All rights reserved.
//

import Foundation

enum Way {
    case all
    case clear
}

struct PrintMatrix {
    
    static func printWay(with matrix: Matrix, style: Way) {
        
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
        printBorder(size: matrix.array.count, style: style)
    }
    
    static func printBorder(size: Int, style: Way) {
        var lenth = size * 2 - 2
        var symbol = String()
        
        switch style {
        case .all:
            symbol = "➖"
        case .clear:
            symbol = "🧩"
        }
        
        while lenth > 0 {
            lenth -= 1
            lenth == 0 ? print(symbol) : print(symbol, terminator: "")
        }
    }
}
