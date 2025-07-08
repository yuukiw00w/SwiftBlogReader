//
//  Item.swift
//  SwiftBlogReader
//
//  Created by Yuuki Noseda on 2025/07/08.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
