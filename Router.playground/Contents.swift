import Foundation
import PlaygroundSupport

// MARK :- Routes

enum Route {
    case home
    case someNested(NestedRoute)
    case optionalParam(Int?)
    case queryParam(theme: Theme?)
    
    enum NestedRoute {
        case someInt(id: Int)
        case someString(name: String)
        case someUUID(UUID)
        case twoParams(String, Int)
        case threeParams(String, Int, Bool?)
    }
    
    enum Theme: String {
        case `default`
        case vip
    }
}

// MARK :- Isos
// Boilerplate code to handle isomorphisms between Routes and their associated values
// Can be generated eventually

extension Route {
    enum Iso {
        static let home = PartialIso<BasicUnit, Route>(
            apply: { _ in .some(Route.home) },
            unapply: { route in
                if case .home = route { return .unit }
                return nil
            }
        )
        
        static let someInt = PartialIso(
            apply: { Route.someNested(.someInt(id: $0)) },
            unapply: { route in
                guard case let .someNested(.someInt(result)) = route else { return nil }
                return result
            }
        )
        
        static let someString = PartialIso(
            apply: { Route.someNested(.someString(name: $0)) },
            unapply: { route in
                guard case let .someNested(.someString(result)) = route else { return nil }
                return result
            }
        )
        
        static let someUUID = PartialIso(
            apply: { Route.someNested(.someUUID($0)) },
            unapply: { route in
                guard case let .someNested(.someUUID(result)) = route else { return nil }
                return result
            }
        )
        
        static let optionalParam = PartialIso(
            apply: Route.optionalParam,
            unapply: { route in
                guard case let .optionalParam(result) = route else { return nil }
                return result
            }
        )
        
        static let queryParam = PartialIso(
            apply: Route.queryParam,
            unapply: { route in
                guard case let .queryParam(result) = route else { return nil }
                return result
            }
        )
        
        static let twoParams = PartialIso<(String, Int), Route>(
            apply: { Route.someNested(.twoParams($0.0, $0.1)) },
            unapply: { route in
                guard case let .someNested(.twoParams(result)) = route else { return nil }
                return result
            }
        )
        
        static let threeParams = PartialIso<(String, Int, Bool?), Route>(
            apply: { Route.someNested(.threeParams($0.0, $0.1, $0.2)) },
            unapply: { route in
                guard case let .someNested(.threeParams(result)) = route else { return nil }
                return result
            }
        )
    }
}

// MARK :- Describe the URLs that match each Route

extension Route {
    private static let parsers = [
        // case .home
        Route.Iso.home
            |* scheme("myapp")
            |+ host("goto")
            |+ path("home")
            +| end,
        
        // case .programme(id:)
        Route.Iso.someInt
            |* scheme("myapp")
            |+ host("goto")
            |+ path("nested")
            |+ path("int")
            |+ path(.int)
            +| end,
        
        // case .series(name:)
        Route.Iso.someString
            |* scheme("myapp")
            |+ host("goto")
            |+ path("nested")
            |+ path("string")
            |+ path(.string)
            +| end,
        
        Route.Iso.someUUID
            |* scheme("myapp")
            |+ host("goto")
            |+ path("nested")
            |+ path("uuid")
            |+ path(.uuid)
            +| end,
        
        // case .optionalParam(Int?)
        Route.Iso.optionalParam
            |* scheme("myapp")
            |+ host("goto")
            |+ path("optionalInt")
            |+ path(optional(.int))
            +| end,
        
        // case .queryParam(Theme?)
        Route.Iso.queryParam
            |* scheme("myapp")
            |+ host("goto")
            |+ path("queryParam")
            |+ query("theme", optional(Theme.iso))
            +| end,
        
        // case .twoParams(String, Int):
        Route.Iso.twoParams
            |* scheme("myapp")
            |+ host("goto")
            |+ path("nested")
            |+ path("twoParams")
            |+ path(.string)
            |+| path(.int)
            +| end,
        
        // case .threeParams(String, Int, Theme):
        Route.Iso.threeParams
            |* scheme("myapp")
            |+ host("goto")
            |+ path("nested")
            |+ path("threeParams")
            |+ path(.string)
            |+| path(.int)
            |+| query("test", optional(.bool))
            +| end
    ]
}

// MARK :- A bit API to facilitate the matching

extension Route {
    static func match(_ string: String) -> Route? {
        return URLData(string).flatMap(match)
    }
    
    static func match(_ url: URL) -> Route? {
        return match(URLData(url))
    }
    
    static func match(_ urlData: URLData) -> Route? {
        return parsers.lazy
            .compactMap { $0.parse(urlData)?.0 }
            .first
    }
}

// MARK :- Examples: Valid Routes
print( "🦍", Route.match("myapp://goto/home")! as Any )                                         // Basic example
print( "🦕", Route.match("myapp://goto/nested/int/123")! as Any )                               // Int path parameter
print( "🦅", Route.match("myapp://goto/nested/string/hello-world")! as Any )                    // String path parameter
print( "🦅", Route.match("myapp://goto/nested/uuid/\(UUID())")! as Any )                        // UUID path parameter
print( "🦑", Route.match("myapp://goto/nested/twoParams/hello-world/123")! as Any )             // Two parameters: string & int
print( "🐙", Route.match("myapp://goto/nested/threeParams/hello-world/123?test=true")! as Any ) // Three parameters: string & int & qs bool
print( "🐋", Route.match("myapp://goto/optionalInt/16")! as Any )                               // Optional Int path parameter
print( "🐊", Route.match("myapp://goto/queryParam?theme=vip")! as Any )                         // Query String queryparameter

// MARK :- Examples: Invalid Routes
Route.match("myapp://goto/homes")                 // Invalid path
Route.match("myapp://goto/home/more")             // Additional path after valid url
Route.match("myapp://goto/nested/someInt/one")    // Invalid int parameter
Route.match("myapp://goto/nested/someBool/hello") // Invalid bool parameter
Route.match("myapp://goto/optionalInt/string")    // String after nil Optional Int parameter

print("")
print("🦖", Date())
PlaygroundPage.current.finishExecution()
