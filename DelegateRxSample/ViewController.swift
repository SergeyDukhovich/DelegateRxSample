//
//  ViewController.swift
//  DelegateRxSample
//
//  Created by Siarhei Dukhovich on 7/24/19.
//  Copyright © 2019 Siarhei Dukhovich. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxSwiftExt
import ContactsUI

class Picker: CNContactPickerViewController {
  private let disposeBag = DisposeBag()
  deinit {
    print("CNContactPickerViewController deinit")
  }
}

class ViewController: UIViewController {

  @IBOutlet var tableView: UITableView!

  private let disposeBag = DisposeBag()
  private let mostVisitedCities = Observable<[String]>.just([
    "Bangkok",
    "London",
    "Paris",
    "Dubai",
    "Singapore",
    "New York",
    "Kuala Lumpur",
    "Tokyo",
    "Istanbul",
    "Seoul",
    "Antalya",
    "Phuket",
    "Mecca",
    "Hong Kong",
    "Milan",
    "Palma de Mallorca",
    "Barcelona",
    "Pattaya",
    "Osaka",
    "Bali"
    ])

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    mostVisitedCities
      .bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { index, model, cell in
        cell.textLabel?.text = model
      }
      .disposed(by: disposeBag)

    let controllerObservable = tableView.rx.itemSelected
      .map { [weak self] indexPath -> CNContactPickerViewController? in
        return self?.picker()
      }
      .unwrap()
      .share()

    controllerObservable
      .subscribe(onNext: { [weak self] controller in
        guard let self = self else { return }
        self.present(controller, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)

    controllerObservable
      .flatMap { controller in
        return controller.rx.didSelectContact
      }
      .subscribe(onNext: { contact in
        print("call from rx")
      })
      .disposed(by: disposeBag)

    tableView.rx.setDelegate(self)
        .disposed(by: disposeBag)

    tableView.rx.itemSelected
        .subscribe(onNext: { indexPath in
            print("call from rx.itemSelected")
        })
        .disposed(by: disposeBag)

    navigationController?.rx
        .setDelegate(self)
        .disposed(by: disposeBag)

    navigationController?.rx.willShow
        .subscribe(onNext: { (controller, animated) in
            print("call from rx.willShow")
        })
        .disposed(by: disposeBag)
  }

  func picker() -> CNContactPickerViewController {
    let contactPicker = Picker()
    contactPicker.view.backgroundColor = UIColor.white
    contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]

    contactPicker.rx
      .setDelegate(self)
      .disposed(by: self.disposeBag)

    return contactPicker
  }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("call from extension")
    }
}

extension ViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("call from extension")
    }
}

extension ViewController: CNContactPickerDelegate {
  func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
    print("call from extension")
  }
}

extension Reactive where Base: UINavigationController {
    func setDelegate(_ delegate: UINavigationControllerDelegate)
        -> Disposable {
            return RxNavigationControllerDelegateProxy
                .installForwardDelegate(delegate,
                                        retainDelegate: false,
                                        onProxyForObject: self.base)
    }
}
