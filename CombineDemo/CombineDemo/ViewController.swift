//
//  ViewController.swift
//  CombineDemo
//
//  Created by jingwan on 2024/5/28.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    let array = [
        "1. 基础的订阅",
        "2. subjects和publisher",
        "3. 内存管理",
        "4. 操作符",
        "5. 组合",
        "6. Scheduling",
        "7. Foundation 使用(请求，通知，定时器)",
        "8. 类的属性",
        "9. Future类",
        "10. 信号的事件处理",
        "11. 自定义点击事件(UIButton)"
    
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let textLabel = cell.textLabel {
            textLabel.text = array[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        var vcClassName: String = ""
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch indexPath.row {
        case 0 :
            vcClassName = "PublishTestVC"
        case 1 :
            vcClassName = "SubjectsTestVC"
        case 2 :
            vcClassName = "MemoryTestVC"
        case 3 :
            vcClassName = "OperatorsTestVC"
        case 4:
            vcClassName = "MergeTestVC"
        case 5:
            vcClassName = "SchedulingTestVC"
        case 6:
            vcClassName = "FoundationTestVC"
        case 7:
            vcClassName = "PropertiesInClassVC"
        case 8:
            vcClassName = "FutureClassTestVC"
        case 9:
            vcClassName = "DebuggingTestVC"
        case 10:
            vcClassName = "CustomUIKitTestVC"

        default:
            vcClassName = "PublishTestVC"
        }
        
        let viewController = storyboard.instantiateViewController(withIdentifier: vcClassName)
        self.navigationController?.pushViewController(viewController, animated: true)
        
        
    }
    
    
    func getClass(_ stringName:String) -> AnyClass? {
        guard let nameSpage = Bundle.main.infoDictionary!["CFbundleExecutable"] as? String else {
            return nil
        }
        
        guard let childVcClass = NSClassFromString(nameSpage+"."+stringName) else {
            return nil
        }
        
        return childVcClass
    }
    
}


