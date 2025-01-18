//
//  BitcoinRateResponce.swift
//  TransactionsTestTask
//
//

import Foundation

struct BitcoinRateResponce: Decodable {
    let code: String
    let symbol: String
    let rate: Double
    
    enum CodingKeys: String, CodingKey {
        case bpi
    }
    
    enum BpiCodingKeys: String, CodingKey {
        case usd = "USD"
    }
    
    enum CurrencyCodingKeys: String, CodingKey {
        case code
        case symbol
        case rate = "rate_float"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let briContainer = try container.nestedContainer(keyedBy: BpiCodingKeys.self, forKey: .bpi)
        let currencyContainer = try briContainer.nestedContainer(keyedBy: CurrencyCodingKeys.self, forKey: .usd)
        
        self.code = try currencyContainer.decode(String.self, forKey: .code)
        self.symbol = try currencyContainer.decode(String.self, forKey: .symbol)
        self.rate = try currencyContainer.decode(Double.self, forKey: .rate)
    }
}
