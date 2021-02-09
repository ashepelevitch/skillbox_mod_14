//
//  WeatherParse.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 01.02.2021.
//

import Foundation

/**
 Класс для парсинга данных о погоде - для погоды по часам
 */
class WeatherParse {
    /**
        Функция парсинга данных о погоде через каждые 3 часа
     */
    func parseToThreeHours(weatherList: [WeatherThreeHoursModel], completion: @escaping ([WeatherGroups]) -> Void) {
        var weatherThreeHoursList: [WeatherGroups] = []
        
        // Сгруппируем записи в списке weatherList по полю date
        let groups = weatherList.group(by: { $0.date })
        // Продемся по группам...
        for group in groups {
            // .. определим дату текущей группы...
            let date = group.first!.date
            // ... и добавим с массив групп связку наименования группы и списка моделей
            weatherThreeHoursList.append(WeatherGroups(date: date, weathers: group))
        }
        // вернем полученный массив
        completion(weatherThreeHoursList)

    }
}

// Дополним функционал для группироки данных по полю
extension Sequence {
    func group<GroupingType: Hashable>(by key: (Iterator.Element) -> GroupingType) -> [[Iterator.Element]] {
        var groups: [GroupingType: [Iterator.Element]] = [:]
        var groupsOrder: [GroupingType] = []
        forEach { element in
            let key = key(element)
            if case nil = groups[key]?.append(element) {
                groups[key] = [element]
                groupsOrder.append(key)
            }
        }
        return groupsOrder.map { groups[$0]! }
    }
}
