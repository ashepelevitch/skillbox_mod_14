//
//  ViewController.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 27.01.2021.
//

import UIKit
import CoreData

class CoreDataViewController: UIViewController, CDEditViewControllerDelegate {
    // Инициируем массив моделей задач
    var toDoList = [ToDoModelCD]()
    // Получим контекст объекта
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext

    // Создадим связку с таблицей
    @IBOutlet weak var tableView: UITableView!
    // Создадим объект для форматирования даты и времени при выводе
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Загрузим сохраненные задачи
        loadUsersData()
    }

    func loadUsersData() {        
        // Создадим запрос на получение данных из таблицы
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDoModelCD")
        // У нас простая таблица, без связей, по этому будем загружать сразу, не используя "ленивую загрузку" данных
        request.returnsObjectsAsFaults = false
        // ...установим сортировку по дате наступления события
        request.sortDescriptors = [NSSortDescriptor(key: "eventDate", ascending: true)]
        // Обработаем запрос, учитывая возможные ошибки при получении данных
        do {
            let result = try context.fetch(request)
            var toDoList = [ToDoModelCD]()
            
            // пройдемся по списку полученных данных...
            for task in result as! [ToDoModelCD] {
                // ...и добавим их в локальный массив
                toDoList.append(task)
            }
            // Теперь присвоим полученный массива задач основному массиву класса
            self.toDoList = toDoList
        } catch let error {
            // Если в случае обработки произошла ошибка - выведем ее в консоль
            print("Error: \(error)")
        }
        
    }
    
    // функция удаления записи из таблицы базы данных и в таблице TableView
    private func removeRow(n: Int) {
        // проверим, что в нашем массиве задач есть задача для удаления
        if self.toDoList[n] != nil {
            do {
                // Удалим запись из контекста базы данных
                context.delete(self.toDoList[n] as NSManagedObject)
                // и удалим запись из нашего массива задач
                self.toDoList.remove(at: n)
                // Запишем итоговый контекст с перехватом ошибки
                try context.save()
            } catch let error as NSError {
                // Если произошла ошибка, отобразим ее в консоли
                print("Could not Update. \(error), \(error.userInfo)")
            }
        }
    }
    
    // функция перезагрузки таблицы (для вызова из экрана редактирования)
    public func tableReload() {
        self.tableView.reloadData()
    }
    
    // Обработаем нажатие на кнопку "+" - добавить задачу
    @IBAction func addButton(_ sender: Any) {
        self.performSegue(withIdentifier: "editTaskCD", sender: sender)
    }
}


// расширим наш контроллер для формирования таблицы с данными о погоде по часам и дням
extension CoreDataViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            self.performSegue(withIdentifier: "editTaskCD", sender: self.toDoList[indexPath.row])
            complete(true)
        }
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
               configuration.performsFirstActionWithFullSwipe = true
               return configuration
    }
    

    // В ячейке таблицы отобразим наименование задачи, дату и время задачи.
    // Если задача просрочена - выделим дату и время красным
    // Если задача выполнена - зачеркнем наименование задачи, дату и время выделим зеленым цветом, метку установим как включенную
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCellCD") as! ToDoCellCD
      
        let model = toDoList[indexPath.row]
     
        cell.taskLabel.text = model.title
        // установим визуальные свойства для типовой задачи, не выполненной и не просроченной
        cell.isCompletedImage.image = UIImage(systemName: "poweroff")
        
        
        cell.dateTaskLabel.textColor = .systemGray
        cell.timeTaskLabel.textColor = .systemGray
        
        let attrStr: NSMutableAttributedString =  NSMutableAttributedString(string: cell.taskLabel.text ?? "")
        // Если задача выполнена - зачеркнем аименование задачи, отметим дату и время зеленым цветом и активируем визуальный маркер
        if model.isCompleted {
            attrStr.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                             value: NSUnderlineStyle.single.rawValue,
                                             range: NSMakeRange(0, attrStr.length))
            
            cell.isCompletedImage.image = UIImage(systemName: "checkmark.circle.fill")
            
            cell.dateTaskLabel.textColor = .green
            cell.timeTaskLabel.textColor = .green
        } else {
            // Если задачу снова сделали на выполненной, необходимо дополнительно сбросить зачеркивание наименования задачи
            attrStr.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0, attrStr.length))
            attrStr.addAttribute(NSAttributedString.Key.strikethroughStyle,
                                 value: 0,
                                 range: NSMakeRange(0, attrStr.length))
        }
        
        cell.taskLabel.attributedText = attrStr
        // Софрматируем дату и время
        let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm:ss"

        cell.dateTaskLabel.text = dateFormatter.string(from: model.eventDate! as Date)
        cell.timeTaskLabel.text = timeFormatter.string(from: model.eventDate! as Date)
        
        // выделим дату и время красным, если задача просрочена и не выполнена
        if model.eventDate!.timeIntervalSince1970 < NSDate().timeIntervalSince1970 && !model.isCompleted {
            cell.dateTaskLabel.textColor = .red
            cell.timeTaskLabel.textColor = .red
        }

        return cell
    }
    
    // Обработаем клик по строке таблицы и откроем задачу на просмотр
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "openTaskCD", sender: self.toDoList[indexPath.row])
    }
    
    // Вызовем нужный экран - для просмотра задачи - openTask
    // для добавления/редактирования editTask, при редактировании передадим модель задачи
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openTaskCD" {
            let taskViewController = segue.destination as! TaskCDViewController
            taskViewController.selectedTask = sender as? ToDoModelCD
        } else if segue.identifier == "editTaskCD" {
            let taskEditViewController = segue.destination as! CoreDataEditViewController
            // Если добавляем новую задачу, то sender является кнопкой и при вызове экрана мы вместо нее передадим nil
            // При редактировании - передадим модель задачи, которую необходимо редактировать
            taskEditViewController.editedTask = (sender is UIBarItem) ? nil : sender
            taskEditViewController.delegate = self.self
            
        }
    }
    
}

