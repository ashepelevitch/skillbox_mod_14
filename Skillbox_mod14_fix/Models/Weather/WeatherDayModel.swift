//
//  WeatherDayModel.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 01.02.2021.
//

import RealmSwift

// Модель данных для хранения текущей погоды
class WeatherDayModel: Object {
    // Singleton
    static let shared = WeatherDayModel()
    
    // Поля модели данных
    @objc dynamic var city = "идет загрузка"
    @objc dynamic var temp = "0"
    @objc dynamic var feelsLike = ""
    
    @objc dynamic var descript = ""
    @objc dynamic var iconURL = ""
    @objc dynamic var windSpeed = ""
    @objc dynamic var humidity = ""
    
    @objc dynamic var date = NSDate()
    
    /* Функция обновления данных
     Так как всегда нужна будет только одна запись о текущем состоянии погодамы,
     не будем плодить множество записей, а будем всегда использовать одну
     */
    func update(data: NSDictionary){
        
        guard let city = data["name"] as? String,
              let main = data["main"] as? NSDictionary,
                let temp = main["temp"] as? Double,
                let feelsLike = main["feels_like"] as? Double,
                let humidity = main["humidity"] as? Int,
                let weather = data["weather"] as? [NSDictionary] else { return }

        guard let descript = weather[0]["description"] as? String,
                let iconURL = weather[0]["icon"] as? String,
              let wind = data["wind"] as? NSDictionary,
                let windSpeed = wind["speed"] as? Int else { return }
        
        let realmInstance = try! Realm()
        
        do {
            try realmInstance.write {
                self.city = city
                self.temp = String(format: "%.0f", temp) + "℃"
                self.feelsLike = "ощущяется: " + String(format: "%.0f", feelsLike) + "℃"

                self.descript = descript
                self.iconURL = "https://openweathermap.org/img/wn/"+iconURL+"@2x.png"
                self.windSpeed = "Ветер: " + String(windSpeed) + "м/с"
                self.humidity = "Влажность: " + String(humidity) + "%"
                self.date = NSDate()
            }

        } catch let error as NSError {
            print(error)
        }
    }
}
