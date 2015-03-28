//
//  WebsiteParserAndStorer.swift
//  TAB-Parsing
//
//  Created by Richard Szczerba on 11/03/15.
//  Copyright (c) 2015 Richard Szczerba. All rights reserved.
//

struct CoreDataAttributes {
    static let nameAndSurname = "nameAndSurname"
    static let positionInCompany = "positionInCompany"
    static let memberDescription = "memberDescription"
    static let imageURLString = "imageURLString"
    static let imageData = "imageData"
}

import UIKit
import CoreData

func loadAndParseWebsite(url: NSURL, queryString: String) -> [TFHppleElement] {
    // function takes raw data from url, parses it and assaigns parsed values to a TeamMember instance
    
    let websiteURL = url
    let websiteHTMLData = NSData(contentsOfURL: websiteURL)
    
    let websiteParser: TFHpple = TFHpple(HTMLData: websiteHTMLData)
    
    let websiteXpathQueryString = queryString
    let websiteParsed = websiteParser.searchWithXPathQuery(websiteXpathQueryString) as [TFHppleElement]
    return websiteParsed

}

func saveToCoreData (object: TFHppleElement) {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedContext = appDelegate.managedObjectContext!
    
    let entity = NSEntityDescription.entityForName("Member", inManagedObjectContext: managedContext)
    let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    
    let imageURLString = object.children[0].firstChild!.objectForKey("src") as String
    person.setValue(imageURLString, forKey: CoreDataAttributes.imageURLString)
    
    
    let nameAndSurname = object.children[1].firstChild!.content
    person.setValue(nameAndSurname, forKey: CoreDataAttributes.nameAndSurname)
    
    let positionInCompany = object.children[2].firstChild!.content
    person.setValue(positionInCompany, forKey: CoreDataAttributes.positionInCompany)
    
    let memberDescription = object.children[3].firstChild!.content
    person.setValue(memberDescription, forKey: CoreDataAttributes.memberDescription)
    
    var error: NSError?
    if !managedContext.save(&error) {
        println("Could not save \(error), \(error?.userInfo)")
    }
    
    
}

