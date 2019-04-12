//
//  Generator.swift
//  NPuzzleCommandLine
//
//  Created by Kateryna Zakharchuk on 3/16/19.
//  Copyright © 2019 Kateryna Zakharchuk. All rights reserved.
//

import Foundation

final class Generator {
    
    var solvability: Solvability = .solvable
    var iterations = 10000
    var size = 3
    
    var arguments = [Arguments]()
    
    func makePuzzle() -> [Int] {
        var puzzle = makeGoal(with: size)
        for _ in 0..<iterations {
            puzzle = self.swapEmpty(array: puzzle)
        }
        
        if solvability == .unsolvable {
            if puzzle[0] == 0 || puzzle[1] == 0 {
                let count = puzzle.count
                let puzzleEl = puzzle[count-1]
                
                puzzle[count-1] = puzzle[count-2]
                puzzle[count-2] = puzzleEl
            } else {
                let puzzleEl = puzzle[0]
                
                puzzle[0] = puzzle[1]
                puzzle[1] = puzzleEl
            }
        }
        return puzzle
    }
    
    func swapEmpty(array: [Int]) -> [Int] {
        var idx = 0
        var p = array
        p.enumerated().forEach { (index, element) in
            if element == 0 {
                idx = index
            }
        }
        var poss = [Int]()
        
        if idx % size > 0 {
            poss.append(idx - 1)
        }
        if idx % size < size - 1 {
            poss.append(idx + 1)
        }
        if idx / size > 0 {
            poss.append(idx - size)
        }
        if idx / size < size - 1 {
            poss.append(idx + size)
            let swi = poss[Int(arc4random_uniform(UInt32(poss.count)))]
            p[idx] = p[swi]
            p[swi] = 0
        }
        return p
    }
    
    func makeGoal(with size: Int) -> [Int] {
        var puzzle = [Int]()
        for _ in 0..<size*size {
            puzzle.append(-1)
        }
        
        var cur = 1
        var x = 0
        var ix = 1
        var y = 0
        var iy = 0
        
        while true {
            let currentIndex = x + y*size
            let index = currentIndex < 0 ? puzzle.count + currentIndex : currentIndex
            puzzle[index] = cur
            if cur == 0 { break }
            cur += 1
            if x + ix == size || x + ix < 0 || (ix != 0 && puzzle[x + ix + y*size] != -1) {
                iy = ix
                ix = 0
            } else if y + iy == size || y + iy < 0 || (iy != 0 && puzzle[x + (y+iy)*size] != -1) {
                ix = -iy
                iy = 0
            }
            x += ix
            y += iy
            cur == size*size ? cur = 0 : ()
        }
        
        print("Fucking yea baby 😎")
        puzzle.enumerated().forEach({ (index, element) in
            if index == 0 || index % size == 0 {
                print(element, terminator: "")
            } else if (index + 1) % size == 0 {
                print(" \(element)")
            } else {
                print(" \(element)", terminator: "")
            }
        })
        print("Wow 🤩")
        return puzzle
    }
    
    func generateCustomPuzzle() {
        ArgumentParser().obtainCustomArguments { [weak self] (customSize, customIterations, customSolvability) in
            guard let strongSelf = self else { return }
            
            if let customSize = customSize,
                let customIterations = customIterations,
                let customSolvability = customSolvability {
                
                strongSelf.solvability = customSolvability
                strongSelf.iterations = customIterations
                strongSelf.size = customSize
                
                let solvabilityName = strongSelf.solvability == .solvable ? "solvable" : "unsolvable"
                print("This puzzle is \(solvabilityName)\n\(strongSelf.size)")
                
                let puzzle = strongSelf.makePuzzle()
                puzzle.enumerated().forEach({ (index, element) in
                    if index == 0 || index % strongSelf.size == 0 {
                        print(element, terminator: "")
                    } else if (index + 1) % strongSelf.size == 0 {
                        print(" \(element)")
                    } else {
                        print(" \(element)", terminator: "")
                    }
                })
                
                PuzzleSolver(with: puzzle)
            } else {
                print("Exit 🕳")
            }
        }
        
    }
}
