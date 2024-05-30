//
//  PublishTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/28.
//

import Foundation
import Combine
import UIKit

class PublishTestVC: UIViewController {
    
    //! 手动 管理 生命周期, 手动取消
    var cancellable1: AnyCancellable?
    var cancellable2: AnyCancellable?
    var cancellable3: AnyCancellable?

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print((#file+"\n"))
        
        example1()
        example2()
        example3()
        
    }
    
    //！ 打印 42
    func example1() {
       
        let publisher1 = Just(42)
   
        cancellable1 = publisher1
            .sink { value in
                print("订阅 publisher1: \(value)")
            }
        print("")
    }
    
    //! 打印 5 次， 分别是 1，2，3，4，5
    func example2() {
       
        let publisher2 = [1,2,3,4,5].publisher

        cancellable2 = publisher2
            .sink { value in
                print("订阅 publisher2: \(value)")
            }

        print("")
    }
    
    
    //! assign 函数: 将发布者值分配给对象上的属性
    func example3() {
        
        let publisher2 = [1,2,3,4,5].publisher

        let object = PublishTestObject()
        
        cancellable3 = publisher2
            .assign(to: \.property, on: object)
        
    }
    
    deinit {
        
        //! 取消订阅
        cancellable1?.cancel()
        cancellable2?.cancel()
        cancellable3?.cancel()

    }
}


 
class PublishTestObject {
    
    var property: Int = 0 {
        didSet {
            print("Did set property to \(property)")
        }
    }
}
