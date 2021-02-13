//
//  RealmHandler.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 11.02.2021.
//

import Foundation
import RealmSwift

let realmInstance = try! Realm()

// Опишем структуру параметров функция для сортировки результата
struct SortedParams {
    let field: String
    let asc: Bool
}

class RealmHandler {
    // Singleton
    static let shared = RealmHandler()
    
    // Функция получения всех записей в таблице obj
    // Результат сортируем по массиву значений параметра sorted
    func fetchAll<T: RealmSwift.Object>(ofType itemType: T.Type, sorted: [SortedParams]?) -> [T] {
        // Создадим пустой массив типа <T>
        var modelList = [T]()
        // Создадим пустой массив типа SortDescriptor для возможной сортировки результатов выборки
        var sortDesc: [SortDescriptor] = []
        
        // Если в параметрах указана сортировка...
        if let sortedList = sorted {
            // ... заполним массив нужными значениями
            for sortItem in sortedList {
                sortDesc.append(SortDescriptor(keyPath: sortItem.field, ascending: sortItem.asc))
            }
        }

        // Запросим список объектов для таблицы <T> и установим нужную сортировку
        for task in realmInstance.objects(T.self).sorted(by: sortDesc) {
            // Заполним массив значениями из таблицы
            modelList.append(task)
        }

        return modelList
    }
    
    
    /*
     Функция записи модели
     Используется для создания новой записи и изменения имующейся записи в таблице  model
     Данные для записи берутся из массива справочников data
     Если добавление новой записи - isInsert = true
     */
    func saveModel<T: Object>(_ model: T, data: [Dictionary<String, Any>]?, isInsert: Bool = false) {
        do {
            try realmInstance.write {
                //  Проверим наличие параметров для записи и пройдемся по очереди по ним
                if let fields = data {
                    for item in fields {
                        // Если параметры есть, возьмем данные о ключе и значении...
                        for (param, value) in item {
                            // ... и запишем в модель
                            model.setValue(value, forKey: param)
                        }
                    }
                }
                    
                // Запишем изменения в базу. Учтем - новая запись или обовление
                realmInstance.add(model, update: (isInsert) ? .error : .all)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    
    // Функция удаления всех записей в таблицах
    func deleteAll<T: Object>(_ data: [T.Type]) {
        realmInstance.refresh()

        try? realmInstance.write {
            for object in data {
                let allObjects = realmInstance.objects(object)
                realmInstance.delete(allObjects)
            }
        }
    }
}
