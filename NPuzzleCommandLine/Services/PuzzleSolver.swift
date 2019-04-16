//
//  PuzzleSolver.swift
//  NPuzzleCommandLine
//
//  Created by pc166 on 3/18/19.
//  Copyright © 2019 Kateryna Zakharchuk. All rights reserved.
//

import Foundation

enum Move {
    case up
    case down
    case left
    case right
    
    func coordinates() -> CGPoint {
        switch self {
        case .up:
            return CGPoint(x: 0, y: -1)
        case .down:
            return CGPoint(x: 0, y: 1)
        case .left:
            return CGPoint(x: -1, y: 0)
        case .right:
            return CGPoint(x: 1, y: 0)
        }
    }
}

final class PuzzleSolver {

    private var openList = PriorityQueue<Matrix>()
    private var closedList = [Matrix]()
    
    private var startArray = [[Int]]()
    private var goalArray = [[Int]]()
    
    private var counter = 0.0
    private var timer = Timer()
    
    private var openListMaxSize = 0

    init(with array: [Int]) {
        self.startArray = make2DArray(array)
        
        let goal = Generator().makeGoal(with: startArray.count)
        self.goalArray = make2DArray(goal)
        
        aStar()
    }
    
    //MARK: - Basic logic
    func aStar() {
        print("\nAll the way:")
        PrintMatrix.printBorder(size: goalArray.count, style: .all)
        
        let matrix = Matrix(with: startArray)

        openList.push(matrix)
        openListMaxSize = openList.count
        startTimer()
        repeat {
            // Get the square with the lowest F score
            let currentMatrix = obtainMatrixWithTheLowestF()
            
            PrintMatrix.printWay(with: currentMatrix, style: .all)

            closedList.append(currentMatrix)
            openList.remove(currentMatrix)
            
            /// Check if all ok
            if currentMatrix.array == goalArray {
                print("Success 🥰\n")
                
                pauseTimer()
                findClearWay(final: currentMatrix)
                break
            }
            
            // Retrieve all its walkable adjacent nodes
            let nextMatrices = obtainNextMatrices(for: currentMatrix)
            nextMatrices.forEach { matrix in
                if !closedList.contains(matrix) {
                    if !openList.contains(matrix) {
                        matrix.g += 1
                        matrix.parentMatrix = currentMatrix
                        matrix.currentF = countFScore(for: matrix)

                        openList.push(matrix)
                    }
                }
            }
            if openList.count > openListMaxSize {
                openListMaxSize = openList.count
            }
        } while !openList.isEmpty
    }
    
    private func findClearWay(final matrix: Matrix) {
        
        var clearWay = [Matrix]()
        var parentMatrix = matrix.parentMatrix
        
        clearWay.append(matrix)

        repeat {
            if let pMatrix = parentMatrix {
                clearWay.append(pMatrix)
                
                let parent = pMatrix.parentMatrix
                parentMatrix = parent
            }
        } while parentMatrix != nil

        print("Clear way:")
        PrintMatrix.printBorder(size: goalArray.count, style: .clear)
        
        var index = clearWay.count - 1
        while index >= 0 {
            PrintMatrix.printWay(with: clearWay[index], style: .clear)
            index -= 1
        }
        printInfo(with: clearWay)
    }
    
    private func obtainNextMatrices(for current: Matrix) -> [Matrix] {
        
        var nextMatrices = [Matrix]()
        
        current.array.enumerated().forEach { y, smallArray in
            smallArray.enumerated().forEach({ x, element in
                if element == 0 {
                    x > 0 ? nextMatrices.append(swap(.left, current, CGPoint(x: x, y: y))) : ()
                    y > 0  ? nextMatrices.append(swap(.up, current, CGPoint(x: x, y: y))) : ()
                    x < startArray.count - 1 ? nextMatrices.append(swap(.right, current, CGPoint(x: x, y: y))) : ()
                    y < startArray.count - 1  ? nextMatrices.append(swap(.down, current, CGPoint(x: x, y: y))) : ()
                }
            })
        }
        return nextMatrices
    }
    
    private func swap(_ move: Move, _ matrix: Matrix, _ zeroCoordinates: CGPoint) -> Matrix {
        let tmpMatrix = Matrix(with: matrix.array)
        tmpMatrix.g = matrix.g
        
        let newZeroCoordinates = CGPoint(x: zeroCoordinates.x + move.coordinates().x, y: zeroCoordinates.y + move.coordinates().y)
        let elementToSwap = matrix.array[Int(newZeroCoordinates.y)][Int(newZeroCoordinates.x)]
        
        tmpMatrix.array[Int(newZeroCoordinates.y)][Int(newZeroCoordinates.x)] = 0
        tmpMatrix.array[Int(zeroCoordinates.y)][Int(zeroCoordinates.x)] = elementToSwap
        return tmpMatrix
    }
    
    
    //MARK: - Count F score
    private func obtainMatrixWithTheLowestF() -> Matrix {
        var finnestMatrix = openList[0]
        var finnestFScore = countFScore(for: finnestMatrix)
        
        openList.forEach { matrix in
            let f = countFScore(for: matrix)
            
            if f < finnestFScore {
                finnestMatrix = matrix
                finnestFScore = f
            }
        }
        return finnestMatrix
    }
    
    private func countFScore(for matrix: Matrix) -> Int {
        var f = matrix.g
        
        matrix.array.enumerated().forEach { (y, smallArray) in
            smallArray.enumerated().forEach({ (x, element) in
                let goalCoordinates = obtainCGPointFromGoalArray(for: element)
                
                f += CGPointManhattanDistance(from: CGPoint(x: x, y: y), to: goalCoordinates)
            })
        }
        return f
    }
    
    private func obtainCGPointFromGoalArray(for element: Int) -> CGPoint {
        var point = CGPoint(x: 0, y: 0)
        
        goalArray.enumerated().forEach { (y, smallArray) in
            smallArray.enumerated().forEach({ (x, goalElement) in
                if element == goalElement {
                    point = CGPoint(x: x, y: y)
                }
            })
        }
        return point
    }
    
    // MARK: - Heuristic functions
    func CGPointManhattanDistance(from: CGPoint, to: CGPoint) -> Int {
        return Int((abs(from.x - to.x) + abs(from.y - to.y)))
    }
    
    //MARK: - Timer methods
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _  in
            self.counter = self.counter + 0.01
        }
    }
    
    private func pauseTimer() {
        timer.invalidate()
    }
    
//    @objc func updateTimer(_ timer: Timer) {
//        counter = counter + 0.01
//    }
    
    // MARK: - Helpers
    private func make2DArray(_ array: [Int]) -> [[Int]] {
        let count = Int(sqrt(Double(array.count)))
        
        var doubleArray = [[Int]]()
        var smallArray = [Int]()
        var y = 0
        
        array.enumerated().forEach { index, value in
            if index % count == 0 && index != 0 {
                doubleArray.append(smallArray)
                
                y += 1
                smallArray = [Int]()
            }
            
            smallArray.append(value)
            index == array.count - 1 ? doubleArray.append(smallArray) : ()
        }
        return doubleArray
    }
    
    private func printInfo(with clearWay: [Matrix]) {
        print("\n🌈 In result:")
        print("Total number of states ever selected: \(closedList.count)")
        print("Maximum number of states ever represented in memory at the same time during the search: \(openListMaxSize)")
        print("Number of moves from initial state to solution: \(clearWay.count - 1)")
        print("Complexity in time: \(String(format: "%.2f", counter))\n")
    }
}
