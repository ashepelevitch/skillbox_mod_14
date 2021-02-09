//
//  ToDoCell.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 29.01.2021.
//

import UIKit

// Элементы для вывода информации из Realm о задаче в строке таблицы
class ToDoCell: UITableViewCell {
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var dateTaskLabel: UILabel!
    @IBOutlet weak var chevronImage: UIImageView!
    @IBOutlet weak var timeTaskLabel: UILabel!
    
}
