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
    func viewDidLoad()
}

protocol WeatherViewModelOutput {
    var WeatherIconName: Driver<String> { get }
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

    private let weatherAPI: WeatherAPIProtocol
    private let weatherIconNameRelay = PublishRelay<String>()
    private let eventRelay = PublishRelay<Event>()

    init(weatherAPI: WeatherAPIProtocol = WeatherAPI()) {
        self.weatherAPI = weatherAPI
    }

    var WeatherIconName: Driver<String> {
        weatherIconNameRelay.asDriver(onErrorDriveWith: .empty())
    }

    var event: Driver<Event> {
        eventRelay.asDriver(onErrorDriveWith: .empty())
    }

    func viewDidLoad() {
        weatherAPI.fechWeather(city: "Fukuoka") { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let weatherData):
                guard let lastWeatherIcon = weatherData.weather.last?.icon else { return }
                strongSelf.weatherIconNameRelay.accept(lastWeatherIcon)
            case .failure(let error):
                strongSelf.eventRelay.accept(
                    .presentAlert(reason: error.reason)
                )
            }
        }
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
