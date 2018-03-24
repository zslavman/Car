//
//  ViewController.swift
//  MyCars
//
//  Created by zslavman on 19/03/17.
//   Copyright © 2018 HomeMade. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class ViewController: UIViewController {
    
    
    lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //    var context = NSManagedObjectContext
    var selectedCar:Car!
    
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromFile()
        
        let fetchRequest:NSFetchRequest<Car> = Car.fetchRequest()
        let carName = segmentedControl.titleForSegment(at: 0) // заглавье 1-й вкладки сегментедконтрол
        fetchRequest.predicate = NSPredicate(format: "mark == %@", carName!) // "mark == %@" - сюда можно подставить информацию
        do {
           let results = try context.fetch(fetchRequest)
            selectedCar = results[0]
            refreshAllScreenData(selectedCar: selectedCar)
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    // обновление контента вкладки
    func refreshAllScreenData(selectedCar: Car){
        
        carImageView.image = UIImage(data: selectedCar.imageData as! Data)
        markLabel.text = selectedCar.mark
        modelLabel.text = selectedCar.model
        myChoiceImageView.isHidden = !(selectedCar.myChoise)
        ratingLabel.text = "\(Int(selectedCar.rating!)) / 10"
        numberOfTripsLabel.text = String(selectedCar.timesDriven)
        
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM.dd.yy \n HH:mm"
        lastTimeStartedLabel.text = dateFormater.string(from: selectedCar.lastStarted as! Date)
        
        segmentedControl.tintColor = selectedCar.tintColor as! UIColor!
        
    }
    
    
    
    

    
    /// получение данных из кордата
    func getDataFromFile(){
        
        let fetchRequest:NSFetchRequest<Car> = Car.fetchRequest()
        // критерий получения записей устанавливается в предикате
        fetchRequest.predicate = NSPredicate(format: "mark != nil")
        
        var records = 0
        do {
            let count = try context.count(for: fetchRequest)// если кол-во полученных записей != 0, то мы уже записывали туда данные из data.plist
            records = count
        }
        catch {
            print(error.localizedDescription)
        }
        
        // если это первый запуск и еще нет данных в кордате
        guard records == 0 else { return } // если records != 0 { return }
        let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist") // Bundle - это сам проект
        // т.к. data.plist - это массив словарей
        let dataArray = NSArray(contentsOfFile: pathToFile!)!
        
        for dictionary in dataArray{
            let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)
            let car = NSManagedObject(entity: entity!, insertInto: context) as! Car
            
            
            let carDictionary = dictionary as! NSDictionary
            // нужно кастить до тех типов которые нам нужны (тех, которые закладывались)
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.rating = carDictionary["rating"] as! Double as NSNumber?
            car.lastStarted = carDictionary["lastStarted"] as? NSDate
            car.timesDriven = carDictionary["timesDriven"] as! Int16
            car.myChoise = carDictionary["myChoice"] as! Bool
            
            let imageName = carDictionary["imageName"] as? String
            let image = UIImage(named: imageName!)
            
            let imageData = UIImagePNGRepresentation(image!)
            car.imageData = imageData as NSData?
            
            let colorDictionary = carDictionary["tintColor"] as? NSDictionary
            car.tintColor = getColor(colorDictionary: colorDictionary!)
            
        }
        
    }
    
    
    
    // соединяет словарь с ключами R G B в цвет
    func getColor(colorDictionary:NSDictionary) -> UIColor{
        
        let red = colorDictionary["red"] as! NSNumber
        let green = colorDictionary["green"] as! NSNumber
        let blue = colorDictionary["blue"] as! NSNumber
        
        // деление на 255 т.к. значение цвета должно быть от 0 - 1
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
        
    }
    
    
    
    
    
    @IBAction func onSegmentedCtrlClick(_ sender: UISegmentedControl) {
        
        let carName = sender.titleForSegment(at: sender.selectedSegmentIndex)
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "mark == %@", carName!)
        
//      print("fetchRequest.predicate = \(fetchRequest.predicate!)  mark = \(mark!)") //fetchRequest.predicate = mark == "Mercedes"  mark = Mercedes
        
        do{
            let results = try context.fetch(fetchRequest)
            selectedCar = results[0]
            refreshAllScreenData(selectedCar: selectedCar)
        }
        catch{
           print(error.localizedDescription)
        }
        
        
    }
    
    
    
    // нажали Завести
    @IBAction func onStartEngineClick(_ sender: UIButton) {
        
        let timesDriven = selectedCar.timesDriven
        selectedCar.timesDriven = Int16(NSNumber(value: timesDriven + 1))
        
        selectedCar.lastStarted = NSDate() // получаем текущую дату
        
        // сохраняем объект
        do {
            try context.save()
            refreshAllScreenData(selectedCar: selectedCar) // обновляем экран
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    // нажали на иконку Медаль
    @IBAction func onRewardClick(_ sender: UIButton) {
        
        
        // Т.к. отметка "Лучший выбор" может быть только у одной машины, получим все записи из кордата, чтоб найти отмеченную как "Лучший выбор" и снимем эту отметку
        var instances: [Car] = []
        let fetch_Raquest: NSFetchRequest<Car> = Car.fetchRequest()

        do { instances = try context.fetch(fetch_Raquest) }
        catch { print("Не удалось получить данные ") }
        
        for item in instances {
            if item.myChoise{
                item.myChoise = false
                break
            }
        }
        
        
        // ставим выбор если он был и сохраняем данные
        myChoiceImageView.isHidden = selectedCar.myChoise
        selectedCar.myChoise = Bool(!myChoiceImageView.isHidden)
        
        // сохраняем объект
        do {
            try context.save()
            refreshAllScreenData(selectedCar: selectedCar) // обновляем экран
        }
        catch {
            print(error.localizedDescription)
        }
        
    }
    
    
    
    
    
    // нажали Рейтинг
    @IBAction func onRateClick(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: "Установка рейтинга", message: "Установите рейтинг для этой тачки (от 0 - 10)", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .default) {
            (action) in
            let textField = alertController.textFields?[0]
            self.update(rating: textField!.text!)
        }
        
        let cancel = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        
        alertController.addTextField {
            textField in
            textField.keyboardType = .numberPad // определяем тип клавиатуры который нам нужен
        }
        
        alertController.addAction(ok)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    
    // нажали на ОК при вводе рейтинга
    func update(rating: String){
        
        var restored = selectedCar // если будет ошибка при сохранении selectedCar повредиться, и не сможет прочитаться, потому сохраним его
        
        // т.к. для ввода рейтинга выдвигается клавиатура только с цифрами, у юзера не будет возможности ввести строку, однако, юзер может ввести пустую строку
        
        func onError(_ str:String){
            let ac = UIAlertController(title: "Недопустимое значение", message: str, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
            selectedCar = restored
        }
        
        
        if let slk = Double(rating){
            selectedCar.rating = slk as NSNumber!
            do {
                try context.save()
                refreshAllScreenData(selectedCar: selectedCar) // обновляем экран
            }
            catch {
                onError("\n Цифра \(Int(slk)) вне диапазона! 😏")
            }
        }
        else{
            if rating == ""{
                onError("\n Вы забыли ввести число 😁")
            }
            else{
               onError("\n \(rating) - не число! 😜")
            }
        }
        
        
        
        
        
    }
    
    
    
    
    
}























