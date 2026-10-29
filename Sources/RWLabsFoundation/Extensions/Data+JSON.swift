//
//  Data+JSON.swift
//  RWLabsFoundation
//
//  Created by RWLabs
//

import Foundation

public extension Data {
    /// Pretty-printed JSON for logging, or `nil` if the data is not JSON
    var prettyPrintedJSON: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: [.fragmentsAllowed]),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .fragmentsAllowed]) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}
