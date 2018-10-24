//
//  SecondViewController.swift
//  Weatherapp
//
//  Created by Rami Niemelä on 01/10/2018.
//  Copyright © 2018 Rami Niemelä. All rights reserved.
//

import UIKit
import CoreLocation

class ForecastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    var weatherData = WeatherForecastObject()
    
    var locationManager : CLLocationManager!
    let uD = UserDefaults.standard
    
    var previousSearch : String! = ""
    
    var alert : UIAlertController? = nil
    
    @IBOutlet weak var forecastTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.forecastTableView.dataSource = self
        self.forecastTableView.delegate = self
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if (uD.value(forKey: "chosenLocation") != nil) {
            FetchValue.fv.value = uD.value(forKey: "chosenLocation") as? String
        }
        
        alert = UIAlertController(title: "Not a valid city name!", message: nil, preferredStyle: .alert)
        alert?.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Forecast " + " Prev: " + previousSearch + " FetchValue: " + FetchValue.fv.value!)
        if (previousSearch != FetchValue.fv.value) {
            previousSearch = FetchValue.fv.value
            
            if (FetchValue.fv.value != "" && FetchValue.fv.value != "Use GPS") {
                fetchURLString(url: "https://api.openweathermap.org/data/2.5/forecast?q=\(FetchValue.fv.value!.replacingOccurrences(of: " ", with: "%"))&units=metric&APPID=ce256b0381ade0625a3342e8094801f8")
            } else if ((FetchValue.fv.value).contains("GPS")) {
                if (CLLocationManager.locationServicesEnabled()) {
                    locationManager.startUpdatingLocation()
                    
                    let loc = locationManager.location
                    
                    let lat = loc!.coordinate.latitude
                    let lon = loc!.coordinate.longitude
                    
                    locationManager.stopUpdatingLocation()
                    
                    fetchURLString(url: "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&units=metric&APPID=ce256b0381ade0625a3342e8094801f8")
                }
            }
        }
    }
    
    func fetchURLString(url : String) {
        let config = URLSessionConfiguration.default
        
        let session = URLSession(configuration: config)
        
        let url : URL = URL(string: url)!

        // Handles errors within datatask
        let task = session.dataTask(with: url) { (data, res, err) in
            if let data = data,  let res = res as? HTTPURLResponse,
                res.statusCode == 200 {
                DispatchQueue.main.async {
                    self.doneFetching(data: data, response: res, error: err)
                }
            } else {
                // Displays an alert if the location searched for isn't a valid name
                self.present(self.self.alert!, animated: true)
            }
        }
        
        task.resume();
    }
    
    func doneFetching(data: Data?, response: URLResponse?, error: Error?) {
        guard let forecast = try? JSONDecoder().decode(WeatherForecastObject.self, from: data!) else {
            print("Error: Couldn't decode data into WeatherObject")
            return
        }
        
        // Execute stuff in UI thread
        DispatchQueue.main.async(execute: {() in
            self.weatherData = forecast
            self.forecastTableView.reloadData()
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastTableCell") as! ForecastTableCell
        let temperature = String(self.weatherData.list[indexPath.row].main.temp)
        let weather = self.weatherData.list[indexPath.row].weather[0].main + "  " + temperature.dropLast() + " C"   // String.dropLast() removes the last number from the temperature
        cell.weatherTypeField.text = weather
        
        // Replaces '-'-marks with '/' and removes the last two numbers (seconds)
        let dt = String(self.weatherData.list[indexPath.row].dt_txt!.replacingOccurrences(of: "-", with: "/").split(separator: ":")[0] + ":" + self.weatherData.list[indexPath.row].dt_txt!.split(separator: ":")[1])
        // It's beautiful, isn't it? ^
        cell.weatherDateField.text = dt
        
        let url = URL(string: "https://openweathermap.org/img/w/\(self.weatherData.list[indexPath.row].weather[0].icon).png")
        
        DispatchQueue.main.async(execute: {() in
            let data = NSData(contentsOf: url!)
            cell.weatherIcon.image = UIImage(data: data! as Data)
        })
        
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weatherData.list.count
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
