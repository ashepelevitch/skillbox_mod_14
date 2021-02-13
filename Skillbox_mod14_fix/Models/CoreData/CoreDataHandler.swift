//
//  CoreDataHandler.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 13.02.2021.
//

//import Foundation
import UIKit
import CoreData

class CoreDataHandler {
    // Singleton
    static let shared = CoreDataHandler()
    
    // Получим контекст объекта
    static let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    // Функция получения всех записей в таблице obj
    // Результат сортируем по массиву значений параметра sorted
    func fetchAll<T: NSManagedObject>(ofType obj: T.Type, sorted: [SortedParams]?) -> [T] {
        // Создадим запрос на получение данных из таблицы
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: obj))
        // У нас простая таблица, без связей, по этому будем загружать сразу, не используя "ленивую загрузку" данных
        request.returnsObjectsAsFaults = false
        // Установим сортировку согласно полученному параметру sorted...
        var sortDesc: [NSSortDescriptor] = []
        // ... для этого сначала проверим, что sorted не пустой
        if let sortedList = sorted {
            // ... затем пройдемся по массиву и добавим в нашу переменную
            for sortItem in sortedList {
                sortDesc.append(NSSortDescriptor(key: sortItem.field, ascending: sortItem.asc))
            }
            // ... установим сортировку
            request.sortDescriptors = sortDesc
        }
        
        // Создадим пустой массив типа <T>
        var modelList = [T]()
        // Обработаем запрос, учитывая возможные ошибки при получении данных
        do {
            let result = try context.fetch(request)
            
            // пройдемся по списку полученных данных...
            for task in result as! [T] {
                // ...и добавим их в локальный массив
                modelList.append(task)
            }
        } catch let error {
            // Если в случае обработки произошла ошибка - выведем ее в консоль
            print("Error: \(error)")
        }
        // Вернем полученный массив загруженных значений
        return modelList
    }
    
    // Функция создания новой модели (записи в табдице) с именем modelName
    // Данные для записи берутся из массива справочников data
    func createModel(_ modelName: String, data: [Dictionary<String, Any>]) {
        // Создадим новый объект в контексте
        let entity = NSEntityDescription.entity(forEntityName: modelName, in: context)
        let model = NSManagedObject(entity: entity!, insertInto: context)
        
        // Пройдемся по всем данным и возьмем инфо о ключе и значении...
        for item in data {
            for (param, value) in item {
                // ... и запишем в модель
                model.setValue(value, forKey: param)
            }
        }

        // Запишем контекст с изменениями
        CoreDataHandler.appDelegate.saveContext()
    }
    
    // Функция обновления значений модели model (записи в табдице)
    // Данные для записи берутся из массива справочников data
    func updateModel<T: NSManagedObject>(_ model: T, data: [Dictionary<String, Any>]) {
        // Пройдемся по всем данным и возьмем инфо о ключе и значении...
        for item in data {
            for (param, value) in item {
                // ... и запишем в модель
                model.setValue(value, forKey: param)
            }
        }
    }
    
    // Функция удаления модели (записи в таблице)
    func delete<T: NSManagedObject>(obj: T) -> Bool {
        // для начала примем что результат удаления отрицательный
        var result = false
        
        do {
            // Удалим запись из контекста базы данных
            context.delete(obj)
            
            // Запишем итоговый контекст с перехватом ошибки
            try context.save()
            // Если ошибки нет, то мы дойдем до этого шага и установим результат как положительный
            result = true
        } catch let error as NSError {
            // Если произошла ошибка, отобразим ее в консоли
            print("Could not Update. \(error), \(error.userInfo)")
        }
        // Вернем результат
        return result
    }
}
