//
//  PGBox.swift
//  PGClustering
//
//  Created by Pablo on 30/03/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import UIKit
import MapKit

struct PGBoundingBox {

    let xSouthWest: CGFloat
    let ySouthWest: CGFloat
    let xNorthEast: CGFloat
    let yNorthEast: CGFloat

    static func mapRectToBoundingBox(mapRect: MKMapRect) -> PGBoundingBox {

        let topLeft =  mapRect.origin.coordinate
        let botRight = MKMapPoint(x: mapRect.maxX, y: mapRect.maxY).coordinate

        let minLat = botRight.latitude
        let maxLat = topLeft.latitude

        let minLon = topLeft.longitude
        let maxLon = botRight.longitude

        return PGBoundingBox(xSouthWest: CGFloat(minLat),
                             ySouthWest: CGFloat(minLon),
                             xNorthEast: CGFloat(maxLat),
                             yNorthEast: CGFloat(maxLon))
    }

    func containsCoordinate(coordinate: CLLocationCoordinate2D) -> Bool {

        let isContainedInX = self.xSouthWest <= CGFloat(coordinate.latitude) && CGFloat(coordinate.latitude) <= self.xNorthEast
        let isContainedInY = self.ySouthWest <= CGFloat(coordinate.longitude) && CGFloat(coordinate.longitude) <= self.yNorthEast

        return (isContainedInX && isContainedInY)
    }

    func intersectsWithBoundingBox(boundingBox: PGBoundingBox) -> Bool {

        return (xSouthWest <= boundingBox.xNorthEast && xNorthEast >= boundingBox.xSouthWest &&
            ySouthWest <= boundingBox.yNorthEast && yNorthEast >= boundingBox.ySouthWest)
    }
}
