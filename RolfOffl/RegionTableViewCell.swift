import UIKit

class RegionTableViewCell: UITableViewCell {

    @IBOutlet weak var ortLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        backgroundColor = UIColor.red
    }
}
