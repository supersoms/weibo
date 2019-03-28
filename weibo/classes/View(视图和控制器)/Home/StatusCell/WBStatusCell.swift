import UIKit

class WBStatusCell: UITableViewCell {

    ///微博试图模型
    var viewModel: WBStatusViewModel? {
        didSet{
            self.statusLabel?.text = viewModel?.status.text             //微博正文
            self.nameLabel.text = viewModel?.status.user?.screen_name   //姓名
            self.memberIconView.image = viewModel?.memberIcon           //设置会员图标
            self.vipIconView.image = viewModel?.vipIcon                 //认证图标
            self.iconView.cz_setImage(urlString: viewModel?.status.user?.profile_image_url, placeholderImage: UIImage(named: "avatar_default_big"), isAvater: true)                  //设置头像
        }
    }
    
    
    @IBOutlet weak var iconView: UIImageView!           //头像
    @IBOutlet weak var nameLabel: UILabel!              //姓名
    @IBOutlet weak var memberIconView: UIImageView!     //会员图标
    @IBOutlet weak var timeLabel: UILabel!              //时间
    @IBOutlet weak var sourceLabel: UILabel!            //来源
    @IBOutlet weak var vipIconView: UIImageView!        //认证图标
    @IBOutlet weak var statusLabel: UILabel!            //微博正文
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
