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

enum Heuristic: String {
    case manhattan = "-m"
    case nodePosition = "-n"
    case euclideanDistance = "-e"
}

enum Algoritm: String {
    case aStar = "-a"
    case greedy = "-g"
    case uniformCost = "-u"
}

final class PuzzleSolver {
    
    private var heuristic: Heuristic = .manhattan
    private var algoritm: Algoritm = .aStar
    
    private var openList = PriorityQueue<Matrix>()
    private var closedList = [Matrix]()
    
    private var startArray = [[Int]]()
    private var goalArray = [[Int]]()
    
    private var startTime = Date()
    private var finalTime = Date()
    
    private var openListMaxSize = 0
    
    init(with array: [Int], algoritm: Algoritm, heuristic: Heuristic) {
        self.algoritm = algoritm
        self.heuristic = heuristic
        self.startArray = make2DArray(array)
        
        let goal = Generator().makeGoal(with: startArray.count)
        self.goalArray = make2DArray(goal)
        
        if isSolvable(puzzle: array) {
            aStar()
        } else {
            print("\nSorry, this puzzle is unsolvable.\nExit 🕳\n")
        }
    }
    
    //MARK: - Basic logic
    func aStar() {
        print("\nAll the way:")
        PrintMatrix.printBorder(size: goalArray.count, style: .all)
        
        let matrix = Matrix(with: startArray)
        
        openList.push(matrix)
        openListMaxSize = openList.count
        
        startTime = Date()
        repeat {
            // Get the square with the lowest F score
            let currentMatrix = obtainMatrixWithTheLowestF()
            
            PrintMatrix.printWay(with: currentMatrix, style: .all)
            
            closedList.append(currentMatrix)
            openList.remove(currentMatrix)
            
            /// Check if all ok
            if compareArray(firstArray: currentMatrix.array, secondArray: goalArray) {
                print("Success 😍\n")
                
                finalTime = Date()
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
        var f = algoritm == .greedy ? 0 : matrix.g
        var h = 0
        
        if algoritm != .uniformCost {
            matrix.array.enumerated().forEach { (y, smallArray) in
                smallArray.enumerated().forEach({ (x, element) in
                    let goalCoordinates = obtainCGPointFromGoalArray(for: element)
                    
                    switch heuristic {
                    case .manhattan:
                        h = CGPointManhattanDistance(from: CGPoint(x: x, y: y), to: goalCoordinates)
                    case .nodePosition:
                        h = CGPointNodePosition(from: CGPoint(x: x, y: y), to: goalCoordinates)
                    case .euclideanDistance:
                        h = CGPointEuclideanDistance(from: CGPoint(x: x, y: y), to: goalCoordinates)
                    }
                    
                    f += h
                })
            }
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
    
    func CGPointNodePosition(from: CGPoint, to: CGPoint) -> Int {
        if from.x == to.x && from.y == to.y {
            return 0
        }
        return 1
    }
    
    func CGPointEuclideanDistance(from: CGPoint, to: CGPoint) -> Int {
        let xDist = to.x - from.x
        let yDist = to.y - from.y
        
        return Int(sqrt(xDist * xDist + yDist * yDist))
    }
    
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
        let diff = Calendar.current.dateComponents([Calendar.Component.minute, Calendar.Component.second, Calendar.Component.nanosecond], from: startTime, to: finalTime)
        let minute = diff.minute ?? 0
        let second = diff.second ?? 0
        let nanosecond = diff.nanosecond ?? 0
        
        print("\n🌈 In result:")
        print("Total number of states ever selected: \(closedList.count)")
        print("Maximum number of states ever represented in memory at the same time during the search: \(openListMaxSize)")
        print("Number of moves from initial state to solution: \(clearWay.count - 1)")
        print("Complexity in time: \(minute):\(second):\(String(format:"%\(2)d", nanosecond))")
        print("Exit 🕳\n")
    }
    
    //MARK: - Solvability
    private func isSolvable(puzzle: [Int]) -> Bool {
        let parity = 0
        let gridWidth = Int(sqrt(Double(puzzle.count)))
        var row = 0
        var blankRow = 0
        
        var solvable: Bool
        
        for i in puzzle {
            if (i % gridWidth == 0) {
                row += 1
            }
            if (puzzle[i] == 0) {
                blankRow = row
            }
            
            if (gridWidth % 2 == 0) {
                if (blankRow % 2 == 0) {
                    solvable = parity % 2 == 0
                } else {
                    solvable = parity % 2 != 0
                }
            } else {
                solvable = parity % 2 == 0
            }
            if solvable {
                
            }
        }
        return basicSolvability == .solvable
    }
}
