//
//  PGClusteringTests.swift
//  PGClusteringTests
//
//  Created by Pablo on 20/01/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import XCTest
@testable import PGClustering

class PGClusteringTests: XCTestCase {

    override func setUp() {

    }

    override func tearDown() {

    }

    func testBoundaryBox() {
        let totalPoints = 10
        let iPhone7Size =  CGRect(x: 0, y: 0, width: 414, height: 736)
        let tree = QuadTree(boundingBox: iPhone7Size)

        var index = 1

        while index <= totalPoints {
            let xCoordinate = CGFloat.random(in: iPhone7Size.origin.x ... iPhone7Size.width)
            let yCoordinate = CGFloat.random(in: iPhone7Size.origin.y ... iPhone7Size.height)
            tree.insertPoint(newPoint: CGPoint(x: xCoordinate, y: yCoordinate), view: UIView())
            index += 1
        }
        let clusteringManager = PGClusteringManager(quadtree: tree)
        let clusters = clusteringManager.clusterAnnotationsWithinRectangle(rectangle: iPhone7Size)
        var pointsInClusters = 0
        print("pablogsio: totalCluster: \(clusters.count)")
        for cluster in clusters {
            print("pablogsio: (\(cluster.origin.x),\(cluster.origin.y)) - \(cluster.points)")
            pointsInClusters += cluster.points
        }
        XCTAssert(pointsInClusters == totalPoints)

    }

    func testPerformanceExample() {

        self.measure {

        }
    }

}
