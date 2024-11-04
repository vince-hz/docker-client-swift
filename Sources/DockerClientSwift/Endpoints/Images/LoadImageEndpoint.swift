
import Foundation
import NIOHTTP1

struct LoadImageEndpoint: StreamingTarEndpoint {
    typealias Body = Data
    typealias Response = NoBody?
    let method: HTTPMethod = .POST
    var body: Data? {
        do {
            let fileURL = URL(fileURLWithPath: src)
            let fileData = try Data(contentsOf: fileURL)
            return fileData
        } catch {
            return nil
        }
    }

    let src: String
    var path: String {
        "images/load?quiet=false"
    }
}
