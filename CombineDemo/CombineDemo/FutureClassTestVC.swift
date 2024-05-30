//
//  FutureClassTestVC.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/29.
//

import Foundation
import UIKit
import Combine

struct User {
    let id: Int
    let name: String
}

enum FetchError: Error {
    case userNotFound
}

//!MARK:  FutureClassTestVC 控制器
class FutureClassTestVC: UIViewController {
    
    let users = [User(id: 0, name: "Antoine"), User(id: 1, name: "Henk"), User(id: 2, name: "Bart")]
    
    let fetchUserPublisher = PassthroughSubject<Int, FetchError>()
    
    var cancellable1: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        example1()
        
    }
    
    /*:
    ## Future and Promises
    - a `Future` delivers exactly one value (or an error) and completes
    - ... it's a lightweight version of publishers, useful in contexts where you'd use a closure callback
    - ... allows you to call custom methods and return a Result.success or Result.failure
    */

    func example1() {
        cancellable1 =
        fetchUserPublisher
            .flatMap { userId -> Future<User, FetchError> in
                Future {[weak self] promise in
                    guard let self = self else {return}
                    
                    fetchUser(for: userId) { (result) in
                        switch result {
                        case .success(let user):
                            promise(.success(user))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
                }
        }
        .map { user in user.name }
        .catch { (error) -> Just<String> in
            print("Error occurred: \(error)")
            return Just("Not found")
        }
        .sink { result in
            print("User is \(result)")
        }
        
    }
    
    deinit {
        cancellable1?.cancel()
    }
    
    @IBAction func sendSignClick(_ sender: Any) {
        //! 寻找制定的id 并打印 name
        fetchUserPublisher.send(0)
        fetchUserPublisher.send(5)
    }
    
    
}

extension FutureClassTestVC {
    
    
    func fetchUser(for userId: Int, completion: (_ result: Result<User, FetchError>) -> Void) {
        if let user = users.first(where: { $0.id == userId }) {
            completion(Result.success(user))
        } else {
            completion(Result.failure(FetchError.userNotFound))
        }
    }

}
