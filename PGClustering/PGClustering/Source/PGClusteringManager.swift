//
//  PGClusteringManager.swift
//  PGClustering
//
//  Created by Pablo on 07/02/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import UIKit

struct ClusterPoint {
    let origin: CGPoint
    let points: Int
    let rectangle: CGRect
}

class PGClusteringManager {

    private let quadtree: QuadTree
    private let boxWidth = CGFloat(5.0)
    private let boxHeight = CGFloat(10.0)

    init(quadtree: QuadTree) {
        self.quadtree = quadtree
    }

    public func clusterAnnotationsWithinRectangle(rectangle: CGRect) -> [ClusterPoint] {

        var clusters = [ClusterPoint]()

        let boxArea = calculateBoxAreaSize(size: rectangle.size)
        var xCoordinate = rectangle.origin.x
        var yCoordinate = rectangle.origin.y

        while yCoordinate<rectangle.size.height {
            xCoordinate = rectangle.origin.x
            while xCoordinate<rectangle.size.width {
                let boundingBox = CGRect(x: xCoordinate, y: yCoordinate, width: boxArea.width, height: boxArea.height)
                quadtree.queryRegion(rectangle: boundingBox) { (points) in
                    if points.count != 0 {
                        var totalX = CGFloat(0)
                        var totalY = CGFloat(0)

                        for point in points {
                            totalX += point.x
                            totalY += point.y
                        }
                        let totalPoints = CGFloat(points.count)
                        clusters.append(ClusterPoint(origin: CGPoint(x: totalX/totalPoints,
                                                                     y: totalY/totalPoints),
                                                     points: points.count, rectangle: boundingBox))
                    }
                }
                xCoordinate += boxArea.width
            }
            yCoordinate += boxArea.height
        }

        return clusters
    }

    private func calculateBoxAreaSize(size: CGSize) -> CGSize {

        let width = size.width/boxWidth
        let height = size.height/boxHeight

        return CGSize(width: width, height: height)

    }

}
