//
//  HWEntry+CoreDataProperties.swift
//  Tracker
//
//  Created by Harshil Patel on 5/4/19.
//  Copyright © 2019 Harshil Patel. All rights reserved.
//
//

import Foundation
import CoreData


extension HWEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HWEntry> {
        return NSFetchRequest<HWEntry>(entityName: "HWEntry")
    }

    @NSManaged public var taskName: String?
    @NSManaged public var dueDate: String?
    @NSManaged public var isDone: Bool

}
