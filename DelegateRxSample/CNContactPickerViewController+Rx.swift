//
//  CNContactPickerViewController+Rx.swift
//  DelegateRxSample
//
//  Created by Siarhei Dukhovich on 7/25/19.
//  Copyright © 2019 Siarhei Dukhovich. All rights reserved.
//

import RxSwift
import RxCocoa
import ContactsUI

extension CNContactPickerViewController: HasDelegate {
  public typealias Delegate = CNContactPickerDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxCNContactPickerDelegateProxy
  : DelegateProxy<CNContactPickerViewController, CNContactPickerDelegate>
  , DelegateProxyType
, CNContactPickerDelegate {

  /// Typed parent object.
  public weak private(set) var pickerController: CNContactPickerViewController?

  /// - parameter navigationController: Parent object for delegate proxy.
  public init(pickerController: ParentObject) {
    self.pickerController = pickerController
    super.init(parentObject: pickerController, delegateProxy: RxCNContactPickerDelegateProxy.self)
  }

  // Register known implementations
  public static func registerKnownImplementations() {
    self.register { RxCNContactPickerDelegateProxy(pickerController: $0) }
  }
}

extension Reactive where Base: CNContactPickerViewController {

  /// Reactive wrapper for `delegate`.
  ///
  /// For more information take a look at `DelegateProxyType` protocol documentation.
  public var delegate: DelegateProxy<CNContactPickerViewController, CNContactPickerDelegate> {
    return RxCNContactPickerDelegateProxy.proxy(for: base)
  }

  /// Reactive wrapper for delegate method `contactPicker(_:didSelect:)`.
  var didSelectContact: ControlEvent<CNContact> {
    let sel = #selector((CNContactPickerDelegate.contactPicker(_:didSelect:)! as (CNContactPickerDelegate) ->  (CNContactPickerViewController, CNContact) -> Void))
    let source: Observable<CNContact> = delegate.methodInvoked(sel)
      .map { arg in
        let contact = arg[1] as! CNContact
        return contact
    }
    return ControlEvent(events: source)
  }

  /// Reactive wrapper for delegate method `contactPicker(_:didSelect:)`.
  var didSelectContactProperty: ControlEvent<CNContactProperty> {
    let sel = #selector((CNContactPickerDelegate.contactPicker(_:didSelect:)! as (CNContactPickerDelegate) ->  (CNContactPickerViewController, CNContactProperty) -> Void))
    let source: Observable<CNContactProperty> = delegate.methodInvoked(sel)
      .map { arg in
        let contact = arg[1] as! CNContactProperty
        return contact
    }
    return ControlEvent(events: source)
  }
}

extension Reactive where Base: CNContactPickerViewController {
  func setDelegate(_ delegate: CNContactPickerDelegate)
    -> Disposable {
      return RxCNContactPickerDelegateProxy
        .installForwardDelegate(delegate,
                                retainDelegate: false,
                                onProxyForObject: self.base)
  }
}
