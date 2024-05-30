//
//  OperatorsTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/28.
//

import Foundation
import UIKit
import Combine

class OperatorsTestVC: UIViewController {
    
    
    let publisher1 = PassthroughSubject<Int, Never>()

    
    var subscription1: AnyCancellable?
    var subscription2: AnyCancellable?
    var subscription3: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        example1()
        example2()
        example3()
        example4()

    }
    
    deinit {
        subscription1?.cancel()
        subscription2?.cancel()
        subscription3?.cancel()
        subscription4?.cancel()
    }
    
    
    
    func example1() {
     
        subscription1 = publisher1
            .sink { value in
                print("subscription1 received integer: \(value)")
        }
        
     
    }
    
    func example2() {
        
        let publisher2 = publisher1.map { value in
            value + 100
        }
        
         
        subscription2 = publisher2
            .sink { value in
                print("Subscription2 received integer: \(value)")
        }

    }
    
    
    func example3() {
        let publisher3 = publisher1.filter {
            // only let even values pass through
            ($0 % 2) == 0
        }
        
        subscription3 = publisher3
            .sink { value in
                print("Subscription3 received integer: \(value)")
        }

    }
    
    /*:
    [Previous](@previous)
    ## flatmap
    - with `flatmap` you provide a new publisher every time you get a value from the upstream publisher
    - ... values all get _flattened_ into a single stream of values
    - ... it looks like Swift's `flatMap` where you flatten inner arrays of an array, just asynchronous.

    ## matching error types
    - use `mapError` to map a failure into a different error type
    */

    //: define the error type we need
    enum RequestError: Error {
        case sessionError(error: Error)
    }
    
    let URLPublisher = PassthroughSubject<URL, RequestError>()
    var subscription4: AnyCancellable?
    
    @IBOutlet weak var tempImageView: UIImageView!
    func example4() {
        
        //: use `flatMap` to turn a URL into a requested data publisher
        subscription4 = URLPublisher.flatMap { requestURL in
            URLSession.shared
                .dataTaskPublisher(for: requestURL)
                .mapError { error -> RequestError in
                    RequestError.sessionError(error: error)
            }
        }
        .assertNoFailure()
        .receive(on: DispatchQueue.main) //! 默认是自线程接收，因此需要设置一下
        .sink { [weak self] result in
            print("Request completed!")
            self?.tempImageView.image = UIImage(data: result.data)
        }
    }

    
    
    @IBAction func example1Click(_ sender: Any) {
        publisher1.send(21)

    }
    
    
    @IBAction func example2Click(_ sender: Any) {
        publisher1.send(16)

    }
    
    
    
    @IBAction func example3Click(_ sender: Any) {
        URLPublisher.send(URL(string: "https://httpbin.org/image/jpeg")!)
        
    }
    
    
    
}
