//
//  CustomUIKitTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/30.
//

import Foundation
import UIKit
import Combine

class CustomUIKitTestVC: UIViewController {
    
    @IBOutlet weak var myButton: UIButton!
    
    @IBOutlet weak var mySwichControl: UISwitch!
    
    
    var cancellables = Set<AnyCancellable>()
    
    
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //! 点击事件
        myButton.publisher(for: .touchUpInside).sink { button in
            print("啊～ 我被点击了")
        }.store(in: &cancellables)
        
        //
        mySwichControl.isOnPublisher.assign(to: \.isEnabled, on: submitButton).store(in: &cancellables)

        
    }
    
    @IBAction func exmapleClick(_ sender: Any) {
        print("说了我可以被点击了")
    }
}





//!MARK: 自定义
final class UIControlSubscription<SubscriberType: Subscriber, Control: UIControl>: Subscription where SubscriberType.Input == Control {
    private var subscriber: SubscriberType?
    private let control: Control

    init(subscriber: SubscriberType, control: Control, event: UIControl.Event) {
        self.subscriber = subscriber
        self.control = control
        control.addTarget(self, action: #selector(eventHandler), for: event)
    }

    func request(_ demand: Subscribers.Demand) {
        // We do nothing here as we only want to send events when they occur.
        // See, for more info: https://developer.apple.com/documentation/combine/subscribers/demand
    }

    func cancel() {
        subscriber = nil
    }

    @objc private func eventHandler() {
        _ = subscriber?.receive(control)
    }

    deinit {
        print("UIControlTarget deinit")
    }
}

/// A custom `Publisher` to work with our custom `UIControlSubscription`.
struct UIControlPublisher<Control: UIControl>: Publisher {

    typealias Output = Control
    typealias Failure = Never

    let control: Control
    let controlEvents: UIControl.Event

    init(control: Control, events: UIControl.Event) {
        self.control = control
        self.controlEvents = events
    }

    /// This function is called to attach the specified `Subscriber` to this `Publisher` by `subscribe(_:)`
    ///
    /// - SeeAlso: `subscribe(_:)`
    /// - Parameters:
    ///     - subscriber: The subscriber to attach to this `Publisher`.
    ///                   once attached it can begin to receive values.
    func receive<S>(subscriber: S) where S : Subscriber, S.Failure == UIControlPublisher.Failure, S.Input == UIControlPublisher.Output {
        subscriber.receive(subscription: UIControlSubscription(subscriber: subscriber, control: control, event: controlEvents))
    }
}

/// Extending the `UIControl` types to be able to produce a `UIControl.Event` publisher.
protocol CombineCompatible { }
extension UIControl: CombineCompatible { }
extension CombineCompatible where Self: UIControl {
    func publisher(for events: UIControl.Event) -> UIControlPublisher<Self> {
        return UIControlPublisher(control: self, events: events)
    }
}


/*:
 ## Solving the UISwitch KVO problem
 #### As the `UISwitch.isOn` property does not support KVO this extension can become handy.
 */
extension CombineCompatible where Self: UISwitch {
    /// As the `UISwitch.isOn` property does not support KVO this publisher can become handy.
    /// The only downside is that it does not work with programmatically changing `isOn`, but it only responds to UI changes.
    var isOnPublisher: AnyPublisher<Bool, Never> {
        return publisher(for: [.allEditingEvents, .valueChanged]).map { $0.isOn }.eraseToAnyPublisher()
    }
}
