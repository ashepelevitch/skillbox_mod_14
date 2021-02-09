//
//  TaskCDViewController.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 30.01.2021.
//

import UIKit

// Класс для просмотра задачи
class TaskCDViewController: UIViewController {

    // Переданная модель для просмотра
    var selectedTask : ToDoModelCD!
    
    // свяжем необходимын элементы для вывода информации
    @IBOutlet weak var titleNavigation: UINavigationItem!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var isCompletedSwitch: UISwitch!
    @IBOutlet weak var isCompletedLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Заполним элементы данными из модели
        titleNavigation.title = selectedTask.title
        
        titleLabel.text = selectedTask.title
        isCompletedSwitch.isOn = false
        isCompletedLabel.text = "Не выполнено"
        if (selectedTask.isCompleted) {
            isCompletedSwitch.isOn = true
            isCompletedLabel.text = "Выполнено"
        }
        
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        
        eventDateLabel.text = dateFormatter.string(from: selectedTask.eventDate! as Date)
        dateLabel.text = dateFormatter.string(from: selectedTask.date! as Date)
        
        notesLabel.text = selectedTask.notes
    }
    

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
