import NIOHTTP1
import Foundation

protocol Endpoint {
    associatedtype Response: Codable
    associatedtype Body: Codable
    var path: String { get }
    var method: HTTPMethod { get }
    var body: Body? { get }
}

extension Endpoint {
    public var body: Body? {
        return nil
    }
}

protocol PipelineEndpoint: Endpoint {
    func map(data: String) throws -> Self.Response
}

protocol StreamingTarEndpoint: Endpoint {
    typealias Body = Data
}
