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
    
    func displayAnnotations(annotations: [MKAnnotation])
}

class PGClusteringManager {

    private var operationQueue = OperationQueue()
    private var dispatchQueue = DispatchQueue(label: "io.pablogs.concurrent", attributes: DispatchQueue.Attributes.concurrent)

    public weak var delegate: PGClusteringManagerDelegate?
    
    private let quadTree = PGQuadTree(boundingBox: PGBoundingBox.mapRectToBoundingBox(mapRect: MKMapRect.world))

    init(annotations: [MKAnnotation]) {

        self.addAnnotations(annotations: annotations)
    }
    
    public func addAnnotation(annotation: MKAnnotation) {
        operationQueue.cancelAllOperations()
        dispatchQueue.async {
            self.quadTree.insertAnnotation(newAnnotation: annotation)
        }
    }

    public func addAnnotations(annotations: [MKAnnotation]) {
        operationQueue.cancelAllOperations()
        dispatchQueue.async {
            for annotation in annotations {
                self.quadTree.insertAnnotation(newAnnotation: annotation)
            }
        }
    }

    public func clusterAnnotationWithinMapRectangle(visibleMapRect: MKMapRect, zoomScale: Double) {

        guard !zoomScale.isInfinite else {
            return
        }
        var clusterAnnotations = [MKAnnotation]()
        let cellSizePoints = Double(visibleMapRect.size.width/Double(PGClusteringManager.cellSizeForZoomScale(zoomScale: MKZoomScale(zoomScale))))
        let minX = visibleMapRect.minX
        let maxX = visibleMapRect.maxX
        let minY = visibleMapRect.minY
        let maxY = visibleMapRect.maxY

        operationQueue.cancelAllOperations()
        operationQueue.addOperation {

            var yCoordinate = minY

            while yCoordinate<maxY {
                var xCoordinate = minX

                while xCoordinate<maxX {
                    let area = PGBoundingBox.mapRectToBoundingBox(mapRect: MKMapRect(x: xCoordinate, y: yCoordinate, width: cellSizePoints, height: cellSizePoints))
                    self.quadTree.queryRegion(searchInBoundingBox: area) { (annotations) in
                        
                        if annotations.count>1 {
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
                    xCoordinate+=cellSizePoints
                }
                yCoordinate+=cellSizePoints
            }
            self.delegate?.displayAnnotations(annotations: clusterAnnotations)
        }
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
            return 32
        case 5...8:
            return 16
        case 9...16:
            return 8
        case 17...20:
            return 4
        default:
            return 10
        }
    }

}
