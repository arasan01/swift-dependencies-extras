//
//  DependenciesExtraAppTests.swift
//  DependenciesExtraAppTests
//
//  Created by arasan01 on 2023/12/06.
//

import XCTest
import DependenciesExtrasMacros
@testable import DependenciesExtraApp

final class DependenciesExtraAppTests: XCTestCase {

    var count = 0
    
    override func invokeTest() {
        count = 0
        withDependencies {
            $0 = .live
            $0.underline.call = { @Sendable in self.count += 1 }
        } operation: {
            super.invokeTest()
        }
    }

    
    func testHoge() {
        let model = ContentViewModel()
        model.tappedButton()
        XCTAssertEqual(model.label, "data")
        
        model.tappedWButton()
        XCTAssertEqual(model.label, "wrapped")
    }
    
    func testPerformanceNormal() throws {
        let model = ContentViewModel()
        measure {
            for _ in 0..<200_000 {
                model.tappedButton()
            }
        }
        XCTAssertEqual(2_000_000, count)
    }
    
    func testPerformanceWrapped() throws {
        let model = ContentViewModel()
        measure {
            for _ in 0..<200_000 {
                model.tappedWButton()
            }
        }
        XCTAssertEqual(2_000_000, count)
    }
}
