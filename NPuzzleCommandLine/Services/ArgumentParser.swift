//
//  ArgumentParser.swift
//  NPuzzleCommandLine
//
//  Created by Kateryna Zakharchuk on 3/16/19.
//  Copyright © 2019 Kateryna Zakharchuk. All rights reserved.
//

import Foundation

/* Arguments:
 - size
 - solvable/unsolvable
 - iterations
 */

enum Solvability {
    case solvable
    case unsolvable
}

enum Arguments: String {
    case solvable = "-s"
    case unsolvable = "-u"
    case iterations = "-i"
    case size = "size"
    
    func getAll() -> [Arguments] {
        return [.solvable, .unsolvable, .iterations, .size]
    }
}

typealias ArgumentsCompletion = ((_ size: Int?, _ iterations: Int?, _ solvability: Solvability?) -> Void)

final class ArgumentParser {
    
    var solvability: Solvability?
    var iterations = 10000
    var size = 3
    
    init() {
        solvability = randomOption()
    }
    
    func obtainCustomArguments(completion: @escaping ArgumentsCompletion) {
        print("Hello! 👋🏼")
        obtainPuzzleSize { [weak self] quit in
            guard let strongSelf = self else { return }
            
            if quit {
                completion(nil, nil, nil)
            } else {
                strongSelf.obtainPassesCount { [weak self] quit in
                    guard let strongSelf = self else { return }
                    
                    if quit {
                        completion(nil, nil, nil)
                    } else {
                        strongSelf.obtainSolvability { [weak self] quit in
                            guard let strongSelf = self else { return }
                            
                            if quit {
                                completion(nil, nil, nil)
                            } else {
                                completion(strongSelf.size, strongSelf.iterations, strongSelf.solvability)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private  func obtainPuzzleSize(completion: ((_ quit: Bool) -> Void)?) {
        print("Please enter size of the puzzle's side. Must be > 2.\"\nIf you want to exit, white 'quit'")
        while let input = readLine() {
            guard input != "quit" else {
                completion?(true)
                break
            }
            
            if let size = Int(input) {
                if size > 2 {
                    self.size = size
                    completion?(false)
                    return
                } else {
                    print("Can't generate a puzzle with size lower than 3. It says so in the usage. Dummy.")
                }
            } else {
                print("Please enter correct size of the puzzle's side. It must be integer and > 2.")
            }
        }
    }
    
    private func obtainPassesCount(completion: ((_ quit: Bool) -> Void)?) {
        print("Do you want to setup a specific number of iterations? - yes/no")
        while let input = readLine() {
            guard input != "quit" else {
                completion?(true)
                break
            }
            
            if input == "yes" {
                print("Please enter number of passes")
                while let input = readLine() {
                    guard input != "quit" else {
                        completion?(true)
                        return
                    }
                    
                    if let iterations = Int(input) {
                        if iterations > 0 && iterations <= 10000 {
                            self.iterations = iterations
                            completion?(false)
                            return
                        } else {
                            print("Number of passes must be > 0 and <= 10000.")
                        }
                    } else {
                        print("Please enter correct number of passes. It must be integer and > 0.")
                    }
                }
            } else if input == "no" {
                completion?(false)
                return
            } else {
                print("Please answer 'yes' or 'no'\nIf you want to exit, white 'quit'")
            }
        }
    }
    
    private func obtainSolvability(completion: ((_ quit: Bool) -> Void)?) {
        print("Do you want to set the puzzle solvability? - yes/no")
        while let input = readLine() {
            guard input != "quit" else {
                completion?(true)
                break
            }
            
            if input == "yes" {
                print("Please enter parameter: [-s] - Forces generation of a solvable puzzle. Overrides -u.\n[-u] - Forces generation of an unsolvable puzzle")
                while let input = readLine() {
                    guard input != "quit" else {
                        completion?(true)
                        return
                    }
                    
                    if input == Arguments.solvable.rawValue {
                        solvability = .solvable
                        completion?(false)
                        return
                    } else if input == Arguments.unsolvable.rawValue {
                        solvability = .unsolvable
                        completion?(false)
                        return
                    } else if input.contains(Arguments.solvable.rawValue) &&
                        input.contains(Arguments.unsolvable.rawValue) {
                        print("Can't be both solvable AND unsolvable, dummy! 🤯")
                    } else {
                        print("Please enter parameter: [-s] - Forces generation of a solvable puzzle. Overrides -u.\n[-u] - Forces generation of an unsolvable puzzle")
                    }
                }
            } else if input == "no" {
                print("Thanks, solvability of the puzzle will be selected randomly.")
                completion?(false)
                return
            } else {
                print("Please answer 'yes' or 'no'\nIf you want to exit, white 'quit'")
            }
        }
    }
    
    private func randomOption() -> Solvability {
        let options: [Solvability] = [.solvable, .unsolvable]
        let randomIndex = Int(arc4random_uniform(UInt32(options.count)))
        
        return options[randomIndex]
    }
}
