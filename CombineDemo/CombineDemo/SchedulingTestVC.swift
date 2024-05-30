//
//  SchedulingTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/28.
//

import Foundation
import UIKit
import Combine


/*:
# Scheduling operators
- Combine introduces the `Scheduler` protocol
- ... adopted by `DispatchQueue`, `RunLoop` and others
- ... lets you determine the execution context for subscription and value delivery
*/

class SchedulingTestVC: UIViewController {
    
    let firstStepDone = DispatchSemaphore(value: 0)

    
    let publisher = PassthroughSubject<String, Never>()
    let receivingQueue = DispatchQueue(label: "receiving-queue")

    
    var subscription1: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        example1()
        
    }
    
    deinit {
        subscription1?.cancel()
    }
    
    
    /*:
    ## `receive(on:)`
    - determines on which scheduler values will be received by the next operator and then on
    - used with a `DispatchQueue`, lets you control on which queue values are being delivered
    */
    func example1() {
        
        subscription1 = publisher
            .receive(on: receivingQueue)
            .sink { [weak self] value in
                guard let self = self else { return }
                
                print("Received value: \(value) on thread \(Thread.current)")
                if value == "Four" {
                    sleep(3)
                    
                    self.firstStepDone.signal()
                }
        }
        
    }
    
    
    /*:
    ## `subscribe(on:)`
    - determines on which scheduler the subscription occurs
    - useful to control on which scheduler the work _starts_
    - may or may not impact the queue on which values are delivered
    */
    func example2() {
        
        let subscription2 = [1,2,3,4,5].publisher
            .subscribe(on: DispatchQueue.global())
            .handleEvents(receiveOutput: { value in
                print("Value \(value) emitted on thread \(Thread.current)")
            })
            .receive(on: receivingQueue)
            .sink { value in
                print("Received value: \(value) on thread \(Thread.current)")
        }
        
    }
    
    @IBAction func queueClick(_ sender: Any) {
        
        for string in ["One","Two","Three","Four"] {
            DispatchQueue.global().async {
                self.publisher.send(string)
            }
        }

        firstStepDone.wait()
        
        print("Demonstrating")
    }
    
    
    @IBAction func globalClick(_ sender: Any) {
        example2()
        
    }
    
    
    
    
}
