//
//  PropertiesInClassVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/29.
//

import Foundation
import UIKit
import Combine

final class FormViewModel {
    //！ 观察 属性
    @Published var isSubmitAllowed: Bool = true
    @Published var array: [Int] = []

}

final class ObservableFormViewModel: ObservableObject {
    @Published var isSubmitAllowed: Bool = true
    @Published var username: String = "旧名称"
    @Published var password: String = "旧密码"
    
    var somethingElse: Int = 10
}





class PropertiesInClassVC: UIViewController {
    
    
    var viewModel = FormViewModel()
    
    var form = ObservableFormViewModel()

    
    var cancellables = Set<AnyCancellable>()

    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        example1()
        example2()
        example3()
    }
    
    
    //! 绑定属性
    func example1() {
        
        // subscribe to a @Published property using the $ wrapped accessor
        viewModel.$isSubmitAllowed
            .receive(on: DispatchQueue.main)
            .print()
            .assign(to: \.isEnabled, on: submitButton)
            .store(in: &cancellables)
        
        
    }
    
    //! 监听数组变化
    func example2() {
        viewModel.$array
            .sink { newArray in
                print("Array count: \(newArray.count)")
            }.store(in: &cancellables)
    }
    
    
    //! 监听属性变化
    func example3() {
        //! 调用了三次 objectWillChange, 获取到旧值
        form.objectWillChange.sink { [weak self] _ in
            guard let self = self else {return}
            print("Form changed: \(form.isSubmitAllowed) \"\(form.username)\" \"\(form.password)\"")
        }.store(in: &cancellables)
        
    }
    
    
    @IBAction func changeArrayCount(_ sender: Any) {
        
        viewModel.array.append(1)
    }
    
    
    @IBAction func changeValueClick(_ sender: Any) {
        form.isSubmitAllowed = false
        form.username = "新名称"
        form.password = "新密码"
        form.somethingElse = 0    // note that this doesn't output anything

    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        viewModel.isSubmitAllowed = false
        
    }
    
}
