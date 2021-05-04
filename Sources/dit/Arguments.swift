//
//  File.swift
//  
//
//  Created by Fabián Cañas on 5/3/21.
//

import ArgumentParser
import Foundation
import libDit

extension Recurrence: ExpressibleByArgument {
    
    public init?(argument: String) {
        guard let r = try? Recurrence(argument) else {
            return nil
        }
        self = r
    }
    
}
