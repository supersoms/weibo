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
            
            //配图视图视图模型
            pictureView.viewModel = viewModel
            //如果是原创微博是没有这个的,所以要设为可选,没有就不设置text
            retweetedLabel?.text = viewModel?.retweetedText
            //设置微博来源
            //sourceLabel.text = viewModel?.sourceStr
            sourceLabel.text = viewModel?.status.source
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
        
        //FIXME: 提高tableView的刷新频率性能，以及解决图片拉伸,混合图层等性能,需要做以下设置,以下设置是高级优化
        
        //离屏渲染实现,就是异步绘制
        self.layer.drawsAsynchronously = true
        
        //栅格化,异步绘制之后,会生成一张独立的图像,cell在屏幕上滚动的时候,本质上滚动的是这张图片
        self.layer.shouldRasterize = true
        
        //栅格化优化之后,会造成界面上的文字或图片不清楚,那怎么解决这个问题呢？必须指定分辨率即可解决
        self.layer.rasterizationScale = UIScreen.cz_scale()
        
        //TODO 以上的高级优化，如果检测到cell的性能己经很好了,就不需要离屏渲染
    }
}
