import Foundation

public extension Array where Element: Equatable {
    public func removing(_ element: Element) -> [Element] {
        return self.filter { $0 != element }
    }
}

public extension Array {
    public func removingFirst() -> Array {
        return Array(dropFirst())
    }
}


public extension Dictionary {
    public func removingValue(forKey key: Key) -> Dictionary {
        var copy = self
        copy.removeValue(forKey: key)
        return copy
    }
}
