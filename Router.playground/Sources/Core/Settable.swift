import Foundation

public protocol Settable {}

public extension Settable {
    public func setting<Value>(_ kp: WritableKeyPath<Self, Value>, to value: Value) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    public func setting<Value>(_ kp: WritableKeyPath<Self, Value?>, to value: Value?) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    public func transforming<Value>(_ kp: WritableKeyPath<Self, Value>, _ transform: (Value) -> Value) -> Self {
        var copy = self
        copy[keyPath: kp] = transform(copy[keyPath: kp])
        return copy
    }
    
    public func transforming<Value>(_ kp: WritableKeyPath<Self, Value?>, _ transform: (Value?) -> Value?) -> Self {
        var copy = self
        copy[keyPath: kp] = transform(copy[keyPath: kp])
        return copy
    }
}
