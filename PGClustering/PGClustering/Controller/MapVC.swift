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
        var annotations = [ClusteringAnnotation]()
        for _ in 1...100 {
            let annotation = self.getAnnotation()
            annotations.append((annotation as? ClusteringAnnotation)!)
        }
        mapView.addAnnotations(annotations)

    }

    private func getAnnotation() -> MKAnnotation {

        let longitude = Double.random(in: -latitudeLongitudeDelta/2...latitudeLongitudeDelta/2)
        let latitude = Double.random(in: -latitudeLongitudeDelta/2...latitudeLongitudeDelta/2)

        return ClusteringAnnotation(coordinate: CLLocationCoordinate2D(latitude: self.latitude+latitude, longitude: self.longitude+longitude),
                                    title: "",
                                    subtitle: "")

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

}

class ClusteringAnnotation: NSObject, MKAnnotation {

    public var coordinate: CLLocationCoordinate2D
    public var title: String?
    public var subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
