import UIKit

/// 撰写微博控制器
class WBComposeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.cz_random()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "退出", target: self, actionMethod: #selector(close))
    }
    
    @objc private func close(){
        dismiss(animated: true, completion: nil)
    }
}
