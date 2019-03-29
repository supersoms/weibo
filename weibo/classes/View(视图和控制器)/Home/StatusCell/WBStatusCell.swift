import UIKit

class WBStatusCell: UITableViewCell {

    ///微博试图模型
    var viewModel: WBStatusViewModel? {
        didSet{
            statusLabel?.text = viewModel?.status.text                                  //微博正文
            nameLabel.text = viewModel?.status.user?.screen_name                        //姓名
            memberIconView.image = viewModel?.memberIcon                                //设置会员图标
            vipIconView.image = viewModel?.vipIcon                                      //认证图标
            iconView.cz_setImage(urlString: viewModel?.status.user?.profile_image_url, placeholderImage: UIImage(named: "avatar_default_big"), isAvater: true)                                  //设置头像
            toolBar.viewModel = viewModel                                               //将当前这个viewModel传给toolBar的viewModel
            pictureView.heightCons.constant = viewModel?.pictureViewSize.height ?? 0    //测试修改配图视图的高度
            
            //测试4张图片的场景
//            if viewModel?.status.pic_urls?.count ?? 0 > 4{
//                //修改数组,将末尾的数据全部删除
//                var picUrls = viewModel!.status.pic_urls!
//                picUrls.removeSubrange((picUrls.startIndex+4)..<picUrls.endIndex) //从开始加到4，一直删到末尾
//                pictureView.urls = picUrls
//            } else {
//                pictureView.urls = viewModel?.status.pic_urls
//            }
            //设置配图，不管是原创微博的配图还是被转发微博的配图
            pictureView.urls = viewModel?.picUrls                               //设置配图视图的图片数据
            retweetedLabel?.text = viewModel?.retweetedText                     //如果是原创微博是没有这个的,所以要设为可选,没有就不设置text
        }
    }
    
    @IBOutlet weak var iconView: UIImageView!           //头像
    @IBOutlet weak var nameLabel: UILabel!              //姓名
    @IBOutlet weak var memberIconView: UIImageView!     //会员图标
    @IBOutlet weak var timeLabel: UILabel!              //时间
    @IBOutlet weak var sourceLabel: UILabel!            //来源
    @IBOutlet weak var vipIconView: UIImageView!        //认证图标
    @IBOutlet weak var statusLabel: UILabel!            //微博正文
    @IBOutlet weak var toolBar: WBStatusToolBar!        //底部工具栏
    @IBOutlet weak var pictureView: WBStatusPictureView!//配置视图
    @IBOutlet weak var retweetedLabel: UILabel?         //被转发微博的标签,因原创微博没有这个控件,所以要设为可选的
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
