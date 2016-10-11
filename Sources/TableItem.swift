import Foundation

class TableItem: Hashable {
    var hashValue: Int {
        return 0
    }

    static func ==(lhs: TableItem, rhs: TableItem) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
