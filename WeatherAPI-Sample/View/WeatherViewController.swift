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

    @IBOutlet private weak var weatherLabel: UILabel!
    @IBOutlet private weak var weatherImageView: UIImageView!

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
        viewModel.inputs.viewDidLoad()
    }

    private func setupBinding() {
        viewModel.outputs.WeatherIconName
            .map { UIImage(named: $0) }
            .drive(weatherImageView.rx.image)
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
