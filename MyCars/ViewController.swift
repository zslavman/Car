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
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func getDataFromFile(){
        
        let fetchRequest:NSFetchRequest<Car> = Car.fetchRequest()
        // критерий получения записей устанавливается в предикате
        fetchRequest.predicate = NSPredicate(format: "mark != nil")
        
        var records = 0
        do {
            let count = try context.count(for: fetchRequest)// если кол-во полученных записей != 0, то мы уже записывали туда данные из data.plist
            records = count
            print("Данные уже есть в кордате?")
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
            car.rating = carDictionary["rating"] as! Double
            car.lastStarted = carDictionary["lastStarted"] as? NSDate
            car.timesDriven = carDictionary["timesDriven"] as! Int16
            car.myChoise = carDictionary["myChoise"] as! Bool
            
            let imageName = carDictionary["imageName"] as? String
            let image = UIImage(named: imageName!)
            
            let imageData = UIImagePNGRepresentation(image!)
            car.imageData = imageData as NSData?
            
            let colorDictionary = carDictionary["tintColor"] as? NSDictionary
            car.tintColor = getColor(colorDictionary: colorDictionary)
            
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
    
    
    
    
    
    @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
        
    }
    
    @IBAction func startEnginePressed(_ sender: UIButton) {
        
    }
    
    @IBAction func rateItPressed(_ sender: UIButton) {
        
    }
}























