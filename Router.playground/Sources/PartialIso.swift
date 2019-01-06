import Foundation

// Partial Isomorphisms
/// An object used to convert between two types
public struct PartialIso<A, B> {
    public let apply: (A) -> B?
    public let unapply: (B) -> A?
    
    public init(apply: @escaping (A) -> B?, unapply: @escaping (B) -> A?) {
        self.apply = apply
        self.unapply = unapply
    }
}

public extension RawRepresentable {
    /// An isomorphism between a raw value and a RawRepresentable type
    public static var iso: PartialIso<RawValue, Self> {
        return PartialIso(
            apply: Self.init(rawValue:),
            unapply: { $0.rawValue }
        )
    }
}

public extension PartialIso {
    /// An isomorphism between a String and an Int
    public static var int: PartialIso<String, Int> {
        return PartialIso<String, Int>(
            apply: Int.init,
            unapply: { "\($0)" }
        )
    }
    
    /// An isomorphism between a String and a Bool
    public static var bool: PartialIso<String, Bool> {
        return PartialIso<String, Bool>(
            apply: Bool.init,
            unapply: { "\($0)" }
        )
    }
    
    /// An isomorphism between a String and a UUID
    public static var uuid: PartialIso<String, UUID> {
        return PartialIso<String, UUID>(
            apply: UUID.init,
            unapply: { "\($0)" }
        )
    }
    
    /// An identity isomorphism for strings
    public static var string: PartialIso<String, String> {
        return PartialIso<String, String>(
            apply: { $0 },
            unapply: { $0 }
        )
    }
}

/// Lifts an isomorphism into the world of optionals
// TODO: Where can this sit so that its not globally accessible?
public func optional<A, B>(_ iso: PartialIso<A, B>) -> PartialIso<A?, B?> {
    return PartialIso<A?, B?>(
        apply: { $0.flatMap(iso.apply) },
        unapply: { $0.flatMap(iso.unapply) }
    )
}
