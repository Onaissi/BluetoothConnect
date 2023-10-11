//
//  SortOptionsTests.swift
//  BluetoothConnectTests
//
//  Created by Ali Onaissi on 11/10/2023.
//

import XCTest
import CoreBluetooth
@testable import BluetoothConnect
final class SortOptionsViewModelTests: XCTestCase {
    
    var viewModel: SortOptionsViewModel!
    
    override func setUpWithError() throws {
        let deviceListViewModel = DeviceListViewModel(bluetoothFacade: MockBluetoothFacade())
        viewModel = SortOptionsViewModel(deviceListViewModel: deviceListViewModel, selectedOption: nil)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testNumberOfSections() throws{
        XCTAssertEqual(viewModel.numberOfSections(), 1)
    }
    
    func testNumberOfOptions() throws{
        XCTAssertEqual(viewModel.numberOfOptions(), 4)
    }
    
    func testOptionItemAt() throws{
        XCTAssertEqual(viewModel.optionItemAt(IndexPath(row:0, section: 0)).description(), AlphabeticalSort(isAscending: true).description())
    }
    
    func testSelectOption() throws{
        let indexPath = IndexPath(row: 1, section: 0)
        viewModel.selectOption(at: indexPath)
        XCTAssertEqual(viewModel.selectedOption.description(), AlphabeticalSort(isAscending: false).description())
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
