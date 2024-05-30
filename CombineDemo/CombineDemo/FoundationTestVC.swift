//
//  FoundationTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/28.
//

import Foundation
import UIKit
import Combine


// 创建一个自定义的通知名称
extension Notification.Name {
    
    public static let customNotification = Notification.Name("CustomNotification")
}

//! model
struct Response: Decodable {
    struct Args: Decodable {
        let foo: String
    }
    
    let args: Args?
}

struct DecodableExample: Decodable { }


class FoundationTestVC: UIViewController {
    
    //! 被观察对象
    @objc dynamic var value: Int = 0

    
    var remoteDataPublisher:  URLSession.DataTaskPublisher?
    
    var sessionCancellable2: AnyCancellable?
    
    var cancellables = Set<AnyCancellable>()
    
    var timePublisher: AnyCancellable?

    @IBOutlet weak var ageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        example1()
        example2()
        example3()
        
        
      
    }
    
    deinit {
        sessionCancellable2?.cancel()
    }
    
    
    func example1() {
        
        
        
    }
    
    func example2() {
        
        self.publisher(for: \.value, options: .new)
            .receive(on: DispatchQueue.main)
            .sink { value in
                print("Value changed: \(value)")
            }.store(in: &cancellables)
        
        
//        self.addObserver(self, forKeyPath: #keyPath(self.value), options: [.new, .old], context: nil)

        
    }
    
    
    
    func example3() {
        
        
        NotificationCenter.default.publisher(for: .customNotification)
            .sink { notification in
                print("Received notification: \(notification)")
            }.store(in: &cancellables)

        
    }
    
    
    /// 网络
    @IBAction func httpsClick(_ sender: Any) {
        
        let url = "https://httpbin.org/get?foo=bar"
        
        let remoteDataPublisher = URLSession.shared.dataTaskPublisher(for: URL(string: url)!)
            .map { $0.data }
            .decode(type: Response.self, decoder: JSONDecoder())
        
        
        sessionCancellable2 = remoteDataPublisher
            .compactMap{$0.args?.foo}
            .subscribe(on: RunLoop.main)
            .print("日志")
            .sink { completion in
            print("sink() received the completion = ", String(describing: completion))
            
            switch completion {
            case .finished: 
                break
            case.failure(let anError):
                print("received error: ", anError)
            }
            
        } receiveValue: { someValue in
            print("解析最后结果： \(someValue)")
        }
        
    }
    
    
    
    @IBAction func customKvoClick(_ sender: Any) {
        self.value += 1
    }
    
    
    /// 通知
    @IBAction func notificationClick(_ sender: Any) {
        
        // 发送自定义通知
        let userInfo = ["message": "Hello, Combine!"]
        NotificationCenter.default.post(name: .customNotification, object: nil, userInfo: userInfo)
    }
    
    
    var count = 28
    
    /// 将数据绑定到 label上： 我直接赋值不香么？
    @IBAction func bindTextClick(_ sender: Any) {
        count += 1
        
        Just(count)
            .map { "Age is \($0)" }
            .assign(to: \.text, on: ageLabel)

    }
    
    /// 定时器
    @IBAction func timerClick(_ sender: UIButton) {
        
        if !sender.isSelected  {
            print("开启定时器")
            timePublisher = Timer
                .publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink {_ in
                    print("6")
                }
            
        } else {
            print("关闭定时器")
            timePublisher?.cancel()
        }
        
        sender.isSelected = !sender.isSelected
    }
    
    
}
