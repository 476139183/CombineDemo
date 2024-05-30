//
//  DebuggingTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/29.
// https://www.cnblogs.com/ficow/p/13788610.html

import Foundation
import UIKit
import Combine

/*:
## Debugging
Operators which help debug Combine publishers

More info: [https://www.avanderlee.com/debugging/combine-swift/‎](https://www.avanderlee.com/debugging/combine-swift/‎)
*/

class DebuggingTestVC: UIViewController {
    
    
    let subject = PassthroughSubject<String, ExampleError>()

    
    var subscription : AnyCancellable?
    
    var printSubscription: AnyCancellable?
    
    var breakSubscription: Publishers.Breakpoint<PassthroughSubject<String, ExampleError>>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        example1()
        example2()
        example3()
    }
    
    
    @IBAction func click1(_ sender: Any) {
        
        subject.send("Hello!")
        subscription?.cancel()
    }
    
    
    @IBAction func click2(_ sender: Any) {
        subject.send("world!")
        printSubscription?.cancel()
    }
    
    
        
    /*:
    ### Handling events
    Can be used combined with breakpoints for further insights.
    - exposes all the possible events happening inside a publisher / subscription couple
    - very useful when developing your own publishers
    */
    func example1() {
        
        subscription = subject
            .handleEvents(receiveSubscription: { (subscription) in
                print("Receive subscription 1")
            }, receiveOutput: { output in
                print("Received output 1: \(output)")
            }, receiveCompletion: { _ in
                print("Receive completion 1")
            }, receiveCancel: {
                print("Receive cancel 1")
            }, receiveRequest: { demand in
                print("Receive request 1: \(demand)")
            }).replaceError(with: "Error occurred 1")
            .sink { _ in }
    
        
    }
    
    
    // Prints out:
    // Receive request: unlimited
    // Receive subscription
    // Received output: Hello!
    // Receive cancel

    //subject.send(completion: .finished)

    /*:
    ### `print(_:)`
    Prints log messages for every event
    */

    func example2() {
        
         printSubscription = subject
            .print("Print example 2")
            .replaceError(with: "Error occurred 2")
            .sink { _ in }
        
    }
    
    
    
    // Prints out:
    // Print example: receive subscription: (PassthroughSubject)
    // Print example: request unlimited
    // Print example: receive value: (Hello!)
    // Print example: receive cancel

    /*
     官方文档
     https://developer.apple.com/documentation/realitykit/scene/publisher/breakpoint(receivesubscription:receiveoutput:receivecompletion:)?changes=311
     
     */
    
    
    
    /*:
    ### `breakpoint(_:)`
    Conditionally break in the debugger when specific values pass through
    */
    
    //  breakpoint 操作符可以发送调试信号来让调试器暂停进程的运行，只要在给定的闭包中返回 true 即可。
    func example3() {
       
        breakSubscription = subject
            .breakpoint(receiveOutput: { value in
                value == "Hello!"
            })
        
   
    }


    
    
    
}
