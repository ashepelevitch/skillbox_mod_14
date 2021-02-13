//
//  RealmEditViewController.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 28.01.2021.
//

import UIKit

// Опишем обратные функции для вызова в головном окне
protocol RealmEditViewControllerDelegate {
    func loadUsersData()
    func tableReload()
}

class RealmEditViewController: UIViewController, UITextFieldDelegate {

    // Модель для редактирования
    var editedTask : ToDoModel!
    // Создадим объект выбора даты и времени
    let datePicker = UIDatePicker()
    // Создадим объект для форматирования даты и времени при выводе
    let dateFormatter = DateFormatter()
    // Будем использовать протокол для работы с основным экраном
    var delegate: RealmEditViewControllerDelegate?
    
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

        // Заполним поля данными
        titleTextField.text = editedTask.title
        
        // Создадим привязку выбора даты и времени к текстовому полю
        if let eventDate = editedTask.eventDate {
            eventDateTextField.text = dateFormatter.string(from: eventDate as Date)
        }
        creteDatePicker()
        
        // Выставим переключатель решена ли задача или нет
        isCompletedSwitch.isOn = false
        isCompletedLabel.text = "Не выполнено"
        if editedTask.isCompleted {
            isCompletedSwitch.isOn = true
            isCompletedLabel.text = "Выполнено"
        }
        notesTextView.text = editedTask.notes
        
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
        
        // проверим - создаем новую задачу или обновляем имеющуюся?
        let isInsert = ("" == editedTask.id)
        
        // Объявим словарь, для заполнения его данными полей ввода
        // ключи в словаре у нас будут текстовые, а значения любого типа
        var fields: [Dictionary<String, Any>] = []
        
        // если новая задача - зададим поле ID
        if isInsert {
            fields.append(["id": UUID().uuidString])
        }
        
        // Заполним поля для сохранения в модели
        fields.append(["title": titleTextField.text!])
        fields.append(["eventDate": ("" != eventDateTextField.text) ? dateFormatter.date(from: eventDateTextField.text!)! : NSDate()])
        fields.append(["isCompleted": isCompletedSwitch.isOn])
        fields.append(["notes": notesTextView.text!])
            
        // Сохраним данные в модели
        RealmHandler.shared.saveModel(editedTask, data: fields, isInsert: isInsert)

        // У основного окна загрузим заново данные из базы
        delegate?.loadUsersData()
        // Перезагрузим таблицу
        delegate?.tableReload()
        // Завершим работу в этом окне
        dismiss(animated: true, completion: nil)
    }
}


// Добавим у TextView возможность выводить оконтовку заданным цветом и скруглять углы
@IBDesignable extension UITextView {
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
            layoutIfNeeded()
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}
