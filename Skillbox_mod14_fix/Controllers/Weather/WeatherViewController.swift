//
//  WeatherViewController.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 01.02.2021.
//

import UIKit

// установим основные конфигурационные константы
let apiKey = "3a57d58eb787613e6e86839433da7faa"
let config = [
    "city": "Moscow",
    "code": "ru",
    "lang": "ru",
    "units": "metric"
]
// установим шаблоны ссылок для текущей погоды и для погоды на 5 дней через каждый 3 часа
let urls = [
    "current": "https://api.openweathermap.org/data/2.5/weather?q=%@,%@&lang=%@&units=%@&appid=%@",
    "forecast": "https://api.openweathermap.org/data/2.5/forecast?q=%@,%@&lang=%@&units=%@&appid=%@"
]

// Опишем структуру группы для вывода данных в таблице по дням
struct WeatherGroups {
    var date: String
    var weathers: [WeatherThreeHoursModel]
}


class WeatherViewController: UIViewController {

    // основные элементы для вывода текущей погоды
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var descriptLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    // таблица для вывода погоды по часам и дням
    @IBOutlet weak var tableView: UITableView!
    
    // объявим объект погоды на текущий день
    var weatherDay: WeatherDayModel?
    
    // объявим словарь для данных о погоде по часам и дням
    var weatherThreeHoursList: [WeatherGroups] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Загрузим данные из базы, если они есть
        loadUsersData()
        
        // Выведем текущую температуру
        showToday()
        // ... и сгруппированную по дням температуру
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Теперь нам необходимо загрузить обновленные данные, записать их в базу и вывести на экран
        
        // получим URL запроса для текущей погоды исходя из шаблона и параметров
        let currentUrl = String.init(format: urls["current"]!, config["city"]!, config["code"]!, config["lang"]!, config["units"]!, apiKey)
        
        // запросим данные о текущей погоде с помощью загрузчика на основе Alamofire
        WeathersAlamofireLoader().loadWeathers(urlStr: currentUrl) { jsonDict in
            // вернемся в main поток...
            DispatchQueue.main.async {
                // запишем полученные данные в базу - будем использовать одну запись, не будем плодить множество
                self.weatherDay!.update(data: jsonDict)
                // отобразим новые данные по текущей погоде
                self.showToday()
            }
            
        }
        
        // получим URL запроса для погоды по часам и дням исходя из шаблона и параметров
        let forecastUrl = String.init(format: urls["forecast"]!, config["city"]!, config["code"]!, config["lang"]!, config["units"]!, apiKey)
        
        // запросим данные о текущей погоде с помощью загрузчика на основе Alamofire
        WeathersAlamofireLoader().loadWeathers(urlStr: forecastUrl) { jsonDict in
            // вернемся в main поток...
            DispatchQueue.main.async {
                if let list = jsonDict["list"] as? [NSDictionary] {
                    // очистим таблицу от старых записей
                    RealmHandler.shared.deleteAll([WeatherThreeHoursModel.self])
                    
                    // заполним таблицу полученными данными о погоде
                    var weatherNewList: [WeatherThreeHoursModel] = []
                    for data in list {
                        if let item = WeatherThreeHoursModel(data: data) {
                            weatherNewList.append(item)
                        }
                    }
                    // полченный словарь данных надо обработать для группирования по дате
                    WeatherParse().parseToThreeHours(weatherList: weatherNewList) { weatherThreeHoursList in
                        // полученные данные поместим в словарь для последущего вывода в таблице
                        self.weatherThreeHoursList = weatherThreeHoursList
                        // обновим вывод таблицы
                        self.tableView.reloadData()
                    }
                }
                
            }
        }
    }
    
    // загружаем данные из Realm в наш data source
    // Будем использовать RealmHandler, отвечающий за работу с Realm
    func loadUsersData() {
        // Если запись о текущей погоде уже есть...
        if let currentWeatherDay = RealmHandler.shared.fetchAll(ofType: WeatherDayModel.self, sorted: [SortedParams(field: "date", asc: true)]).first {
            // ...просто запишем ее в необходимую переменную
            self.weatherDay = currentWeatherDay
        } else {
            // Если записи о текущей погоде еще нет (первый запуск приложения)
            // Будем использовать Singleton
            self.weatherDay = WeatherDayModel.shared
            
            // И пустую модель запишем в базу используя RealmHandler
            RealmHandler.shared.saveModel(self.weatherDay!, data: nil)
        }
        
        // Попытаемся получить данные о погодо по часам и дням из базы
        // Запросим все записи из табдицы и установим сортировку по дате и времени прогноза
        let weatherList = RealmHandler.shared.fetchAll(ofType: WeatherThreeHoursModel.self, sorted: [SortedParams(field: "date", asc: true), SortedParams(field: "time", asc: true)])
        
        // Полученные из базы данных записи необходимо сгруппировать перед выводом в табдицу
        WeatherParse().parseToThreeHours(weatherList: weatherList) { weatherThreeHoursList in
            // плученные данные поместим в словарь для последущего вывода в таблице
            self.weatherThreeHoursList = weatherThreeHoursList
            // обновим вывод таблицы
            self.tableView.reloadData()
        }
        
    }

    // Отобразим данные о текущей погоде из модели
    func showToday() {
        if let wd = self.weatherDay {
            self.cityLabel.text = wd.city
            self.tempLabel.text = wd.temp
            self.feelsLikeLabel.text = wd.feelsLike
            self.iconImage.downloaded(from: wd.iconURL)
            self.descriptLabel.text = wd.descript
            self.windSpeedLabel.text = wd.windSpeed
            self.humidityLabel.text = wd.humidity
        }
    }
}


/**
 Расширим класс UIImageView для загрузки изображений по URL
 */
extension UIImageView {
    func downloaded(from url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
    func downloaded(from link: String) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url)
    }
}


// расширим наш контроллер для формирования таблицы с данными о погоде по часам и дням
extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {

    // функция, возвращающая кол-во разделов в таблице
    func numberOfSections(in tableView: UITableView) -> Int {
        return weatherThreeHoursList.count
    }
    
    // расширим функцию, возвращающую кол-во строк в разделе таблицы
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherThreeHoursList[section].weathers.count
    }
    
    // функция запроса объекта представления для отображения заголовка раздела
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherGroupAlamofireCell") as! WeatherGroupAlamofireCell
        
        cell.dateLabel.text = weatherThreeHoursList[section].date
        return cell
    }
    
    // в ячейке таблицы отобразим время текущего дня (раздела), температуру, иконку и краткое описание о погоде в этот час
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherAlamofireCell") as! WeatherAlamofireCell

        let model = weatherThreeHoursList[indexPath.section].weathers[indexPath.row]

        cell.timeLabel.text = model.time
        cell.tempLabel.text = model.temp
        cell.iconImage.downloaded(from: model.iconURL)
        cell.descriptLabel.text = model.descript
        return cell
    }
}
