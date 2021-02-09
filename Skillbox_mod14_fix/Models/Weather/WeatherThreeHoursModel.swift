//
//  WeatherThreeHoursModel.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 01.02.2021.
//

import RealmSwift

// Модель данных для хранения данных о погоде по дням и часам
class WeatherThreeHoursModel: Object {

    // Поля модели данных
    @objc dynamic var date = ""
    @objc dynamic var time = ""
    @objc dynamic var temp = ""
    @objc dynamic var iconURL = ""
    @objc dynamic var descript = ""
    
    override init() {
        super.init()
    }
    // Для правильного хранения данных о погоде по часам и дням, необходимо множество записей в базе
    init?(data: NSDictionary) {
        super.init()
        
        let realmInstance = try! Realm()

        var itemDate: String = ""
        var itemTime: String = ""

        if let timeResult = (data["dt"] as? Double) {
            let date = Date(timeIntervalSince1970: timeResult)
            let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                dateFormatter.timeZone = .current
            let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                timeFormatter.timeZone = .current
            itemDate = dateFormatter.string(from: date)
            itemTime = timeFormatter.string(from: date)
        }

        guard let main = data["main"] as? NSDictionary,
              let temp = main["temp"] as? Double,
              let weather = data["weather"] as? [NSDictionary],
              let descript = weather[0]["description"] as? String,
              let iconURL = weather[0]["icon"] as? String else { return }

        do {
            try realmInstance.write {
                self.date = itemDate
                self.time = itemTime
                self.temp = String(format: "%.0f", temp) + "℃"

                self.descript = descript
                self.iconURL = "https://openweathermap.org/img/wn/"+iconURL+"@2x.png"
                
                realmInstance.add(self)
            }

        } catch let error as NSError {
            print(error)
        }
    }
}
