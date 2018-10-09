//
//  SecondViewController.swift
//  Weatherapp
//
//  Created by Rami Niemelä on 01/10/2018.
//  Copyright © 2018 Rami Niemelä. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var weatherData = WeatherForecastObject()
    var weatherIconArray : [UIImage] = []
    var weatherIconArraySet : Bool = false
    
    var previousSearch : String?
    
    var alert : UIAlertController? = nil
    
    @IBOutlet weak var forecastTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.forecastTableView.dataSource = self
        self.forecastTableView.delegate = self
        
        alert = UIAlertController(title: "Not a valid city name!", message: nil, preferredStyle: .alert)
        alert?.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (FetchValue.fv.value == "" || previousSearch != "" && previousSearch != FetchValue.fv.value) {
            previousSearch = FetchValue.fv.value
            weatherIconArraySet = false
            weatherIconArray = []
        }
        
        if (FetchValue.fv.value != "" && FetchValue.fv.value != "Use GPS") {
            fetchURLString(url: "https://api.openweathermap.org/data/2.5/forecast?q=\(FetchValue.fv.value!)&units=metric&APPID=ce256b0381ade0625a3342e8094801f8")
        } else if (FetchValue.fv.value == "Use GPS") {
            // TODO: USE GPS TO FETCH WEATHER DATA
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
                print("Error fetching for \(FetchValue.fv.value)!")
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
            self.weatherIconArray.append(UIImage(data: data!)!)
            
            if (self.weatherIconArray.count == self.weatherData.list.count) {
                self.weatherIconArraySet = true
                self.forecastTableView.reloadData()
                
                for index in 0...self.weatherData.list.count {
                    self.fetchURLImage(url:
                        "https://openweathermap.org/img/w/\(self.weatherData.list[index].weather[0].icon).png")
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastTableCell") as! ForecastTableCell
        let weather = self.weatherData.list[indexPath.row].weather[0].main + "  " + String(self.weatherData.list[indexPath.row].main.temp) + " C"
        cell.weatherTypeField.text = weather
        cell.weatherDateField.text = self.weatherData.list[indexPath.row].dt_txt!
        
        self.fetchURLImage(url:
            "https://openweathermap.org/img/w/\(self.weatherData.list[indexPath.row].weather[0].icon).png")
        
        DispatchQueue.main.async(execute: {() in
            if (self.weatherIconArraySet) {
                cell.weatherIcon.image = self.weatherIconArray[indexPath.row]
            }
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
