import Foundation
import PlaygroundSupport

// MARK :- Routes

enum Route {
    case home
    case article(id: Int, theme: Theme?)
    case discover(DiscoverRoute)
    
    enum DiscoverRoute {
        case programme(id: UUID)
        case series(name: String)
        case other(String, Int, Bool?)
    }
    
    enum Theme: String {
        case `default`
        case vip
    }
}

// MARK :- Isos
// Boilerplate code to handle isomorphisms between Routes and their associated values
// Can be code generated

extension Route {
    enum Iso {
        static let home = PartialIso<BasicUnit, Route>(
            apply: { _ in .some(Route.home) },
            unapply: { route in
                if case .home = route { return .unit }
                return nil
            }
        )
        
        static let article = PartialIso<(Int, Theme?), Route>(
            apply: { .article(id: $0.0, theme: $0.1) },
            unapply: { route in
                guard case let .article(result) = route else { return nil }
                return result
            }
        )
        
        enum Discover {
            static let programme = PartialIso(
                apply: { Route.discover(.programme(id: $0)) },
                unapply: { route in
                    guard case let .discover(.programme(result)) = route else { return nil }
                    return result
                }
            )
            
            static let series = PartialIso(
                apply: { Route.discover(.series(name: $0)) },
                unapply: { route in
                    guard case let .discover(.series(result)) = route else { return nil }
                    return result
                }
            )
            
            static let other = PartialIso<(String, Int, Bool?), Route>(
                apply: { .discover(.other($0.0, $0.1, $0.2)) },
                unapply: { route in
                    guard case let .discover(.other(result)) = route else { return nil }
                    return result
                }
            )
        }
    }
}

// MARK :- Describe the URLs that match each Route

extension Route {
    private static let parsers = [
        Route.Iso.home
            |* scheme("myapp")
            |+ host("goto")
            |+ path("home")
             +| end,
        
        Route.Iso.article
            |* scheme("myapp")
            |+ host("goto")
            |+ path("article")
            |+ path(.int)
            |+| query("theme", optional(Theme.iso))
             +| end,
        
        Route.Iso.Discover.programme
            |* scheme("myapp")
            |+ host("goto")
            |+ path("discover")
            |+ path("programme")
            |+ path(.uuid)
             +| end,
        
        Route.Iso.Discover.series
            |* scheme("myapp")
            |+ host("goto")
            |+ path("discover")
            |+ path("series")
            |+ path(.string)
             +| end,
        
        Route.Iso.Discover.other
            |* scheme("myapp")
            |+ host("goto")
            |+ path("discover")
            |+ path("other")
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
print( "🦍", Route.match("myapp://goto/home")! )                           // Basic example
print( "🦕", Route.match("myapp://goto/article/123?theme=vip")! )          // Int path parameter + optional query string
print( "🦅", Route.match("myapp://goto/discover/programme/\(UUID())")! )   // UUID path parameter
print( "🐋", Route.match("myapp://goto/discover/series/the-sinner)")! )    // String path parameter
print( "🐙", Route.match("myapp://goto/discover/other/hello-world/123?test=true")! ) // Three parameters: string & int & qs bool

// MARK :- Examples: Invalid Routes
Route.match("myapp://goto/homes")                           // Invalid path
Route.match("myapp://goto/home/more")                       // Additional path after valid url
Route.match("myapp://goto/article?theme=vip")               // Missing int parameter
Route.match("myapp://goto/discover/programme/not-a-uuid")   // Invalid type for parameter

print("")
print("🦖", Date())
PlaygroundPage.current.finishExecution()
