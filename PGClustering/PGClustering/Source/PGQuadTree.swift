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

class PGQuadTree {

    static let capacity = 4

    var annotations = [PGAnnotation]()

    var points = [CGPoint]()
    var boundingBox = CGRect()
    var isDivided = false
    var color = UIColor.random

    private var northWest: PGQuadTree?
    private var northEast: PGQuadTree?
    private var southWest: PGQuadTree?
    private var southEast: PGQuadTree?

    init(boundingBox: CGRect) {
        self.boundingBox = boundingBox
    }

    public func insertAnnotation(newAnnotation: PGAnnotation) {
        
    }
    public func insertPoint(newPoint: CGPoint) {

        guard self.boundingBox.contains(newPoint) else {
            return
        }
        if points.count < PGQuadTree.capacity && northWest == nil {
            points.append(newPoint)
        } else {
            if northWest == nil {
                self.subdivide()
            }
            northWest?.insertPoint(newPoint: newPoint)
            northEast?.insertPoint(newPoint: newPoint)
            southWest?.insertPoint(newPoint: newPoint)
            southEast?.insertPoint(newPoint: newPoint)
        }
    }

    public func insertPoint(newPoint: CGPoint, view: UIView) {

        guard self.boundingBox.contains(newPoint) else {
            return
        }
        if points.count < PGQuadTree.capacity && northWest == nil {
            points.append(newPoint)
            if points.count == 1 {
                //drawRectangle(rectangle: boundingBox, view: view)
            }

            let layer = self.drawPoint(point: newPoint, color: self.color)
            layer.add(opacityAnimation(beginAfter: CACurrentMediaTime(), duration: 0.2), forKey: "draw")
            view.layer.addSublayer(layer)
        } else {
            if northWest == nil {
                self.subdivide()
            }
            northWest?.insertPoint(newPoint: newPoint, view: view)
            northEast?.insertPoint(newPoint: newPoint, view: view)
            southWest?.insertPoint(newPoint: newPoint, view: view)
            southEast?.insertPoint(newPoint: newPoint, view: view)
        }
    }

    func queryRegion(rectangle: CGRect, completion: ([CGPoint]) -> Void) {

        guard boundingBox.intersects(rectangle) else {
            return
        }
        var totalPoints = [CGPoint]()
        for point in points {
            if rectangle.contains(point) {
                totalPoints.append(point)
            }
        }
        if self.isDivided {
            northEast?.queryRegion(rectangle: rectangle, completion: { (northEastPoints) in
                totalPoints.append(contentsOf: northEastPoints)
            })
            northWest?.queryRegion(rectangle: rectangle, completion: { (northWestPoints) in
                totalPoints.append(contentsOf: northWestPoints)
            })
            southEast?.queryRegion(rectangle: rectangle, completion: { (southEastPoints) in
                totalPoints.append(contentsOf: southEastPoints)
            })
            southWest?.queryRegion(rectangle: rectangle, completion: { (southWestPoints) in
                totalPoints.append(contentsOf: southWestPoints)
            })
        }

        completion(totalPoints)
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

    private func subdivide() {
        self.isDivided = true
        let offset = CGFloat(5)
        let width = self.boundingBox.width/2
        let height = self.boundingBox.height/2
        let size = CGSize(width: width-offset, height: height-offset)

        self.northWest = PGQuadTree(boundingBox: CGRect(origin: CGPoint(x: self.boundingBox.origin.x+offset/2,
                                                                      y: self.boundingBox.origin.y+offset/2),
                                                      size: size))
        self.northEast = PGQuadTree(boundingBox: CGRect(origin: CGPoint(x: self.boundingBox.origin.x+width+offset/2,
                                                                      y: self.boundingBox.origin.y+offset/2),
                                                      size: size))
        self.southWest = PGQuadTree(boundingBox: CGRect(origin: CGPoint(x: self.boundingBox.origin.x+offset/2,
                                                                      y: self.boundingBox.origin.y+height+offset/2),
                                                      size: size))
        self.southEast = PGQuadTree(boundingBox: CGRect(origin: CGPoint(x: self.boundingBox.origin.x+width+offset/2,
                                                                      y: self.boundingBox.origin.y+height+offset/2),
                                                      size: size))
    }

    private func subdivide(view: UIView) {
        self.isDivided = true
        let offset = CGFloat(5)
        let width = self.boundingBox.width/2
        let height = self.boundingBox.height/2
        let size = CGSize(width: width-offset, height: height-offset)

        self.northWest = PGQuadTree(boundingBox: CGRect(origin: CGPoint(x: self.boundingBox.origin.x+offset/2,
                                                                      y: self.boundingBox.origin.y+offset/2),
                                                      size: size))
        self.northEast = PGQuadTree(boundingBox: CGRect(origin: CGPoint(x: self.boundingBox.origin.x+width+offset/2,
                                                                      y: self.boundingBox.origin.y+offset/2),
                                                      size: size))
        self.southWest = PGQuadTree(boundingBox: CGRect(origin: CGPoint(x: self.boundingBox.origin.x+offset/2,
                                                                      y: self.boundingBox.origin.y+height+offset/2),
                                                      size: size))
        self.southEast = PGQuadTree(boundingBox: CGRect(origin: CGPoint(x: self.boundingBox.origin.x+width+offset/2,
                                                                      y: self.boundingBox.origin.y+height+offset/2),
                                                      size: size))
    }

    private func drawRectangle(rectangle: CGRect, view: UIView) {

        let boundingRectangle = UIBezierPath(roundedRect: rectangle, cornerRadius: 10)

        let layerRectangle = CAShapeLayer()
        layerRectangle.path = boundingRectangle.cgPath
        layerRectangle.strokeColor = self.color.cgColor
        layerRectangle.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(layerRectangle)
    }

    private func drawPoint(point: CGPoint, color: UIColor) -> CAShapeLayer {

        let layer = CAShapeLayer()

        layer.path = UIBezierPath(arcCenter: point,
                                  radius: 1,
                                  startAngle: 0,
                                  endAngle: 2*CGFloat.pi,
                                  clockwise: true).cgPath
        layer.fillColor = UIColor.red.cgColor
        layer.lineWidth = 1
        layer.strokeColor = color.cgColor
        layer.opacity = 0

        return layer
    }

    private func opacityAnimation(beginAfter: TimeInterval, duration: TimeInterval = 0.1) -> CAKeyframeAnimation {

        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")

        opacityAnimation.beginTime = beginAfter
        opacityAnimation.keyTimes = [0, 1]
        opacityAnimation.autoreverses = false
        opacityAnimation.values = [0, 1]
        opacityAnimation.duration = duration
        opacityAnimation.fillMode = CAMediaTimingFillMode.forwards
        opacityAnimation.isRemovedOnCompletion = false

        return opacityAnimation
    }
}
