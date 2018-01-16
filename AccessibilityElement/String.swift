//
//  String.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

extension String {
    public subscript(r: Range<Int>) -> Substring {
        let lowerBound = index(startIndex, offsetBy: r.lowerBound)
        let upperBound = index(startIndex, offsetBy: r.upperBound)
        return self[lowerBound..<upperBound]
    }
    public subscript(i: Int) -> Character {
        let bound = index(startIndex, offsetBy: i)
        return self[bound]
    }
}
