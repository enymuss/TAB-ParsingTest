//
//  WebsiteParserAndStorer.swift
//  TAB-Parsing
//
//  Created by Richard Szczerba on 11/03/15.
//  Copyright (c) 2015 Richard Szczerba. All rights reserved.
//

import UIKit
import CoreData

func loadAndParseWebsite() -> [TFHppleElement] {
    // function takes raw data from url, parses it and assaigns parsed values to a TeamMember instance
    
    let websiteURL = NSURL(string: "http://www.theappbusiness.com/our-team/")
    let websiteHTMLData = NSData(contentsOfURL: websiteURL!)
    
    let websiteParser: TFHpple = TFHpple(HTMLData: websiteHTMLData)
    
    let websiteXpathQueryString = "//div[@class = 'col col2']"
    let websiteParsed = websiteParser.searchWithXPathQuery(websiteXpathQueryString) as [TFHppleElement]
    return websiteParsed

}

func saveToCoreData (object: TFHppleElement) {
    
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedContext = appDelegate.managedObjectContext!
    
    let entity = NSEntityDescription.entityForName("Member", inManagedObjectContext: managedContext)
    let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
    
    let profileImageString = object.children[0].firstChild!.objectForKey("src")
    let imageURL = NSURL(string: profileImageString)
    let profileImageData = NSData(contentsOfURL: imageURL!)
    person.setValue(profileImageData, forKey: "imageData")
    
    let nameAndSurname = object.children[1].firstChild!.content
    person.setValue(nameAndSurname, forKey: "nameAndSurname")
    
    let positionInCompany = object.children[2].firstChild!.content
    person.setValue(positionInCompany, forKey: "positionInCompany")
    
    let memberDescription = object.children[3].firstChild!.content
    person.setValue(memberDescription, forKey: "memberDescription")
    
    var error: NSError?
    if !managedContext.save(&error) {
        println("Could not save \(error), \(error?.userInfo)")
    }
    
    //allTeamMembersArray.append(person)
    
}

