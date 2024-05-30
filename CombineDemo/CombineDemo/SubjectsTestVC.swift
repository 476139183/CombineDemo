//
//  SubjectsTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/28.
//

import Foundation
import UIKit
import Combine


/*:
# Subjects
- A `subject` is a `publisher` ...
- ... relays values it receives from other `publishers` ...
- ... can be manually fed with new values
- ... `subjects` as also subscribers, and can be used with `subscribe(_:)`
*/



enum ExampleError: Swift.Error {
    case somethingWentWrong
}

class SubjectsTestVC: UIViewController {
    
    let relay = PassthroughSubject<String, Never>()

    let variable = CurrentValueSubject<String, Never>("")
    
    
    
    var subscription1 : AnyCancellable?
    var subscription3 : AnyCancellable?
    var subscription4 : AnyCancellable?

    
    
    let subject = PassthroughSubject<String, ExampleError>()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        example1()
        example2()
        example3()
        example4()
        
        
    }
    
    //！1. 发送两次给 subscribers
    @IBAction func replayClick(_ sender: Any) {
        relay.send("Hello")
        relay.send("World! ")

    }
    
    //！2. 将数组的值发送过去，
    @IBAction func subscribeClick(_ sender: Any) {
        
        let publisher = ["Here","we","go!"].publisher
         
        let subscription2 = publisher.subscribe(relay)
        subscription2.cancel()
    }
    
    // 使用' currentvaluessubject '来保存最新的值并将其传递给新的订阅者,
    @IBAction func variableClick(_ sender: Any) {
        variable.send("More text")
    }
    
    
    /*:
     ## Subscription details
     - A subscriber will receive a _single_ subscription
     - _Zero_ or _more_ values can be published
     - At most _one_ {completion, error} will be called
     - After completion, nothing more is received
     */
    // 3. 如果没点击，则还会调用 cancelled， 如果点击了，则不在接收，也就是 receiveCancel也不会调用
    @IBAction func subjectClick(_ sender: Any) {
        
        subject.send("Hello!")
        subject.send("Hello again!")
        subject.send("Hello for the last time!")
        subject.send(completion: .failure(.somethingWentWrong))
        //! 被拦截，打印不出来，后续也会取消
        subject.send("Hello?? :(")
        
    }
    
    
    
    deinit {
        subscription1?.cancel()
        subscription3?.cancel()
        subscription4?.cancel()
    }
}


extension SubjectsTestVC {
    
    func example1() {

        subscription1 = relay
            .sink { value in
            print("subscription1 received value: \(value)")
        }
        
    }
    
    
    func example2() {
        /// 查看 subscribeClick
    }
    
    func example3() {
        
        //！ 会保存一次 等订阅的时候触发
        variable.send("Initial text")

        subscription3 = variable.sink { value in
            print("subscription3 received value: \(value)")
        }
        
    }

    func example4() {
   
        // The handleEvents operator lets you intercept
        // All stages of a subscription lifecycle
        
        subscription4 = subject
            .handleEvents(receiveSubscription: { (subscription) in
                print("New subscription!")
            }, receiveOutput: { _ in
                print("Received new value!")
            }, receiveCompletion: { _ in
                print("A subscription4 完成")
            }, receiveCancel: {
                print("A subscription4 取消")
            })
            .replaceError(with: "错误")
            .sink { (value) in
                print("Subscriber received value: \(value)")
            }
    }

    
   

    
}
