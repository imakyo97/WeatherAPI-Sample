//
//  WeatherViewModel.swift
//  WeatherAPI-Sample
//
//  Created by 今村京平 on 2021/11/22.
//

import Foundation
import RxSwift
import RxCocoa

protocol WeatherViewModelInput {
    var cityTextRelay: BehaviorRelay<String?> { get }
    func didTapEnterButton()
}

protocol WeatherViewModelOutput {
    var cityName: Driver<String> { get }
    var weatherIconName: Driver<String> { get }
    var weather: Driver<String> { get }
    var tempMax: Driver<String> { get }
    var tempMin: Driver<String> { get }
    var temp: Driver<String> { get }
    var humidity: Driver<String> { get }
    var pressure: Driver<String> { get }
    var event: Driver<WeatherViewModel.Event> { get }
}

protocol WeatherViewModelType {
    var inputs: WeatherViewModelInput { get }
    var outputs: WeatherViewModelOutput { get }
}

final class WeatherViewModel: WeatherViewModelInput, WeatherViewModelOutput {
    enum Event {
        case presentAlert(reason: String)
    }

    let cityTextRelay = BehaviorRelay<String?>(value: "")

    private let weatherAPI: WeatherAPIProtocol
    private let cityNameRelay = PublishRelay<String>()
    private let weatherIconNameRelay = PublishRelay<String>()
    private let weatherRelay = PublishRelay<String>()
    private let tempMaxRelay = PublishRelay<String>()
    private let tempMinRelay = PublishRelay<String>()
    private let tempRelay = PublishRelay<String>()
    private let humidityRelay = PublishRelay<String>()
    private let pressureRelay = PublishRelay<String>()
    private let eventRelay = PublishRelay<Event>()

    init(weatherAPI: WeatherAPIProtocol = WeatherAPI()) {
        self.weatherAPI = weatherAPI
    }

    var weatherIconName: Driver<String> {
        weatherIconNameRelay.asDriver(onErrorDriveWith: .empty())
    }

    var cityName: Driver<String> {
        cityNameRelay.asDriver(onErrorDriveWith: .empty())
    }

    var weather: Driver<String> {
        weatherRelay.asDriver(onErrorDriveWith: .empty())
    }

    var tempMax: Driver<String> {
        tempMaxRelay.asDriver(onErrorDriveWith: .empty())
    }

    var tempMin: Driver<String> {
        tempMinRelay.asDriver(onErrorDriveWith: .empty())
    }

    var temp: Driver<String> {
        tempRelay.asDriver(onErrorDriveWith: .empty())
    }

    var humidity: Driver<String> {
        humidityRelay.asDriver(onErrorDriveWith: .empty())
    }

    var pressure: Driver<String> {
        pressureRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func didTapEnterButton() {
        weatherAPI.fechWeather(city: cityTextRelay.value!) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let weatherData):
                strongSelf.weatherAccept(weatherData: weatherData)
            case .failure(let error):
                strongSelf.eventRelay.accept(
                    .presentAlert(reason: error.reason)
                )
            }
        }
    }

    private func weatherAccept(weatherData: WeatherData) {
        cityNameRelay.accept(weatherData.name)
        guard let lastWeather = weatherData.weather.last else { return }
        weatherIconNameRelay.accept(lastWeather.icon)
        weatherRelay.accept(lastWeather.description)
        tempMaxRelay.accept(String(weatherData.main.tempMax))
        tempMinRelay.accept(String(weatherData.main.tempMin))
        tempRelay.accept(String(weatherData.main.temp))
        humidityRelay.accept(String(weatherData.main.humidity))
        pressureRelay.accept(String(weatherData.main.pressure))
    }
}

extension WeatherViewModel: WeatherViewModelType {
    var inputs: WeatherViewModelInput {
        return self
    }

    var outputs: WeatherViewModelOutput {
        return self
    }
}
