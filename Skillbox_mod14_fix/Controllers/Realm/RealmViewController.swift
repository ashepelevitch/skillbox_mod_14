//
//  RealmViewController.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 28.01.2021.
//

import UIKit

class RealmViewController: UIViewController, RealmEditViewControllerDelegate {
    // Инициируем массив моделей задач
    var toDoList = [ToDoModel]()
    
//    var currentCreateAction:UIAlertAction!
    // Создадим объект выбора даты и времени
    var datePicker:UIDatePicker = UIDatePicker()
    //... и тулбар для него
    let toolBar = UIToolbar()
    
    // создадим связку с таблицей
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Загрузим сохраненные задачи
        self.loadUsersData()
    }
    

    // загружаем данные из Realm в наш data source
    func loadUsersData() {
        self.toDoList = RealmHandler.shared.fetchAll(ofType: ToDoModel.self, sorted: [SortedParams(field: "eventDate", asc: false)])
    }

    // функция удаления записи из таблицы базы данных и в таблице TableView
    private func removeRow(n: Int) {
        // проверим, что в нашем массиве задач есть задача для удаления
        if self.toDoList[n] != nil {
            // для надежности удалим задачу по ее ID
            if let tdModel = ToDoModel.find(id: toDoList[n].id) {
                // удалим сам объект в базе
                tdModel.remove()
                // ... и удалим запись из визуальной таблицы
                self.toDoList.remove(at: n)
            }
        }
    }
    
    // функция перезагрузки таблицы (для вызова из экрана редактирования)
    public func tableReload() {
        self.tableView.reloadData()
    }
    
    // Обработаем нажатие на кнопку "+" - добавить задачу
    @IBAction func addButton(_ sender: Any) {
        // Вызовем экран редактирования и передадим ему новую модель задачи (так как это добавление)
        self.performSegue(withIdentifier: "editTask", sender: ToDoModel())
    }
    
}

// расширим наш контроллер для формирования таблицы с данными о погоде по часам и дням
extension RealmViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return 61.0;
    }
    
    // расширим функцию, возвращающую кол-во строк в разделе таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoList.count
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // дополним строки таблицы кнопками Редактирования и Удаления записей при смахивании
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, complete in
            self.removeRow(n: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic) // .fade
            complete(true)
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Редакт.") { _, _, complete in
            self.performSegue(withIdentifier: "editTask", sender: self.toDoList[indexPath.row])
            complete(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
               configuration.performsFirstActionWithFullSwipe = true
               return configuration
    }
    

    // В ячейке таблицы отобразим наименование задачи, дату и время задачи.
    // Если задача просрочена - выделим дату и время красным
    // Если задача выполнена - зачеркнем наименование задачи
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell") as! ToDoCell
      
        let model = toDoList[indexPath.row]
     
        cell.taskLabel.text = model.title
        
        let attributeString =  NSMutableAttributedString(string: model.title)
        // зачеркнем наименование задачи, если она уже выполнена
        if model.isCompleted {
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                             value: NSUnderlineStyle.single.rawValue,
                                             range: NSMakeRange(0, attributeString.length))
            
        } else {
            attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                 value: 0,
                                 range: NSMakeRange(0, attributeString.length))
        }
        cell.taskLabel.attributedText = attributeString
        
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"

        cell.dateTaskLabel.text = dateFormatter.string(from: model.eventDate! as Date)
        cell.timeTaskLabel.text = timeFormatter.string(from: model.eventDate! as Date)
        
        // выделим дату и время красным, если задача просрочена
        cell.dateTaskLabel.textColor = .systemGray
        cell.timeTaskLabel.textColor = .systemGray
        if model.eventDate!.timeIntervalSince1970 < NSDate().timeIntervalSince1970 {
            cell.dateTaskLabel.textColor = .red
            cell.timeTaskLabel.textColor = .red
        }

        return cell
    }
    
    // Обработаем клик по строке таблицы и откроем задачу на просмотр
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openTask", sender: self.toDoList[indexPath.row])
    }
    
    // Вызовем нужный экран - для просмотра задачи - openTask
    // для добавления/редактирования editTask, при этом передадим модель
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openTask" {
            let taskViewController = segue.destination as! TaskViewController
            taskViewController.selectedTask = sender as? ToDoModel
        } else if segue.identifier == "editTask" {
            let taskEditViewController = segue.destination as! RealmEditViewController
            taskEditViewController.editedTask = sender as? ToDoModel
            taskEditViewController.delegate = self.self
            
        }
    }
    
}
