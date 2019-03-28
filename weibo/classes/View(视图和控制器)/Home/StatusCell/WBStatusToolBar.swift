import UIKit

//微博列表底部3个按钮的工具栏
class WBStatusToolBar: UIView {
    
    var viewModel: WBStatusViewModel? {
        didSet{
            retweetedBtn.setTitle(viewModel?.retweetedStr, for: .normal)
            commentBtn.setTitle(viewModel?.commentStr, for: .normal)
            likeBtn.setTitle(viewModel?.likeStr, for: .normal)
        }
    }
    
    @IBOutlet weak var retweetedBtn: UIButton!      //转发
    @IBOutlet weak var commentBtn: UIButton!        //评论
    @IBOutlet weak var likeBtn: UIButton!           //赞
}
