//
//  QuadTree.swift
//  PGClustering
//
//  Created by Pablo on 19/01/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import MapKit

class PGQuadTree {

    static let capacity = 4

    var annotations = [MKAnnotation]()
    var boundingBox: PGBoundingBox
    var isDivided = false

    private var northWest: PGQuadTree?
    private var northEast: PGQuadTree?
    private var southWest: PGQuadTree?
    private var southEast: PGQuadTree?

    init(boundingBox: PGBoundingBox) {
        self.boundingBox = boundingBox
    }
    
    public func insertAnnotation(newAnnotation: MKAnnotation) {

        guard self.boundingBox.containsCoordinate(coordinate: newAnnotation.coordinate) else {
            return
        }
        if annotations.count < PGQuadTree.capacity {
            annotations.append(newAnnotation)
        } else {
            if northWest == nil {
                self.subdivideNode()
            }
            northWest?.insertAnnotation(newAnnotation: newAnnotation)
            northEast?.insertAnnotation(newAnnotation: newAnnotation)
            southWest?.insertAnnotation(newAnnotation: newAnnotation)
            southEast?.insertAnnotation(newAnnotation: newAnnotation)
        }
    }

    func queryRegion(searchInBoundingBox: PGBoundingBox, completion: ([MKAnnotation]) -> Void) {
        guard searchInBoundingBox.intersectsWithBoundingBox(boundingBox: self.boundingBox) else {
            return
        }
        var totalAnnotations = [MKAnnotation]()
        for annotation in self.annotations {

            if searchInBoundingBox.containsCoordinate(coordinate: annotation.coordinate) {
                totalAnnotations.append(annotation)
            }
            
        }
        if self.isDivided {

            northEast?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (annotations) in
                totalAnnotations.append(contentsOf: annotations)
            })
            northWest?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (annotations) in
                totalAnnotations.append(contentsOf: annotations)
            })
            southEast?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (annotations) in
                totalAnnotations.append(contentsOf: annotations)
            })
            southWest?.queryRegion(searchInBoundingBox: searchInBoundingBox, completion: { (annotations) in
                totalAnnotations.append(contentsOf: annotations)
            })
        }
        completion(totalAnnotations)
    }

    func getSubQuadTrees() -> [PGQuadTree] {
        if isDivided {
            return [northWest!, northEast!, southWest!, southEast!]
        } else {
            return []
        }
    }
}

extension PGQuadTree {

    private func subdivideNode() {

        self.isDivided = true

        let xMiddle = (boundingBox.xNorthEast+boundingBox.xSouthWest)/2.0
        let yMiddle = (boundingBox.yNorthEast+boundingBox.ySouthWest)/2.0

        self.northWest = PGQuadTree(boundingBox: PGBoundingBox(xSouthWest: boundingBox.xSouthWest, ySouthWest: yMiddle, xNorthEast: xMiddle, yNorthEast: boundingBox.yNorthEast))
        self.northEast = PGQuadTree(boundingBox: PGBoundingBox(xSouthWest: xMiddle, ySouthWest: yMiddle, xNorthEast: boundingBox.xNorthEast, yNorthEast: boundingBox.yNorthEast))
        self.southWest = PGQuadTree(boundingBox: PGBoundingBox(xSouthWest: boundingBox.xSouthWest, ySouthWest: boundingBox.ySouthWest, xNorthEast: xMiddle, yNorthEast: yMiddle))
        self.southEast = PGQuadTree(boundingBox: PGBoundingBox(xSouthWest: xMiddle, ySouthWest: boundingBox.ySouthWest, xNorthEast: boundingBox.xNorthEast, yNorthEast: yMiddle))

    }

}
