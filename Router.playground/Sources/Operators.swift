// MARK :- Operators

infix operator |*  :ConversionPrecedenceGroup
infix operator |+  :CombinationPrecedenceGroup
infix operator  +| :CombinationPrecedenceGroup
infix operator |+| :CombinationPrecedenceGroup


// MARK :- Precedence Groups

precedencegroup ConversionPrecedenceGroup {
    associativity: left
    higherThan: AssignmentPrecedence
}

precedencegroup CombinationPrecedenceGroup {
    associativity: left
    higherThan: ConversionPrecedenceGroup
}


// MARK :- Operator Implementations

/// Converts a parser of `A` to a parser of `B` using the given isomorphism (left hand side of the infix operator)
public func |* <A, B> (_ iso: PartialIso<A, B>, _ parser: Parser<A>) -> Parser<B> {
    return Parser { url in
        guard let (a, remainder) = parser.parse(url),
            let b = iso.apply(a)
            else { return nil }
        
        return (b, remainder)
    }
}

public extension Parser {
    
    /// Composes two parsers together, keeping the result of the right hand parser if successful.
    public static func |+ <B> (_ parserA: Parser, _ parserB: Parser<B>) -> Parser<B> {
        return Parser<B> { url in
            guard let (_, remainder) = parserA.parse(url) else { return nil }
            return parserB.parse(remainder)
        }
    }
    
    /// Composes two parsers together, keeping the result of the left hand parser if successful.
    public static func +| <B> (_ parserA: Parser, _ parserB: Parser<B>) -> Parser<A> {
        return Parser<A> { url in
            guard let (a, remainder) = parserA.parse(url),
                let (_, _) = parserB.parse(remainder)
                else { return nil }
            
            return (a, remainder)
        }
    }
    
    /// Composes two parsers together, keeping the result from both as a tuple
    public static func |+| <B> (_ parserA: Parser, _ parserB: Parser<B>) -> Parser<(A, B)> {
        return Parser<(A, B)> { url in
            guard let (a, aRemainder) = parserA.parse(url),
                let (b, bRemainder) = parserB.parse(aRemainder)
                else { return nil }
            
            return ((a, b), bRemainder)
        }
    }
    
    /// Composes two parsers together, where the left parser is a 2-tuple, keeping and flattening the result from both
    /// sides as a 3-tuple
    public static func |+| <B, C> (_ parserAB: Parser<(A,B)>, _ parserC: Parser<C>) -> Parser<(A, B, C)> {
        return Parser<(A, B, C)> { url in
            guard let (ab, abRemainder) = parserAB.parse(url),
                let (c, cRemainder) = parserC.parse(abRemainder)
                else { return nil }
            
            return ((ab.0, ab.1, c), cRemainder)
        }
    }
}
