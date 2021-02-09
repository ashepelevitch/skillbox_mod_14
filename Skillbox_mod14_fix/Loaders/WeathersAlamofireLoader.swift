//
//  WeathersAlamofireLoader.swift
//  Skillbox_mod14_fix
//
//  Created by Александр Шепелевич on 01.02.2021.
//

import Foundation
import Alamofire
import SVProgressHUD

/**
 Класс загрузки данных с удаленного сервера с  помощью Alamofire
 */
class WeathersAlamofireLoader {
    /**
     Создадим замыкание загрузки данных о погоде и преобразовании в Json с использованием Alamofire
     @param urlStr Адрес для запроса
     @param completion
     */
    func loadWeathers(urlStr: String, completion: @escaping (NSDictionary) -> Void) {
        SVProgressHUD.setBackgroundColor(UIColor(white: 1.0, alpha: 0.0))
        SVProgressHUD.show()
        // получим данные с помощью Alamofire и вернем Json
        AF.request(urlStr).responseJSON { response in
            if let objects = response.value,
                let jsonDict = objects as? NSDictionary {
                    completion(jsonDict)
                    SVProgressHUD.dismiss()
                }

        }
    }
}
