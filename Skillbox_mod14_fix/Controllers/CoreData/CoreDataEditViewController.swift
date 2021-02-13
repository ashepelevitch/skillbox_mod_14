//
//  CoreDataEditViewController.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 30.01.2021.
//

import UIKit

// Опишем обратные функции для вызова в головном окне
protocol CDEditViewControllerDelegate {
    func loadUsersData()
    func tableReload()
}

class CoreDataEditViewController: UIViewController, UITextFieldDelegate {
    
    // Объект для редактирования - или nil (новая задача) или объект типа ToDoModelCD
    var editedTask : Any?
    
    // Создадим объект выбора даты и времени
    let datePicker = UIDatePicker()
    // Создадим объект для форматирования даты и времени при выводе
    let dateFormatter = DateFormatter()
    // Будем использовать протокол для работы с основным экраном
    var delegate: CDEditViewControllerDelegate?
    
    // свяжем необходимын элементы для вывода информации
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var isCompletedSwitch: UISwitch!
    @IBOutlet weak var isCompletedLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Укажем, что делегат для поля eventDateTextField
        // является наш контроллер - чтобы отключить ввод текста
        eventDateTextField.delegate = self

        // Установить формат даты и времени
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        // Если редактируем задачу, то заполним элементы ввода данными из этой задачи
        if let editObj = editedTask as? ToDoModelCD {
            // Заполним поля данными
            titleTextField.text = editObj.title
            
            if let eventDate = editObj.eventDate {
                eventDateTextField.text = dateFormatter.string(from: eventDate as Date)
            }

            isCompletedSwitch.isOn = false
            isCompletedLabel.text = "Не выполнено"
            if editObj.isCompleted {
                isCompletedSwitch.isOn = true
                isCompletedLabel.text = "Выполнено"
            }
            notesTextView.text = editObj.notes
        }
        
        // Создадим привязку выбора даты и времени к текстовому полю
        creteDatePicker()
        // Добавим Тап для обработки клика по Label, чтобы менять состояние связанного Switch
        let tap = UITapGestureRecognizer(target: self, action: #selector(RealmEditViewController.tapFunction))
        isCompletedLabel.isUserInteractionEnabled = true
        isCompletedLabel.addGestureRecognizer(tap)
    }
    
    // Создадим тулбар, элемент выбора даты и времени и кнопку "Применить"
    func creteDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(title: "Применить", style: .done, target: nil, action: #selector(doneButtonAction))
        toolbar.setItems([doneBtn], animated: true)
        
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale.init(identifier: localeID!)

        
        eventDateTextField.inputAccessoryView = toolbar
        
        datePicker.preferredDatePickerStyle = UIDatePickerStyle.wheels
        datePicker.datePickerMode = UIDatePicker.Mode.dateAndTime
        datePicker.minuteInterval = 5
        
        eventDateTextField.inputView = datePicker
        
    }
    
    // Функция обработки переключателя выполнения задачи
    func changeCompletedLabel(isCompleted: Bool) {
        isCompletedLabel.text = "Не выполнено"
        if isCompleted {
            isCompletedLabel.text = "Выполнено"
        }
    }
    
    // Функция, предотвращающая ввод данных в поле eventDateTextField
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //For mobile numer validation
        if textField == eventDateTextField {
            return false
        }
        return true
    }
    
    // Обработаем событие начала редактирования поля дата события
    @IBAction func eventDateDidBeginEditing(_ sender: Any) {
        // если поле не пустое, то попытаемся передать в селектор даты и времени его значение
        if "" != eventDateTextField.text {
            datePicker.date = dateFormatter.date(from: eventDateTextField.text!)!
        }
    }
    
    // Обработаем выбор даты и времени селектором
    @objc func doneButtonAction(){
        eventDateTextField.text = dateFormatter.string(from: datePicker.date as Date)
        self.view.endEditing(true)
    }
    
    // Событие возврата с экрана на основной экран
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Обработаем событие переключения выполнения задачи
    @IBAction func isCompletedSwitchAction(_ sender: Any) {
        changeCompletedLabel(isCompleted: isCompletedSwitch.isOn)
    }
    
    // Обработаем клик по тексту, связанному с переключателем выполнения задачи
    @objc func tapFunction(sender: UITapGestureRecognizer) {
        isCompletedSwitch.setOn(!isCompletedSwitch.isOn, animated: true)
        changeCompletedLabel(isCompleted: isCompletedSwitch.isOn)
    }
    
    // Обработаем событие нажатия на кнопку Записать
    @IBAction func saveButton(_ sender: Any) {
        // Объявим словарь, для заполнения его данными полей ввода
        // ключи в словаре у нас будут текстовые, а значения любого типа
        var fields: [Dictionary<String, Any>] = []
        
        // Заполним поля нового объекта значениями из полей ввода
        fields.append(["title": titleTextField.text!])
        fields.append(["eventDate": ("" != eventDateTextField.text) ? dateFormatter.date(from: eventDateTextField.text!)! as Date : Date()])
        fields.append(["isCompleted": isCompletedSwitch.isOn])
        fields.append(["notes": notesTextView.text!])
        
        // Если у нас редактирование задачи...
        if let editObj = editedTask as? ToDoModelCD {
            CoreDataHandler.shared.updateModel(editObj, data: fields)
        } else {
            // Для новой задачи задаим так же дату ее создания
            fields.append(["date": NSDate()])
            
            // И создадим запись в базе даннх
            CoreDataHandler.shared.createModel("ToDoModelCD", data: fields)
        }
        
        // У основного окна загрузим заново данные из базы
        delegate?.loadUsersData()
        // Перезагрузим таблицу
        delegate?.tableReload()
        // Завершим работу в этом окне
        dismiss(animated: true, completion: nil)
    }

}
