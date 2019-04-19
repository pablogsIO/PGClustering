//
//  PGQuadTreeTest.swift
//  PGClusteringTests
//
//  Created by Pablo on 07/04/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import XCTest
import MapKit

@testable import PGClustering

class PGQuadTreeTest: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }

    func testQuadTree() {

        let boundingBox = PGBoundingBox(xSouthWest: CGFloat(0),
                                        ySouthWest: CGFloat(0),
                                        xNorthEast: CGFloat(100),
                                        yNorthEast: CGFloat(100))
        let quadTree = PGQuadTree(boundingBox: boundingBox)
        XCTAssertNotNil(quadTree)

    }

    func testQuadTreeDivide() {
        let longitude = -0.076132
        let latitude = 51.508530

        let quadTree = PGQuadTree(boundingBox: PGBoundingBox.mapRectToBoundingBox(mapRect: MKMapRect.world))
        XCTAssertNotNil(quadTree)
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = PGAnnotation(coordinate: location, title: "Test tilte", subtitle: "Test subtitle")
        quadTree.insertAnnotation(newAnnotation: annotation)
        quadTree.insertAnnotation(newAnnotation: annotation)
        quadTree.insertAnnotation(newAnnotation: annotation)
        quadTree.insertAnnotation(newAnnotation: annotation)
        quadTree.insertAnnotation(newAnnotation: annotation)
        assert(quadTree.isDivided)
    }

    func testPerformanceExample() {

        self.measure {

        }
    }

}
