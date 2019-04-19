//
//  PGClusteringManager.swift
//  PGClustering
//
//  Created by Pablo on 07/02/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import UIKit
import MapKit

protocol PGClusteringManagerDelegate: class {
    
    func displayAnnotations()
}

class PGClusteringManager {

    public var mapView: MKMapView!
    public weak var delegate: PGClusteringManagerDelegate?
    
    private let quadTree = PGQuadTree(boundingBox: PGBoundingBox.mapRectToBoundingBox(mapRect: MKMapRect.world))

    init(annotations: [PGAnnotation]) {

        for annotation in annotations {
            quadTree.insertAnnotation(newAnnotation: annotation)
        }
    }

    private func drawPolyline(box: PGBoundingBox) {

        let bottomLeft = CLLocationCoordinate2D(latitude: CLLocationDegrees(box.xSouthWest), longitude: CLLocationDegrees(box.ySouthWest))
        let topLeft = CLLocationCoordinate2D(latitude: CLLocationDegrees(box.xSouthWest), longitude: CLLocationDegrees(box.yNorthEast))
        let bottomRight = CLLocationCoordinate2D(latitude: CLLocationDegrees(box.xNorthEast), longitude: CLLocationDegrees(box.ySouthWest))
        let topRight = CLLocationCoordinate2D(latitude: CLLocationDegrees(box.xNorthEast), longitude: CLLocationDegrees(box.yNorthEast))
        let coordinates = [bottomLeft,bottomRight, topRight, topLeft, bottomLeft]
        let polyline = MKPolyline(coordinates: coordinates, count: 5)
        
        mapView.addOverlay(polyline)

    }
    public func clusterAnnotationWithinMapRectangle(visibleMapRect: MKMapRect, zoomScale: Double) -> [PGAnnotation] {

        guard !zoomScale.isInfinite else {
            return []
        }
        var clusterAnnotations = [PGAnnotation]()
        let cellSizePoints = Double(visibleMapRect.size.width/Double(PGClusteringManager.cellSizeForZoomScale(zoomScale: MKZoomScale(zoomScale))))
        let minX = visibleMapRect.minX
        let maxX = visibleMapRect.maxX
        let minY = visibleMapRect.minY
        let maxY = visibleMapRect.maxY
        
        var iterator = 1
        var iteratorSecond = 1
        var iCoordinate = minY
        while iCoordinate<maxY {
            var jCoordinate = minX
            iterator = 1
            while jCoordinate<maxX {
                let area = PGBoundingBox.mapRectToBoundingBox(mapRect: MKMapRect(x: jCoordinate, y: iCoordinate, width: cellSizePoints, height: cellSizePoints))
                //drawPolyline(box: area)
                self.quadTree.queryRegion(searchInBoundingBox: area) { (annotations) in
                    
                    if annotations.count>1 {
                        print("\(annotations.count) in (\(iterator),\(iteratorSecond))")
                        var totalX = 0.0
                        var totalY = 0.0
                        
                        for annotation in annotations {
                            totalX += annotation.coordinate.latitude
                            totalY += annotation.coordinate.longitude
                        }
                        let totalAnnotations = annotations.count
                        
                        clusterAnnotations.append(PGAnnotation(coordinate: CLLocationCoordinate2D(latitude: totalX/Double(totalAnnotations), longitude: totalY/Double(totalAnnotations)), title: "\(annotations.count)", subtitle: "Clustered"))
                    } else if annotations.count == 1 {
                        clusterAnnotations.append(annotations.first!)
                    }
                }
                jCoordinate+=cellSizePoints
                iterator+=1
            }
            iteratorSecond+=1
            iCoordinate+=cellSizePoints
        }
        return clusterAnnotations
    }
 
}

extension PGClusteringManager {

    class func zoomScaleToZoomLevel(scale: MKZoomScale) -> Int {

        let totalTilesAtMaxZoom = MKMapSize.world.width / 256.0
        let zoomLevelAtMaxZoom = CGFloat(log2(totalTilesAtMaxZoom))
        
        return Int(max(0,zoomLevelAtMaxZoom+CGFloat(floor(log2f(Float(scale))+0.5))))

    }

    class func cellSizeForZoomScale(zoomScale: MKZoomScale) -> Int {
        
        let zoomLevel = zoomScaleToZoomLevel(scale: zoomScale)
        
        switch zoomLevel {
        case 0...4:
            return 4
        case 5...8:
            return 8
        case 9...16:
            return 16
        case 17...20:
            return 4
        default:
            return 10
        }
    }

}
