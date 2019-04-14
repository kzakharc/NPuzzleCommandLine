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
    
    init(with array: [Int]) {
        self.startArray = makeNodeArray(array)
        
        let goal = Generator().makeGoal(with: startArray.count)
        self.goalArray = makeNodeArray(goal)
        
        aStar()
    }
    
    private func obtainEmptyNode(from array: [[Node]]) -> Node {
        var emptyNode = array[0][0]
        array.forEach { smallArray in
            smallArray.forEach({ node in
                if node.value == 0 {
                    emptyNode = node
                }
            })
        }
        return emptyNode
    }
    
    func aStar() {
        repeat {
            //print
            startArray.forEach({ array in
                array.enumerated().forEach({ (index, element) in
                    if index == 0 || index % array.count == 0 {
                        print(element.value, terminator: "")
                    } else if (index + 1) % array.count == 0 {
                        print(" \(element.value)")
                    } else {
                        print(" \(element.value)", terminator: "")
                    }
                })
            })
            print("================================")
            
            // Get the square with the lowest F score
            let currentNode = obtainEmptyNode(from: startArray)

            /// Check if all ok
            var equalsCount = 0
            startArray.enumerated().forEach { index, _ in
                if startArray[index] == goalArray[index] {
                    equalsCount += 1
                }
            }
            if equalsCount == startArray.count {
                break
            }
            
            // Retrieve all its walkable adjacent nodes
            let acentNodes = obtainNeighborsNodes(for: currentNode)
            
            acentNodes.forEach({ node in
                 if !closedListContains(node) {
                    openListContains(node) ? () : openList.append(node)
                }
            })
            
            let finnestNode = obtainNodeWithLowestFScore()
            openList.enumerated().forEach { index, element in
                if finnestNode.value == element.value {
                    openList.remove(at: index)
                }
            }
            closedList.append(finnestNode)
            
            swapNodes(firstNode: currentNode, secondNode: finnestNode)
        } while !openList.isEmpty
        
        // print
        startArray.forEach({ array in
            array.enumerated().forEach({ (index, element) in
                if index == 0 || index % array.count == 0 {
                    print(element.value, terminator: "")
                } else if (index + 1) % array.count == 0 {
                    print(" \(element.value)")
                } else {
                    print(" \(element.value)", terminator: "")
                }
            })
        })
        print("+++++++++++++++++++++++++++++")
    }
    
    private func closedListContains(_ node: Node) -> Bool {
        for currentNode in closedList {
            if currentNode.value == node.value {
                return true
            }
        }
        return false
    }
    
    private func openListContains(_ node: Node) -> Bool {
        for currentNode in openList {
            if currentNode.value == node.value {
                return true
            }
        }
        return false
    }
    
    func obtainNeighborsNodes(for node: Node) -> [Node] {
        let y = Int(node.coordinates.y)
        let x = Int(node.coordinates.x)
        
        var neighbor = [Node]()
        x > 0 ? neighbor.append(obtainNeighbor(from: .left, for: node)) : ()
        y > 0  ? neighbor.append(obtainNeighbor(from: .up, for: node)) : ()
        x < startArray.count - 1 ? neighbor.append(obtainNeighbor(from: .right, for: node)) : ()
        y < startArray.count - 1  ? neighbor.append(obtainNeighbor(from: .down, for: node)) : ()
        return neighbor
    }
    
    func obtainNeighbor(from side: Move, for node: Node) -> Node {
        var neighbor = node
        
        switch side {
        case .up:
            neighbor = startArray[Int(node.coordinates.y - 1)][Int(node.coordinates.x)]
        case .down:
            neighbor = startArray[Int(node.coordinates.y + 1)][Int(node.coordinates.x)]
        case .left:
            neighbor = startArray[Int(node.coordinates.y)][Int(node.coordinates.x - 1)]
        case .right:
            neighbor = startArray[Int(node.coordinates.y)][Int(node.coordinates.x + 1)]
        }
        return neighbor
    }
    
    private func fakeSwap(with node: Node) -> (Node, [[Node]]) {
        
        var finnestNode = node
        var fakeStartArray = startArray
        
        var emptyNode0 = obtainEmptyNode(from: startArray)
        
        let secondCoordinates = finnestNode.coordinates
        finnestNode.coordinates = emptyNode0.coordinates
        emptyNode0.coordinates = secondCoordinates
        
        fakeStartArray[Int(emptyNode0.coordinates.y)][Int(emptyNode0.coordinates.x)] = emptyNode0
        fakeStartArray[Int(finnestNode.coordinates.y)][Int(finnestNode.coordinates.x)] = finnestNode
        return (finnestNode, fakeStartArray)
    }
    
    func obtainNodeWithLowestFScore() -> Node {
        let tNode = openList[0]
        var (finnestNode, fakeStartArray) = fakeSwap(with: tNode)

        var currentF = countFScore(for: finnestNode)
        
        openList.forEach { node11 in
            
            var (node, fakeStartArray1) = fakeSwap(with: node11)
            
            let f = countFScore(for: node)
            
            if f < currentF {
                finnestNode = node11
                currentF = f
            }
        }
        return finnestNode
    }
    
    func countFakeScore(for node: Node) -> CGFloat {
        
        var tmpNode = node
        var fakeStartArray = startArray
        
        var emptyNode = obtainEmptyNode(from: startArray)
        
        let secondCoordinates = tmpNode.coordinates
        tmpNode.coordinates = emptyNode.coordinates
        emptyNode.coordinates = secondCoordinates
        
        fakeStartArray[Int(emptyNode.coordinates.y)][Int(emptyNode.coordinates.x)] = emptyNode
        fakeStartArray[Int(tmpNode.coordinates.y)][Int(tmpNode.coordinates.x)] = tmpNode
        
        let h = CGPointManhattanDistance(from: tmpNode.coordinates, to: obtainGoalCGPoint(for: tmpNode))
        let g: CGFloat = tmpNode.g
        let f = h + g
        
        return f
    }

    
    func countFScore(for node: Node) -> CGFloat {
        let h = CGPointManhattanDistance(from: node.coordinates, to: obtainGoalCGPoint(for: node))
        let g: CGFloat = node.g
        let f = h + g
        
        return f
    }
    
    func obtainNodeWithLowestHScore() -> Node {
        var finnestNode = openList[0]
        var currentH = CGPointManhattanDistance(from: finnestNode.coordinates, to: obtainGoalCGPoint(for: finnestNode))
        
        openList.forEach { node in
            let h = CGPointManhattanDistance(from: node.coordinates, to: obtainGoalCGPoint(for: node))
            if h < currentH {
                finnestNode = node
                currentH = h
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
    
    func moveNode(node: Node, move: Move) {
        let goalY = Int(abs(node.coordinates.y + move.coordinates().y))
        let goalX = Int(abs(node.coordinates.x + move.coordinates().x))
        
        var secondNode = startArray[goalY][goalX]
        
        let nodeCoordinates = node.coordinates
        secondNode.coordinates = nodeCoordinates
        
        var tmpNode = node
        tmpNode.coordinates = CGPoint(x: goalX, y: goalY)
        startArray[goalY][goalX] = tmpNode
        startArray[Int(secondNode.coordinates.y)][Int(secondNode.coordinates.x)] = secondNode
    }
    
    func swapNodes(firstNode: Node, secondNode: Node) {
        var first = firstNode
        var second = secondNode
        
        let secondCoordinates = second.coordinates
        second.coordinates = first.coordinates
        first.coordinates = secondCoordinates
        
        startArray[Int(first.coordinates.y)][Int(first.coordinates.x)] = first
        startArray[Int(second.coordinates.y)][Int(second.coordinates.x)] = second
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
