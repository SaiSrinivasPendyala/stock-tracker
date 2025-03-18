//
//  StockAPI.swift
//  StockPriceLive
//
//  Created by P Sai Srinivas on 22/02/25.
//

//da76cf0b6b1f4928846bf23d5af018cd

import Foundation
import Combine

struct StockDetailResponse: Codable {
    let data: [StockDetail]
}

struct StockDetail: Codable, Identifiable {
    var id: String { "\(symbol)_\(exchange)" }
    let symbol: String
    let name: String
    let currency: String
    let country: String
    let exchange: String
}

struct StockPrice: Codable { // ✅ Added missing struct
    let price: String
}

class StockAPI {
    static let shared = StockAPI()
    private let baseStockURL = "https://api.twelvedata.com/stocks?source=docs"
    private let basePriceURL = "https://api.twelvedata.com/price?apikey=da76cf0b6b1f4928846bf23d5af018cd"

    func fetchStockDetails() -> AnyPublisher<[StockDetail], Error> {
        guard let url = URL(string: baseStockURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: StockDetailResponse.self, decoder: JSONDecoder())
            .map { response in
                let uniqueStocks = Dictionary(grouping: response.data, by: { $0.symbol }) // Group by symbol
                    .compactMap { $0.value.first } // Keep only the first occurrence
                return uniqueStocks.filter { $0.currency == "USD" && $0.country == "United States"}
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func fetchStockPrice(for symbol: String) -> AnyPublisher<String, Error> {
        print("\(basePriceURL)&symbol=\(symbol)")
        guard let url = URL(string: "\(basePriceURL)&symbol=\(symbol)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: StockPrice.self, decoder: JSONDecoder())
            .map { stockPrice in
                stockPrice.price // ✅ Explicit type annotation for clarity
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
