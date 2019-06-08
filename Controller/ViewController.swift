//
//  ViewController.swift
//  WeatherApp
//
//  Created by Vitaliy on 6/10/18.
//  Copyright © 2018 Vitaliy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var tempLbl: UILabel!
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var loadingIndecator: UIActivityIndicatorView!
    @IBOutlet weak var changeCityBtn: UIButton!
    
    var currentCity = City()

    let APP_ID = "1e0fb1aef35a6c8c47c305ca1141693c"
    var WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkNetwork()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func checkNetwork() {
        if Reachability.isConnectedToNetwork(){
            print("Connection succesful!")
        } else {
            print("Internet Connection not Available!")
            let internetConnectionAlert = UIAlertView(title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK")
            internetConnectionAlert.show()
        }
    }
    
    func getData(url: String) {
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                let weatherJson: JSON = JSON(response.result.value!)
                print(weatherJson)
                self.jsonParsing(json: weatherJson)
                self.updateUI()
            } else {
                print("\(String(describing: response.result.error))")
            }
        }
    }
    
    func jsonParsing(json: JSON) {
        if let tempResult = json["main"]["temp"].double {
            currentCity.temp = Int(tempResult - 273.15)
            currentCity.name = json["name"].stringValue
        }
    }
    
    func updateUI() {
        loadingIndecator.isHidden = true
        changeCityBtn.isHidden = false
        cityLbl.isHidden = false
        tempLbl.isHidden = false
        cityLbl.text = currentCity.name
        tempLbl.text = "\(String(describing: currentCity.temp)) ℃"
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            //I catch errors if I tried to send coordinats via parametrs because
            //of old alamofire version so I made it in a such way:
            WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(APP_ID)"
            getData(url: WEATHER_URL)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLbl.text = "Location unavaible"
    }
}

