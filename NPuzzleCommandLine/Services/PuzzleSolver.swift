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
    
    var openList = [Node]()
    var closedList = [Node]()
    
    var startArray = [[Node]]()
    var goalArray = [[Node]]()
    
    init(startArray: [Int]) {
        self.startArray = makeNodeArray(startArray)
        
        let goal = Generator().makeGoal(with: startArray.count)
        self.goalArray = makeNodeArray(goal)
    }
    
    func aStar() {
        var emptyNode = startArray[0][0]
        startArray.forEach { smallArray in
            smallArray.forEach({ node in
                if node.value == 0 {
                    emptyNode = node
                }
            })
        }
        
        repeat {
            //let currentNode
        } while !openList.isEmpty
    }
    
    func obtainNodeWithLowestFScore() -> Node {
        var finnestNode = openList[0]
        var currentF = CGPointManhattanDistance(from: finnestNode.coordinates, to: obtainGoalCGPoint(for: finnestNode))
        
        openList.forEach { node in
            let f = CGPointManhattanDistance(from: node.coordinates, to: obtainGoalCGPoint(for: node))
            if f < currentF {
                finnestNode = node
                currentF = f
            }
        }
        return finnestNode
    }
    
    func obtainGoalCGPoint(for node: Node) -> CGPoint {
        var coordinates = node.coordinates
        
        goalArray.forEach { smallArray in
            smallArray.forEach({ goalNode in
                if goalNode.value == node.value {
                    coordinates = goalNode.coordinates
                }
            })
        }
        return coordinates
    }
    
    func swapNodes(node: Node, move: Move) {
        let goalY = Int(abs(node.coordinates.y + move.coordinates().y))
        let goalX = Int(abs(node.coordinates.x + move.coordinates().x))
        
        let secondNode = startArray[goalY][goalX]
        
        let nodeCoordinates = node.coordinates
        secondNode.coordinates = nodeCoordinates
        
        node.coordinates = CGPoint(x: goalX, y: goalY)
        startArray[goalY][goalX] = node
        startArray[Int(secondNode.coordinates.y)][Int(secondNode.coordinates.x)] = secondNode
    }
    
    private func makeNodeArray(_ array: [Int]) -> [[Node]] {
        let count = Int(sqrt(Double(array.count)))
        
        var nodeArray = [[Node]]()
        var smallArray = [Node]()
        var y = 0
        
        array.enumerated().forEach { index, value in
            if index % count == 0 && index != 0 {
                nodeArray.append(smallArray)
                
                y += 1
                smallArray = [Node]()
            }
            
            let multiplier = index / count
            let x = index < count ? index : (index - count * multiplier)
            
            let node = Node(value: value, coordinates: CGPoint(x: x, y: y))
            smallArray.append(node)
            
            index == array.count - 1 ? nodeArray.append(smallArray) : ()
        }
        return nodeArray
    }
    
    // MARK: - Heuristic functions
    func CGPointManhattanDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return (abs(from.x - to.x) + abs(from.y - to.y))
    }
}
