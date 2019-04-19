//
//  PGClusteringManagerTest.swift
//  PGClusteringTests
//
//  Created by Pablo on 04/04/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import XCTest
import MapKit

@testable import PGClustering

class PGClusteringManagerTest: XCTestCase {

    private let latitudeLongitudeDelta = 0.0275
    private let longitude = -0.076132
    private let latitude = 51.508530

    override func setUp() {

    }

    override func tearDown() {

    }

    func testPGQuadTree() {

        let boundingBox = PGBoundingBox(xSouthWest: CGFloat(0),
                                        ySouthWest: CGFloat(0),
                                        xNorthEast: CGFloat(100),
                                        yNorthEast: CGFloat(100))
        XCTAssertNotNil(boundingBox)
        let quadTree = PGQuadTree(boundingBox: boundingBox)
        XCTAssertNotNil(quadTree)
    }

    func testManager() {
        let annotations = self.getRandomAnnotations()
        assert(annotations.count != 0)
        let clusteringManager = PGClusteringManager(annotations: annotations)
        XCTAssertNotNil(clusteringManager)
    }

    func testCellSize() {

        let annotations = self.getRandomAnnotations()
        assert(annotations.count != 0)
        let clusteringManager = PGClusteringManager(annotations: annotations)
        XCTAssertNotNil(clusteringManager)
    }
    func testPerformanceExample() {

        self.measure {

        }
    }

    private func getRandomAnnotations() -> [PGAnnotation] {

        var annotations = [PGAnnotation]()

        for _ in 1...100 {
            let annotation = self.getAnnotation()
            annotations.append(annotation)
        }
        return annotations
    }
    private func getAnnotation() -> PGAnnotation {

        let longitude = Double.random(in: -latitudeLongitudeDelta/2...latitudeLongitudeDelta/2)
        let latitude = Double.random(in: -latitudeLongitudeDelta/2...latitudeLongitudeDelta/2)

        return PGAnnotation(coordinate: CLLocationCoordinate2D(latitude: self.latitude+latitude,
                                                               longitude: self.longitude+longitude),
                            title: "",
                            subtitle: "")

    }
}
