//
//  TreeElement.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

public protocol TreeElement {
    func up() throws -> Self
    func down() throws -> [Self]
}

extension TreeElement where Self : Hashable {
    public func walk(_ visitor: (Self) -> Void) {
        var elements = [Self]()
        var visited = Set<Self>()
        elements.append(self)
        while elements.count > 0 {
            let element: Self = elements[0]
            elements.remove(at: 0)
            if !visited.contains(element) {
                do {
                    visitor(element)
                    let children = try element.down()
                    elements.append(contentsOf: children)
                } catch let error {
                    os_log("%@", error.localizedDescription)
                }
                visited.insert(element)
            }
        }
    }
}
