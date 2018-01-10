//
//  Describer.swift
//
//  Copyright © 2018 Doug Russell. All rights reserved.
//

import Foundation
import os.log

extension Array where Element == String? {
    public func prune() -> [String] {
        var strings = [String]()
        for maybe in self {
            if let string = maybe, string.count > 0 {
                strings.append(string)
            }
        }
        return strings
    }
}

public protocol DescriberRequest {
    
}

public class Describer<ElementType> where ElementType : AccessibilityElement {
    public enum Attribute {
        case role
        case roleDescription
        case subrole
        case title
        case titleElement(DescriberRequest)
        case description
        case stringValue
        case numberValue
        case toggleValue
        case checkboxValue
        case attachmentText
    }
    public struct Single : DescriberRequest {
        public let required: Bool
        public let attribute: Attribute
    }
    public struct Fallthrough : DescriberRequest {
        public let required: Bool
        public let attributes: [Attribute]
    }
    private func twoState(element: ElementType, on: String, off: String) -> String? {
        do {
            let value = try element.value()
            if let number = value as? NSNumber {
                // TODO: Localize
                return number.boolValue ? on : off
            } else if let string = value as? String {
                switch string {
                case "0":
                    // TODO: Localize
                    return on
                case "1":
                    // TODO: Localize
                    return off
                default:
                    return nil
                }
            }
            return nil
        } catch {
            return nil
        }
    }
    private func value(attribute: Attribute, element: ElementType) -> String? {
        switch attribute {
        case .role:
            return try? element.role().rawValue
        case .roleDescription:
            if let roleDescription = try? element.roleDescription() {
                return roleDescription
            }
            guard let role = try? element.role() else {
                return nil
            }
            let subrole = try? element.subrole()
            return role.description(with: subrole)
        case .subrole:
            return try? element.subrole().rawValue
        case .title:
            return try? element.title()
        case .titleElement(let request):
            do {
                let titleElement = try element.titleElement()
                return try describe(element: titleElement, requests: [request])[0]
            } catch {
                return nil
            }
        case .description:
            return try? element.description()
        case .stringValue:
            return (try? element.value()) as? String
        case .numberValue:
            return nil
        case .toggleValue:
            return twoState(element: element, on: "on", off: "off")
        case .checkboxValue:
            return twoState(element: element, on: "checked", off: "unchecked")
        case .attachmentText:
            do {
                let count = try element.numberOfCharacters()
                let attributedText = try element.attributedString(range: 0..<count)
                os_log("attributed text %@", attributedText.debugDescription)
            } catch let error {
                os_log("attributed text error: %@", error.localizedDescription)
            }
            return nil
        }
    }
    public enum Error : Swift.Error {
        case nilRequirement
    }
    public func describe(element: ElementType,
                         requests: [DescriberRequest]) throws -> [String?] {
        var results = [String?]()
        for request in requests {
            if let single = request as? Single {
                let value = self.value(attribute: single.attribute, element: element)
                if single.required && value == nil {
                    throw Describer.Error.nilRequirement
                }
                results.append(value)
            } else if let fall = request as? Fallthrough {
                var value: String?
                for attribute in fall.attributes {
                    value = self.value(attribute: attribute, element: element)
                    if value != nil {
                        break
                    }
                }
                if fall.required && value == nil {
                    throw Describer.Error.nilRequirement
                }
                results.append(value)
            } else {
                fatalError()
            }
        }
        return results
    }
}
