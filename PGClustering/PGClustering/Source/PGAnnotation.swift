//
//  PGAnnotation.swift
//  PGClustering
//
//  Created by Pablo on 06/03/2019.
//  Copyright © 2019 Pablo Garcia. All rights reserved.
//

import CoreLocation
import MapKit

class PGAnnotation: NSObject, MKAnnotation {

    public var coordinate: CLLocationCoordinate2D
    public var title: String?
    public var subtitle: String?

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
