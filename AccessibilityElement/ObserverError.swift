//
//  ObserverError.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation

extension ObserverManager {
    public enum Error : Swift.Error {
        case invalidApplication
        case invalidToken
    }
}
