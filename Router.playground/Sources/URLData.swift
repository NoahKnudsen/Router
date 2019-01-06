import Foundation

public struct URLData: Settable {
    public var scheme: String?
    public var host: String?
    public var path: [String]
    public var query: [String : String]
}

public extension URLData {
    private static let excludedPathComponents = ["/"]
    
    public init(_ url: URL) {
        scheme = url.scheme
        host = url.host
        path = url.pathComponents.filter { !URLData.excludedPathComponents.contains($0) }
        query = url.query.map(URLData.parseQueryString) ?? [:]
    }
    
    public init?(_ string: String) {
        guard let url = URL(string) else { return nil }
        self.init(url)
    }
    
    public static func parseQueryString(_ queryString: String) -> [String: String] {
        return queryString
            .split(separator: "&")
            .compactMap { params -> (key: String, value: String)? in
                let components = params.split(separator: "=").map(String.init)
                return components[safe: 1].map { (components[0], $0) }
            }
            .toDictionary()
    }
}
