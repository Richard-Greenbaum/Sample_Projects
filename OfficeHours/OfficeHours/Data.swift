//
//  File.swift
//  OfficeHours
//
//  Created by Richard Greenbaum on 9/16/17.
//  Copyright © 2017 Richard Greenbaum. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

let discrt = [[[12, 13, 1], [13, 18, 0]], [[18.5, 21, 1]], [[11.75, 13.25, 0], [13, 14, 1], [15, 16, 1], [15.5, 16.5, 1]], [[10, 12, 1], [12, 13, 0], [14.5, 15.5, 2], [15.5, 17.5, 0], [19, 20, 1]], [[12, 16, 1]], [[10.25, 11, 0], [10.5, 11.5, 1], [14.5, 15.5, 2], [14.5, 18, 1]], [[10.5, 11.5, 0], [11, 14, 1], [16, 19, 1]]]


let location = ["Uris Hall", "Rhodes Hall", "Gates"]

let urisLat = 42.447255
let urisLong = -76.482250
let rhodesLat = 42.4434
let rhodesLong = -76.4817
let gatesLat = 42.443679
let gatesLong = -76.481313

let avLat = (urisLat+rhodesLat+gatesLat)/3
let avLong = (urisLong+rhodesLong+gatesLong)/3

let coordinates = [[urisLat, urisLong], [rhodesLat, rhodesLong], [gatesLat, gatesLong]]


