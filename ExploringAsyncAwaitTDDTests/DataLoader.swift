//
//  DataLoader.swift
//  ExploringAsyncAwaitTDDTests
//
//  Created by Daniel Reyes Sanchez on 21/07/21.
//

import Foundation

struct DataLoader {
    
    private let bundle: Bundle
    
    init(identifier: String = "com.walmart.ExploringAsyncAwaitTDD") {
        self.bundle = Bundle(identifier: identifier)!
    }
    
    func loadData(from fileName: String) -> Data {
        guard
            let url = bundle.url(forResource: fileName, withExtension: "json"),
            let data = try? Data(contentsOf: url)
            else {
                return Data()
        }
        return data
    }
}
