//
//  RecordsTableViewCell.swift
//  Memorama
//
//  Created by Noe  on 25/03/25.
//

import UIKit

class RecordsTableViewCell: UITableViewCell {

    @IBOutlet weak var labelScore: UILabel!
    @IBOutlet weak var labelErrors: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelNum: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
