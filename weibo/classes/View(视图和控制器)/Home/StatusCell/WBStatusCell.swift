import UIKit

class WBStatusCell: UITableViewCell {

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
