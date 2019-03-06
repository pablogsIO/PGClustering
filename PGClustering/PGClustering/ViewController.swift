//
//  ViewController.swift
//  PGClustering
//
//  Created by Pablo on 19/01/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var tree: QuadTree?
    var quadTreeView: UIView?
    var clusteringView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.quadTreeView = UIView(frame: self.view.frame)
        self.clusteringView = UIView(frame: self.view.frame)
        self.view.addSubview(quadTreeView!)
        self.view.addSubview(clusteringView!)
    }

    private func insertDataQuadTree() {
        let rectangle = CGRect(x: self.view.safeAreaInsets.left,
                               y: self.view.safeAreaInsets.top,
                               width: self.view.frame.width-self.view.safeAreaInsets.right,
                               height: self.view.safeAreaLayoutGuide.layoutFrame.size.height)
        tree = QuadTree(boundingBox: rectangle)

        var index = 0

        while index <= 100 {

            let xCoordinate = CGFloat.random(in: rectangle.origin.x ... rectangle.width)
            let yCoordinate = CGFloat.random(in: rectangle.origin.y ... rectangle.height)
            //self.tree?.insertPoint(newPoint: CGPoint(x: xCoordinate, y: yCoordinate))
            self.tree?.insertPoint(newPoint: CGPoint(x: xCoordinate, y: yCoordinate), view: self.quadTreeView!)
            index += 1
        }
    }
    private func clustering() {
        let rectangle = CGRect(x: self.view.safeAreaInsets.left,
                               y: self.view.safeAreaInsets.top,
                               width: self.view.frame.width-self.view.safeAreaInsets.right,
                               height: self.view.safeAreaLayoutGuide.layoutFrame.size.height)

        let clusterManager = PGClusteringManager(quadtree: tree!)
        let clusters = clusterManager.clusterAnnotationsWithinRectangle(rectangle: rectangle)
        //print("pablogsio: Total Clusters: \(clusters.count)")
        self.drawClusters(clusters: clusters)
    }
    @IBAction func tapGesture(_ sender: Any) {
        //self.quadTreeConfiguration()
        var index = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            switch index {
            case 0:
                self.insertDataQuadTree()
            case 1:
                self.clustering()
            case 3:
                self.changeOpacityViews()
                timer.invalidate()
            default:
                print("The end")
            }
            index+=1
        }

        timer.fire()

    }

    private func changeOpacityViews() {

        let animation = CAKeyframeAnimation(keyPath: "opacity")
        animation.keyTimes = [0, 0.25, 0.5, 0.75, 1]
        animation.values = [1, 0.5, 0, 0.5, 1]
        animation.duration = 2
        animation.repeatCount = .infinity

        self.quadTreeView?.layer.add(animation, forKey: "opacity")

    }
    private func quadTreeConfiguration() {

        self.view.backgroundColor = UIColor.black

        let rectangle = CGRect(x: self.view.safeAreaInsets.left,
                               y: self.view.safeAreaInsets.top,
                               width: self.view.frame.width-self.view.safeAreaInsets.right,
                               height: self.view.safeAreaLayoutGuide.layoutFrame.size.height)

        tree = QuadTree(boundingBox: rectangle)

        var index = 1

        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {timer in
            guard index <= 1000 else {
                timer.invalidate()
                return
            }

            let xCoordinate = CGFloat.random(in: rectangle.origin.x ... rectangle.width)
            let yCoordinate = CGFloat.random(in: rectangle.origin.y ... rectangle.height)
            self.tree?.insertPoint(newPoint: CGPoint(x: xCoordinate, y: yCoordinate), view: self.view)
            index += 1
        }

        timer.fire()

    }
}

extension ViewController {
    public func drawClusters(clusters: [ClusterPoint]) {
        DispatchQueue.main.async {
            for clusterPoint in clusters {
                //print("pablogsio: \(clusterPoint.points)")
                let layer = self.drawPoint(point: clusterPoint.origin)
                self.clusteringView!.layer.addSublayer(layer)
                self.clusteringView!.layer.addSublayer(self.drawRectangle(rectangle: clusterPoint.rectangle))
                for index in 0...clusterPoint.points {
                    let layerCluster = self.drawCircle(center: clusterPoint.origin, radius: 5*index)
                    self.clusteringView?.layer.addSublayer(layerCluster)
                }
            }
        }

    }

    private func drawRectangle(rectangle: CGRect) -> CAShapeLayer {
        let layer = CAShapeLayer()

        layer.path = UIBezierPath(rect: rectangle).cgPath
        layer.strokeColor = UIColor.random.cgColor
        layer.fillColor = UIColor.clear.cgColor

        return layer
    }
    private func drawCircle(center: CGPoint, radius: Int) -> CAShapeLayer {
        let layer = CAShapeLayer()

        layer.path = UIBezierPath(arcCenter: center, radius: CGFloat(radius),
                                  startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true).cgPath

        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1
        layer.strokeColor = UIColor.random.cgColor

        return layer
    }
    private func drawPoint(point: CGPoint) -> CAShapeLayer {

        let layer = CAShapeLayer()

        layer.path = UIBezierPath(arcCenter: point,
                                  radius: 1,
                                  startAngle: 0,
                                  endAngle: 2*CGFloat.pi,
                                  clockwise: true).cgPath
        layer.fillColor = UIColor.red.cgColor
        layer.lineWidth = 1
        layer.strokeColor = UIColor.red.cgColor

        return layer
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1.0)
    }
}
