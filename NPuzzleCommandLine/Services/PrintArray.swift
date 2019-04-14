//
//  PrintArray.swift
//  NPuzzleCommandLine
//
//  Created by Kateryna Zakharchuk on 4/14/19.
//  Copyright © 2019 Kateryna Zakharchuk. All rights reserved.
//

import Foundation

func fprint(_ array: [[Node]]) {
    array.forEach({ currentArray in
        currentArray.enumerated().forEach({ (index, element) in
            if index == 0 || index % currentArray.count == 0 {
                //print(element.value, terminator: "")
                print("{0: <5}", element.value)
            } else if (index + 1) % array.count == 0 {
               // print(" \(element.value)")
                print("{0: <5}", element.value)
            } else {
                //print(" \(element.value)", terminator: "")
                print("{0: <5}", element.value)
            }
        })
    })
    print("================================")
}
