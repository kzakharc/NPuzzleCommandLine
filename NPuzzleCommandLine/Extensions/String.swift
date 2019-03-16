
//
//  String.swift
//  NPuzzleCommandLine
//
//  Created by Kateryna Zakharchuk on 3/16/19.
//  Copyright © 2019 Kateryna Zakharchuk. All rights reserved.
//

import Foundation

extension String {
    
    func contains(_ substring: String) -> Bool {
        return self.range(of: substring) != nil
    }
}
