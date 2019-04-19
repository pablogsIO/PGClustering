//
//  MapVC.swift
//  PGClustering
//
//  Created by Pablo on 06/03/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    private let latitudeLongitudeDelta = 0.0275
    private let longitude = -0.076132
    private let latitude = 51.508530

    private let clusterManager = PGClusteringManager(annotations: [PGAnnotation]())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        
    }

    private func configureMap() {
        mapView.delegate = self
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                             span: MKCoordinateSpan(latitudeDelta: latitudeLongitudeDelta,
                                                                    longitudeDelta: latitudeLongitudeDelta)),
                          animated: true)
        var annotations = [MKAnnotation]()
        for _ in 1...1000 {
            let annotation = self.getAnnotation()
            annotations.append(annotation)
        }
        clusterManager.delegate = self
        clusterManager.addAnnotations(annotations: annotations)

    }

    private func getAnnotation() -> MKAnnotation {

        let longitude = Double.random(in: -latitudeLongitudeDelta/2...latitudeLongitudeDelta/2)
        let latitude = Double.random(in: -latitudeLongitudeDelta/2...latitudeLongitudeDelta/2)

        return PGAnnotation(coordinate: CLLocationCoordinate2D(latitude: self.latitude+latitude, longitude: self.longitude+longitude),
                                    title: "",
                                    subtitle: "")

    }

}

extension MapVC: PGClusteringManagerDelegate {
    
    func displayAnnotations(annotations: [MKAnnotation]) {
        print("pablogsio: Total annotations: \(annotations.count)")
        DispatchQueue.main.async {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotations(annotations)
        }
    }
}
extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "annotationView"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        if #available(iOS 11.0, *) {
            if view == nil {
                view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
            view?.displayPriority = .required
        } else {
            if view == nil {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            }
        }
        view?.annotation = annotation
        view?.canShowCallout = true
        return view
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        let boundsWidth = self.mapView.bounds.width
        let visibleWidth = CGFloat(self.mapView.visibleMapRect.width)

        clusterManager.clusterAnnotationWithinMapRectangle(visibleMapRect: mapView.visibleMapRect, zoomScale: Double(boundsWidth/visibleWidth))
    }

    func zoomScaleToZoomLevel(scale: MKZoomScale) -> Int {
        
        let totalTilesAtMaxZoom = MKMapSize.world.width / 256.0
        
        let zoomLevelAtMaxZoom = Int(log2(totalTilesAtMaxZoom))
        let floorLog2ScaleFloat = floor(log2f(Float(scale))) + 0.5
        guard !floorLog2ScaleFloat.isInfinite else {
            return floorLog2ScaleFloat.sign.rawValue < 0 ? 0 : 19
        }
        
        let sum = zoomLevelAtMaxZoom + Int(floorLog2ScaleFloat)
        let zoomLevel = max(0, sum)
        return zoomLevel
    }
}
