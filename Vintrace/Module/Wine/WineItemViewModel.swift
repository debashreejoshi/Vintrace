//
//  WineItemViewModel.swift
//  Vintrace
//
//  Created by Debashree Joshi on 30/6/2023.
//

import Foundation

class WineItemViewModel {
    
    var wineModelItem: WineModel?
    var sections: [Section] = []
    private var componentsCount: Int = 0
        
    // Fetch the JSON data and parse it into StockItem objects
    func fetchData(completion: @escaping (Result<WineModel, Error>) -> Void) {
        guard let jsonData = readJSONFromFile() else {
            completion(.failure(DataLoadingError.fileNotFound))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(WineModel.self, from: jsonData)
            wineModelItem = decodedData
            self.componentsCount = wineModelItem?.components?.count ?? 0
            sections = componentsCount > 0 ? [.levels, .components] : [.levels]
            completion(.success(decodedData))
        } catch {
            completion(.failure(error))
            print("Error decoding JSON: \(error)")
        }
    }
    
    // Read JSON data from file
    private func readJSONFromFile() -> Data? {
        if let path = Bundle.main.path(forResource: "stock-item-1", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                return data
            } catch {
                return nil
            }
        }
        return nil
    }
}

// Enum representing the sections
enum Section: Int {
    case levels = 0
    case components = 1
    
    static let allSections: [Section] = [.levels, .components]
        
}

// Error enum for data loading
enum DataLoadingError: Error {
    case fileNotFound
}
