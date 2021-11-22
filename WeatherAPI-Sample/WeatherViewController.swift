//
//  WeatherViewController.swift
//  WeatherAPI-Sample
//
//  Created by 今村京平 on 2021/11/21.
//

import UIKit

class WeatherViewController: UIViewController {

    @IBOutlet private weak var weatherLabel: UILabel!
    @IBOutlet private weak var weatherImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let urlString = createURLString(city: "Nobeoka")
        fetchWeather(urlString: urlString)
    }

    private func createURLString(city: String) -> String {
        let unit = "metric"
        let appId = "9f3ab1e7ced559d013692e82ff4f65ea"
        let lang = "ja"
        return "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(appId)&units=\(unit)&lang=\(lang)"
    }

    private func fetchWeather(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request)
        { (data, response, error) in
            guard let data = data else { return }
            do {
                let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                print(weatherData)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.weatherLabel.text = ""
                    guard let weather = weatherData.weather.last else { return }
                    strongSelf.weatherImageView.image = UIImage(named: weather.icon)
                }
            } catch let e {
                print(e)
            }
        }
        task.resume()
    }
}
