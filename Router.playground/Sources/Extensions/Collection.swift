import Foundation

public extension Collection {
    public subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension Collection {
    public func toDictionary<Key, Value>() -> [Key : Value] where Element == (Key, Value) {
        return Dictionary(self) { _, last in last }
    }
}
