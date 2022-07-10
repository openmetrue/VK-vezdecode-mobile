//
//  Agent.swift
//  Cats
//
//  Created by Mark Khmelnitskii on 10.04.2022.
//

import Foundation
import Combine

struct Agent {
    
    typealias Dict = [String: Any]
    
    func run<T: Decodable>(method: String = "GET", url: URL, access: String? = nil, parameters: [URLQueryItem]? = nil, headers: Dict? = nil, body: Dict? = nil) -> AnyPublisher<T,Error> {
        var urlComp = URLComponents(url: url, resolvingAgainstBaseURL: true)
        if let parameters = parameters { urlComp?.queryItems = parameters}
        
        var urlRequest = URLRequest(url: urlComp?.url ?? url)
        urlRequest.httpMethod = method
        
        headers?.forEach { (key, value) in urlRequest.addValue("\(value)", forHTTPHeaderField: key) }
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body { urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body) }
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap({ try handleURLResponse(output: $0, url: url)})
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func handleURLResponse(output: URLSession.DataTaskPublisher.Output, url: URL) throws -> Data {
        guard let response = output.response as? HTTPURLResponse
        else { throw NetworkingError.badURLResponse(url) }
        
        switch response.statusCode {
        case 200...299:
            return output.data
        case 400:
            throw NetworkingError.errorInputData
        case 401:
            throw NetworkingError.authError
        case 402...499:
            throw NetworkingError.badStatusCode(response.statusCode)
        case 500...599:
            throw NetworkingError.serverError
        default:
            throw NetworkingError.unknown
        }
    }
}
