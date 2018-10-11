//
//  FirstViewController.swift
//  Weatherapp
//
//  Created by Rami Niemelä on 01/10/2018.
//  Copyright © 2018 Rami Niemelä. All rights reserved.
//

import UIKit
import CoreLocation

class CurrenWeatherViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let uD = UserDefaults.standard
    
    var alert : UIAlertController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        
        if (uD.value(forKey: "chosenLocation") != nil) {
            FetchValue.fv.value = uD.value(forKey: "chosenLocation") as! String
        }
        
        alert = UIAlertController(title: "Not a valid location!", message: nil, preferredStyle: .alert)
        alert?.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FetchValue.fv.value != "" && FetchValue.fv.value != "Use GPS") {
            fetchURLString(url: "https://api.openweathermap.org/data/2.5/weather?q=\(FetchValue.fv.value!)&units=metric&APPID=ce256b0381ade0625a3342e8094801f8")
        } else if (FetchValue.fv.value == "Use GPS") {
            if (CLLocationManager.locationServicesEnabled()) {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
            }
            
            let lat = Int((locationManager.location?.coordinate.latitude)!)
            let lon = Int((locationManager.location?.coordinate.longitude)!)
            
            CLGeocoder().reverseGeocodeLocation(locationManager.location!, completionHandler: { (placemarks, error) in
                if error == nil {
                    self.cityLabel.text = placemarks?[0].locality
                } else {
                    self.present(self.self.alert!, animated: true)
                }
            })
            
            fetchURLString(url: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric&APPID=ce256b0381ade0625a3342e8094801f8")
        }
    }
    
    func fetchURLString(url : String) {
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let url : URL = URL(string: url)!
        
        // Handles errors within datatask
        let task = session.dataTask(with: url) { (data, res, err) in
            if let data = data, let res = res as? HTTPURLResponse,
                res.statusCode == 200 {
                DispatchQueue.main.async {
                    self.doneFetching(data: data, response: res, error: err)
                }
            } else {
                // Displays an alert if the location searched for isn't a valid name
                self.present(self.self.alert!, animated: true)
                print("Error fetching for \(FetchValue.fv.value)!")
            }
        }
        
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        
        guard let weatherObj = try? JSONDecoder().decode(WeatherObject.self, from: data!) else {
            print("Error: Couldn't decode data into WeatherObject")
            return
        }
        
        // Execute stuff in UI thread
        DispatchQueue.main.async(execute: {() in
            self.cityLabel.text = FetchValue.fv.value
            self.tempLabel.text = String(weatherObj.main.temp)
            self.tempLabel.text = self.tempLabel.text! + " C"
            self.fetchURLImage(url:
                "https://openweathermap.org/img/w/\(weatherObj.weather[0].icon).png")
        })
    }
    
    func fetchURLImage(url : String) {
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let url : URL? = URL(string: url)
        
        let task = session.dataTask(with: url!, completionHandler: doneFetchingImage);
        
        // Starts the task, spawns a new thread and calls the callback function
        task.resume();
    }
    
    func doneFetchingImage(data: Data?, response: URLResponse?, error: Error?) {
        guard let image = data else {
            // TODO: Show error dialog
            print("Error fetching request!")
            return
        }
        
        // Execute stuff in UI thread
        DispatchQueue.main.async(execute: {() in
            self.weatherImage.image = UIImage(data: image)
            self.weatherImage.contentMode = .scaleAspectFit
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
