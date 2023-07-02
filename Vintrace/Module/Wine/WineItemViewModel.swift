//
//  WineItemViewModel.swift
//  Vintrace
//
//  Created by Debashree Joshi on 30/6/2023.
//

import Foundation

class WineItemViewModel {
    
    var wineModelItem: WineModel?
    private var componentsCount: Int = 0
    
    // Closure-based data binding for updates
    var onUpdate: ((WineModel?) -> Void)?
    
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
            self.componentsCount = wineModelItem?.components.count ?? 0
            onUpdate?(wineModelItem) // Notify the view controller about the data update
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
    
    // Provide the number of rows in a given section
    func numberOfRowsInSection(section: Section) -> Int {
        switch section {
        case .components:
            return componentsCount
        case .levels:
            return 4
        }
    }
}

// Enum representing the sections
enum Section: String {
    case components = "Components"
    case levels = "Levels"
    
    static let allSections: [Section] = [.levels, .components]
}

// Error enum for data loading
enum DataLoadingError: Error {
    case fileNotFound
}
