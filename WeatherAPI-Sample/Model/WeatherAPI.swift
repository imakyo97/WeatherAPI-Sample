//
//  WeatherAPI.swift
//  WeatherAPI-Sample
//
//  Created by 今村京平 on 2021/11/22.
//

import Foundation

enum WeatherAPIError: Error {
    case urlTypeConversionFailure
    case dataNotFound
    case jsonDecodeFailure(String)

    var reason: String {
        switch self {
        case .urlTypeConversionFailure:
            return "URL型の変換に失敗しました"
        case .dataNotFound:
            return "データが見つかりません"
        case .jsonDecodeFailure(let reason):
            return reason
        }
    }
}

protocol WeatherAPIProtocol {
    func fechWeather(city: String, completion: @escaping CompletionHandler<WeatherData>)
}

typealias CompletionHandler<T> = (Result<T,WeatherAPIError>) -> Void

final class WeatherAPI: WeatherAPIProtocol {
    func fechWeather(city: String, completion: @escaping CompletionHandler<WeatherData>) {
        let urlString = createURLString(city: city)
        guard let url = URL(string: urlString) else {
            return completion(.failure(WeatherAPIError.urlTypeConversionFailure))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return completion(.failure(WeatherAPIError.dataNotFound))
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let weatherData = try decoder.decode(WeatherData.self, from: data)
                print(weatherData)
                completion(.success(weatherData))
            } catch let error {
                completion(
                    .failure(WeatherAPIError.jsonDecodeFailure(error.localizedDescription))
                )
            }
        }
        task.resume()
    }

    private func createURLString(city: String) -> String {
        let appId = "9f3ab1e7ced559d013692e82ff4f65ea"
        let unit = "metric"
        let lang = "ja"
        return "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(appId)&units=\(unit)&lang=\(lang)"
    }
}
