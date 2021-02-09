//
//  UDViewController.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 28.01.2021.
//

import UIKit

class UDViewController: UIViewController {

    // основные элементы для ввода/вывода информации
    @IBOutlet weak var name1TextField: UITextField!
    @IBOutlet weak var surname1TextField: UITextField!
    
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var surname2TextField: UITextField!
    
    // ключи для связывания данных в UserDefaults
    let udKey = "keyUser.dy34fy34d56yfd"
    let uNameKey = "keyUser.kshYUTvvtVT2"
    let uSurNameKey = "keyUser.67V&r67rc67r"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Если есть данные после сохранения кнопкой, отобразим их
        if let data = UserDefaults.standard.dictionary(forKey: udKey) {
            name1TextField.text = data["userName"] as? String
            surname1TextField.text = data["userSurname"] as? String
        }
        // если есть данные после автосохранения поля Имя, отобразим их
        if let name2 = UserDefaults.standard.string(forKey: uNameKey) {
            name2TextField.text = name2
        }
        // если есть данные после автосохранения поля Фамилия, отобразим их
        if let surname2 = UserDefaults.standard.string(forKey: uSurNameKey) {
            surname2TextField.text = surname2
        }
    }
    
    // Сохраним данные об имени и фамилии из первого блока
    @IBAction func saveBtnAction(_ sender: Any) {
        UserDefaults.standard.set([
            "userName": name1TextField.text!,
            "userSurname": surname1TextField.text!
        ], forKey: self.udKey)
    }
    
    // Если поле Имя из 2-го блока было изменено, сохраним его
    @IBAction func name2EditChanged(_ sender: Any) {
        UserDefaults.standard.set(name2TextField.text!, forKey: self.uNameKey)
    }
    
    // Если поле Фамилия из 2-го блока было изменено, сохраним его
    @IBAction func surname2EditChanged(_ sender: Any) {
        UserDefaults.standard.set(surname2TextField.text!, forKey: self.uSurNameKey)
    }
    
    
}
