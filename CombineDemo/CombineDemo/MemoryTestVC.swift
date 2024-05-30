//
//  MemoryTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/28.
//

import Foundation
import UIKit
import Combine

class MemoryTestVC: UIViewController {
    
    let subject = PassthroughSubject<Int,Never>()
    let subject2 = PassthroughSubject<Int,Never>()
    var object: MemoryTestClass?
    var object2: MemoryTestClass2?

    
    //! 自动管理
    var cancellables = Set<AnyCancellable>()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        example1()
        example2()
        
        example3()
        

    }
    
    
    func example1() {
        
        object = MemoryTestClass(subject: subject)
        emitNextValue(from: [1,2,3,4,5,6,7,8], after: 0.5)
    }
    
    func example2() {
        
        object2 = MemoryTestClass2(subject: subject2)
        emitNextValue2(from: [1,2,3,4,5,6,7,8], after: 0.5)
    }

    
    func example3() {
        
        [1,2,3,4,5].publisher.sink { value in
            print("订阅: \(value)")
        }.store(in: &cancellables)
      
    }
    
    
    func emitNextValue(from values: [Int], after delay: TimeInterval) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            var array = values
            self.subject.send(array.removeFirst())
            if !array.isEmpty {
                self.emitNextValue(from: array, after: delay)
            }
        }
    }
    
    func emitNextValue2(from values: [Int], after delay: TimeInterval) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            var array = values
            self.subject2.send(array.removeFirst())
            if !array.isEmpty {
                self.emitNextValue2(from: array, after: delay)
            }
        }
    }

    
}

class MemoryTestClass {

    var cancellable: Cancellable? = nil

    var variable: Int = 0 {
        didSet {
            print("MemoryTestClass object.variable = \(variable)")
        }
    }

    init(subject: PassthroughSubject<Int,Never>) {
        
        cancellable = subject.sink { value in
            // Note that we are introducing a retain cycle on `self`
            // on purpose, by not using `weak` or `unowned`
            // 取消这一行，则发现 MemoryTestClass 可以被销毁
            self.variable += value
        }
    }

    deinit {
        
        cancellable?.cancel()
        print("MemoryTestClass object deallocated")
    }
}



class MemoryTestClass2 {

    var cancellable: Cancellable? = nil

    var variable: Int = 0 {
        didSet {
            print("MemoryTestClass2 object.variable = \(variable)")
        }
    }

    init(subject: PassthroughSubject<Int,Never>) {
        
        cancellable = subject.sink {[weak self] value in
           
            //! 这里使用 弱应用 来杜绝 循环引用，也可以销毁
            self?.variable += value
        }
    }

    deinit {
        
        cancellable?.cancel()
        print("MemoryTestClass2 object deallocated")
    }
}
