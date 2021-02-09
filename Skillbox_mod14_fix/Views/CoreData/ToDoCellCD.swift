//
//  ToDoCellCD.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 30.01.2021.
//

import UIKit

// Элементы для вывода информации из CoreData о задаче в строке таблицы
class ToDoCellCD: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var dateTaskLabel: UILabel!
    @IBOutlet weak var timeTaskLabel: UILabel!
    @IBOutlet weak var isCompletedImage: UIImageView!

}
