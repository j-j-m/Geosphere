//
//  Extensions.swift
//  Geosphere
//
//  Created by Jacob Martin on 4/17/17.
//  Copyright © 2017 Jacob Martin. All rights reserved.
//

import Foundation

extension Array {
    var powerset: [[Element]] {
        guard count > 0 else {
            return [[]]
        }
        
        // tail contains the whole array BUT the first element
        let tail = Array(self[1..<endIndex])
        
        // head contains only the first element
        let head = self[0]
        
        // computing the tail's powerset
        let withoutHead = tail.powerset
        
        // mergin the head with the tail's powerset
        let withHead = withoutHead.map { $0 + [head] }
        
        // returning the tail's powerset and the just computed withHead array
        return withHead + withoutHead
    }
    
    func combinations(_ size: Int) -> [[Element]]{
        
        return powerset.filter { $0.count == size }
    }
}
