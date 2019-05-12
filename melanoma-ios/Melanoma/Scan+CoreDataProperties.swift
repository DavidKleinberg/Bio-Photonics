//
//  Scan+CoreDataProperties.swift
//  
//
//  Created by David Kleinberg on 4/30/19.
//
//

import Foundation
import CoreData


extension Scan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scan> {
        return NSFetchRequest<Scan>(entityName: "Scan")
    }

    @NSManaged public var date: String?

}
