// MARK :- Parser
/// An object that parses a URL, extracting neccessary values from it or returning nil if parsing fails
public struct Parser<A> {
    public let parse: (URLData) -> (A, URLData)?
    
    public init(parse: @escaping (URLData) -> (A, URLData)?) {
        self.parse = parse
    }
}


// MARK :- Some Parsers
// TODO: Where can these live so that they are not totally global or free? 

/// Creates a parser that checks the `scheme` against a given string and consumes it if it matches
public let scheme = Parser<BasicUnit>.prop(\.scheme)

/// Creates a parser that checks the `host` against a given string and consumes it if it matches
public let host   = Parser<BasicUnit>.prop(\.host)

/// Creates a parser that checks the next `path` parameter against a given string
/// and consumes the `path` parameter if it matches
public let path   = Parser<BasicUnit>.prop(first: \.path)

/// Creates a parser that converts the next `path` component using the given isomorphism.
/// The parser will consume the `path` parameter if the conversion is successful.
public func path<B>(_ iso: PartialIso<String, B>) -> Parser<B> {
    return Parser { url in
        guard let pathParam = url.path.first,
            let b = iso.apply(pathParam)
            else { return nil }
        
        return (b, url.transforming(\.path, { $0.removingFirst() }))
    }
}

/// Creates a parser that converts the next `path` component using the given isomorphism.
/// Used for isomorphisms where the `A` and `B` are optional types.
/// The parser will consume the `path` parameter if the conversion is successful.
public func path<B>(_ iso: PartialIso<String?, B?>) -> Parser<B?> {
    return Parser { url in
        if let pathParam = url.path.first,
            let b = iso.apply(pathParam)
        {
            return b.isNotNil
                ? (b, url.transforming(\.path, { $0.removingFirst() }))
                : (b, url)
        } else {
            return (Optional<B>.none, url)
        }
    }
}

/// Creates a parser that checks the next `query` string parameter against a given string
/// and consumes the `query` string parameter if it matches
public let query  = Parser<BasicUnit>.prop(dict: \.query)

/// Creates a parser that attempts to convert the given `query` string value using the given isomorphism.
/// The parser will consume the `query` parameter if the conversion is successful.
public func query<B>(_ key: String, _ iso: PartialIso<String, B>) -> Parser<B> {
    return Parser { url in
        guard let queryParam = url.query[key],
            let b = iso.apply(queryParam)
            else { return nil }
        
        return (b, url.transforming(\.query, { $0.removingValue(forKey: key) }))
    }
}

/// Creates a parser that attempts to convert the given `query` string value using the given isomorphism.
/// Used for isomorphisms where the `A` and `B` are optional types.
/// The parser will consume the `query` parameter if the conversion is successful.
public func query<B>(_ key: String, _ iso: PartialIso<String?, B?>) -> Parser<B?> {
    return Parser { url in
        guard let b = iso.apply(url.query[key]) else { return nil }
        
        return b.map { ($0, url.transforming(\.query, { $0.removingValue(forKey: key) })) }
    }
}

/// A Parser that checks the scheme, host and path to ensure that they have been consumed.
/// The query string is not checked.
public let end = Parser<BasicUnit>{ url in
    guard url.scheme.isNil,
        url.host.isNil,
        url.path.isEmpty
        else { return nil }
    
    return (.unit, url)
}


// MARK :- Parser creation helper methods

public extension Parser where A == BasicUnit {
    
    // Optional properties - Are consumed (set to nil) by the parser after being processed
    public static func prop<Value: Equatable>(_ keyPath: WritableKeyPath<URLData, Value?>) -> (Value) -> Parser {
        return { value in
            Parser { url in
                return url[keyPath: keyPath] == value
                    ? (.unit, url.setting(keyPath, to: Value?.none))
                    : nil
            }
        }
    }
    
    // First property in an Array
    public static func prop<Value: Equatable>(first keyPath: WritableKeyPath<URLData, [Value]>) -> (Value) -> Parser {
        return { value in
            Parser { url in
                return url[keyPath: keyPath].first == value
                    ? (.unit, url.transforming(keyPath, { $0.removingFirst() }))
                    : nil
            }
        }
    }
    
    // Keyed property in an Dictionary
    public static func prop<Key: Hashable, Value>(dict keyPath: WritableKeyPath<URLData, [Key : Value]>) -> (Key) -> Parser {
        return { key in
            Parser { url in
                return url[keyPath: keyPath][key].isNotNil
                    ? (.unit, url.transforming(keyPath, { $0.removingValue(forKey: key) }))
                    : nil
            }
        }
    }
}
