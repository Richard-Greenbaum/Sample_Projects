//
//  ViewController.swift
//  OfficeHours
//
//  Created by Richard Greenbaum on 9/16/17.
//  Copyright © 2017 Richard Greenbaum. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation



class ViewController: UIViewController {

    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var map1: MKMapView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var day: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        time.text = "12:00 PM"
        
        let centerLocation = CLLocationCoordinate2DMake(avLat, avLong)
        
        let mapSpan = MKCoordinateSpanMake(0.007, 0.007)
        
        let mapRegion = MKCoordinateRegionMake(centerLocation, mapSpan)
        
        map1.setRegion(mapRegion, animated: true)
        
        map1.showsUserLocation = true
        displayPins()
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let x:Float = self.timeSlider.value
        let am_pm: String
        let min1: String
        if x<12 {
            am_pm = "AM"
        } else {
            am_pm = "PM"
        }
        var hour:Int = (Int(x)%12)
        if hour == 0 {
            hour = 12
        }
        let min:Int = (Int((x-floor(x))*60.0))
        if min<10 {
            min1 = "0" + String(min)
        } else {
            min1 = String(min)
        }
        time.text = String(hour) + ":" + min1 + " " + am_pm
        displayPins()

    
        
    }
    
    
    @IBAction func dayChange(_ sender: Any) {
        displayPins()
    }
    
    func addPin(lat: Double, long: Double, title1: String) {
        let annotation = MKPointAnnotation()
        let centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        annotation.coordinate = centerCoordinate
        annotation.title = title1
        map1.addAnnotation(annotation)
    }
    
    func displayPins() {
        map1.removeAnnotations(map1.annotations)
        for x in discrt[day.selectedSegmentIndex] as! [Array<NSNumber>] {
                if timeSlider.value >= Float(x[0]) && timeSlider.value <= Float(x[1]) {
                    let y = Int(x[2])
                    addPin(lat: coordinates[y][0], long: coordinates[y][1], title1: location[y])
            }
            
        }
    }
    

}

