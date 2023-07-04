//
//  StockItemViewControllerTests.swift
//  VintraceTests
//
//  Created by Debashree Joshi on 4/7/2023.
//

import XCTest
@testable import Vintrace

final class StockItemViewControllerTests: XCTestCase {
    
    var viewController: StockItemViewController?
    var stock: Stock?
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Stock", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "StockItemViewController") as? StockItemViewController
        
        // Load the view hierarchy
        viewController?.loadViewIfNeeded()
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testConfigureUI() {
        // Access and assert the UI elements of the view controller
        XCTAssertNotNil(viewController?.carouselView)
        XCTAssertNotNil(viewController?.titleLabel)
        XCTAssertNotNil(viewController?.descriptionLabel)
        
        // Call the method under test
        viewController?.configureUI()
        
    }
    
    func testUpdateImageCountLabel() {
        // Set up the initial state of the view controller
        viewController?.currentImageIndex = 0
        viewController?.images = [UIImage(named: "wine-1")!, UIImage(named: "wine-3")!]
        
        // Call the method under test
        viewController?.updateImageCountLabel()
        
        // Assert the changes made to the imageCountLabel
        XCTAssertEqual(viewController?.imageCountLabel.text, "1/2")
        XCTAssertEqual(viewController?.imageCountLabel.layer.cornerRadius, 8)
        XCTAssertTrue(((viewController?.imageCountLabel.clipsToBounds) != nil))
    }
    
    
    func testHeaderViewTapped() {
        // Set up the initial state of the view controller
        viewController?.shouldShowHeader = true
        
        // Create a mock UITapGestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: nil, action: nil)
        
        // Call the method under test
        viewController?.headerViewTapped(tapGesture)
        
        // Assert the changes made to shouldShowHeader and the navigation bar
        XCTAssertFalse(viewController?.shouldShowHeader ?? true)
        // Add assertions to check the changes in the navigation bar appearance and buttons
        
        // Call the method under test again
        viewController?.headerViewTapped(tapGesture)
        
        // Assert the changes made to shouldShowHeader and the navigation bar
        XCTAssertTrue(viewController?.shouldShowHeader ?? false)
    }
    
    func testFetchData_HandleSuccess() {
        // Given
        let expectedStock = Stock(id: 1, code: "CHRD/EU/2016", description: "Standard EU export bottle", secondaryDescription: "Bottle - 750 ml", type: ItemType(name: "Single x1", code: "BOTTLED_BEVERAGE"), beverageProperties: nil, unit: Unit(name: "Unit", abbreviation: "x1", precision: 0), unitRequired: true, quantity: Quantity(onHand: 10, committed: 5, ordered: 2), owner: Owner(id: 1, name: "Owner"), images: nil, components: nil)
        let mockViewModel = MockStockItemViewModel(result: .success(expectedStock))
        viewController?.viewModel = mockViewModel
        
        // When
        viewController?.fetchData()
        
        // Then
        // Assert that the UI is updated correctly with the expected stock
        XCTAssertEqual(viewController?.titleLabel.text, expectedStock.code)
        XCTAssertEqual(viewController?.descriptionLabel.text, expectedStock.description)
        // Add more assertions as needed
    }
    
}

class MockStockItemViewModel: StockItemViewModel {
    var result: Result<Stock, Error>?
    var fetchDataCalled = false
    
    init(result: Result<Stock, Error>) {
        self.result = result
    }
    
    override func fetchData(completion: @escaping (Result<Stock, Error>) -> Void) {
        fetchDataCalled = true
        if let result = result {
            completion(result)
        }
    }
}

