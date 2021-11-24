//
//  WeatherAPI.swift
//  WeatherAPI-Sample
//
//  Created by 今村京平 on 2021/11/22.
//

import Foundation

enum WeatherAPIError: Error {
    case urlTypeConversionFailure
    case networkError
    case jsonDecodeFailure(String)

    var reason: String {
        switch self {
        case .urlTypeConversionFailure:
            return "URL型の変換に失敗しました"
        case .networkError:
            return "ネットワークエラー"
        case .jsonDecodeFailure(let reason):
            return reason

        }
    }
}

protocol WeatherAPIProtocol {
    func fechWeather(city: String) async throws -> WeatherData
}

final class WeatherAPI: WeatherAPIProtocol {
    func fechWeather(city: String) async throws -> WeatherData {
        let urlString = createURLString(city: city)
        guard let url = URL(string: urlString) else {
            throw WeatherAPIError.urlTypeConversionFailure
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw WeatherAPIError.networkError }
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let weatherData = try decoder.decode(WeatherData.self, from: data)
            return weatherData
        } catch let error {
            throw WeatherAPIError.jsonDecodeFailure(error.localizedDescription)
        }
    }

    private func createURLString(city: String) -> String {
        let appId = "9f3ab1e7ced559d013692e82ff4f65ea"
        let unit = "metric"
        let lang = "ja"
        return "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(appId)&units=\(unit)&lang=\(lang)"
    }
}
