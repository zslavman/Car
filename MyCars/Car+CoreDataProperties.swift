//
//  Car+CoreDataProperties.swift
//  MyCars
//
//  Created by Admin on 19.03.18.
//  Copyright © 2018 HomeMade. All rights reserved.
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car");
    }

    @NSManaged public var imageData: NSData?
    @NSManaged public var lastStarted: NSDate?
    @NSManaged public var mark: String?
    @NSManaged public var model: String?
    @NSManaged public var myChoise: Bool
    @NSManaged public var rating: Double
    @NSManaged public var timesDriven: Int16
    @NSManaged public var tintColor: NSObject?

}
