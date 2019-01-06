import Foundation

public extension Optional {
    public var isNil: Bool { return self == nil }
    public var isNotNil: Bool { return !isNil }
}
