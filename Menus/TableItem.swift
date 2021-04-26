/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The model object representing each item in the master table view.
*/

import Foundation

enum TableItem {
    case date(Date)
    case text(String)
}

extension TableItem: CustomStringConvertible {
    var description: String {
        switch self {
        case let .date(date):
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .medium
            return dateFormatter.string(from: date)
        case let .text(text):
            return text
        }
    }
}
