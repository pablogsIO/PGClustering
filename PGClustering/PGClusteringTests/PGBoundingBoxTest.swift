//
//  PGBoundingBox.swift
//  PGClusteringTests
//
//  Created by Pablo on 06/04/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import XCTest
import MapKit

@testable import PGClustering

class PGBoundingBoxTest: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }

    func testIntersection() {
        let boundingBox = PGBoundingBox(xSouthWest: CGFloat(0),
                                        ySouthWest: CGFloat(0),
                                        xNorthEast: CGFloat(100),
                                        yNorthEast: CGFloat(100))
        XCTAssertNotNil(boundingBox)
        let boxIntersection = PGBoundingBox(xSouthWest: CGFloat(50),
                                            ySouthWest: CGFloat(50),
                                            xNorthEast: CGFloat(150),
                                            yNorthEast: CGFloat(150))
        XCTAssertNotNil(boxIntersection)
        let intersection = boundingBox.intersectsWithBoundingBox(boundingBox: boxIntersection)
        assert(intersection)
        //No intersection
        let boxNoIntersection = PGBoundingBox(xSouthWest: CGFloat(200),
                                            ySouthWest: CGFloat(200),
                                            xNorthEast: CGFloat(150),
                                            yNorthEast: CGFloat(150))
        XCTAssertNotNil(boxNoIntersection)
        let noIntersection = boxIntersection.intersectsWithBoundingBox(boundingBox: boxNoIntersection)
        assert(!noIntersection)

    }

}
