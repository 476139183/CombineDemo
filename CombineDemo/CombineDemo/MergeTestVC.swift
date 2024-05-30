//
//  MergeTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/28.
//

import Foundation
import UIKit
import Combine

class MergeTestVC: UIViewController {
    
    
    let usernamePublisher = PassthroughSubject<String, Never>()
    let passwordPublisher = PassthroughSubject<String, Never>()
    
    var validatedCredentialsSubscription: AnyCancellable?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        example1()
        
    }
    
    func example1() {
        
        //！ 将 两个字符串 信号 合并 并映射成一个 bool 信号
        validatedCredentialsSubscription = Publishers
            .CombineLatest(usernamePublisher,passwordPublisher)
            .map{ (username, password) -> Bool in
                !username.isEmpty && !password.isEmpty && password.count > 12
            }
            .sink{ valid in
                print("CombineLatest: are the credentials valid? = \(valid)")
            }
        
    }
    
    
    /*:
    ## `Merge`
    - merges multiple publishers value streams into one
    - ... values order depends on the absolute order of emission amongs all merged publishers
    - ... all publishers must be of the same type.
    */
    //! 将打印 所有的 value
    func example2() {
        let publisher1 = [1,2,3,4,5].publisher
        let publisher2 = [300,400,500].publisher
        
        let mergedPublishersSubscription = Publishers
            .Merge(publisher1, publisher2)
            .sink { value in
                print("Merge: subscription received value \(value)")
        }
        
        
    }
    
    
    @IBAction func CombineClick(_ sender: Any) {
        usernamePublisher.send("avanderlee")
        passwordPublisher.send("weakpass")
        passwordPublisher.send("verystrongpassword")
    }
    
    
    
    @IBAction func MergeClick(_ sender: Any) {
        example2()
    }
    
}
