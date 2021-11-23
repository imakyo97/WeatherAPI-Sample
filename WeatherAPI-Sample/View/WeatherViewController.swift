//
//  WeatherViewController.swift
//  WeatherAPI-Sample
//
//  Created by 今村京平 on 2021/11/21.
//

import UIKit
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController {

    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var weatherImageView: UIImageView!
    @IBOutlet private weak var weatherLabel: UILabel!
    @IBOutlet private weak var tempMaxLabel: UILabel!
    @IBOutlet private weak var tempMinLabel: UILabel!
    @IBOutlet private weak var tempLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    @IBOutlet private weak var pressureLabel: UILabel!
    @IBOutlet private weak var cityTextField: UITextField!
    @IBOutlet private weak var enterButton: UIButton!

    private let viewModel: WeatherViewModelType
    private let disposeBag = DisposeBag()

    init(viewModel: WeatherViewModelType = WeatherViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBinding()
    }

    private func setupBinding() {
        cityTextField.rx.text
            .bind(to: viewModel.inputs.cityTextRelay)
            .disposed(by: disposeBag)

        enterButton.rx.tap
            .subscribe(onNext: viewModel.inputs.didTapEnterButton)
            .disposed(by: disposeBag)

        viewModel.outputs.cityName
            .drive(cityLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.weatherIconName
            .map { UIImage(named: $0) }
            .drive(weatherImageView.rx.image)
            .disposed(by: disposeBag)

        viewModel.outputs.weather
            .drive(weatherLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.tempMax
            .drive(tempMaxLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.tempMin
            .drive(tempMinLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.temp
            .drive(tempLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.humidity
            .drive(humidityLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.pressure
            .drive(pressureLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.outputs.event
            .drive(onNext: { [weak self] event in
                guard let strongSelf = self else { return }
                switch event {
                case .presentAlert(reason: let reason):
                    strongSelf.presentAlert(alertTitle: reason)
                }
            })
            .disposed(by: disposeBag)
    }

    private func presentAlert(alertTitle: String) {
        let alert = UIAlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil)
        )
        present(alert, animated: true, completion: nil)
    }
}
