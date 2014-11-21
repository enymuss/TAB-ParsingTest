//
//  ViewController.swift
//  TAB-Parsing
//
//  Created by Jolanta Karwowska on 17/11/2014.
//  Copyright (c) 2014 Richard Szczerba. All rights reserved.
//

import UIKit
import QuartzCore
import CoreData

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  @IBOutlet var teamMembersCollectionView: UICollectionView!
  
  //create array to hold the team members
  var allTeamMembersArray = [NSManagedObject]()
  
  func loadAndParseWebsite () {
    // function takes raw data from url, parses it and assaigns parsed values to a TeamMember instance

    let websiteURL = NSURL(string: "http://www.theappbusiness.com/our-team/")
    let websiteHTMLData = NSData(contentsOfURL: websiteURL!)
    
    let websiteParser: TFHpple = TFHpple(HTMLData: websiteHTMLData)
    
    let websiteXpathQueryString = "//div[@class = 'col col2']"
    let teamMembersNodes = websiteParser.searchWithXPathQuery(websiteXpathQueryString)
    
    for object in teamMembersNodes {
      
      var element = object as TFHppleElement
      
      saveToCoreData(element)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    loadAndParseWebsite()
    teamMembersCollectionView.reloadData()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    let managedContext = appDelegate.managedObjectContext!
    
    let fetchRequest = NSFetchRequest(entityName: "Member")
    var error: NSError?
    
    let fetchedResults = managedContext.executeFetchRequest(fetchRequest, error: &error) as [NSManagedObject]?
    
    if let results = fetchedResults {
      allTeamMembersArray = results
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return allTeamMembersArray.count;
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    
    let kCellIdentifier: String = "TeamMemberCell"
    
    var cell = teamMembersCollectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as UICollectionViewCell
    
    let teamMember = allTeamMembersArray[indexPath.row]
    
    var cellImageView = cell.viewWithTag(1) as UIImageView
    cellImageView = roundProfilePicture(cellImageView, indexPath: indexPath)
    
    var nameAndSurnameLabel = cell.viewWithTag(2) as UILabel
    nameAndSurnameLabel.text = teamMember.valueForKey("nameAndSurname") as String?
    
    var positionInCompanyLabel = cell.viewWithTag(3) as UILabel
    positionInCompanyLabel.text = teamMember.valueForKey("positionInCompany") as String?
    
    var descriptionTextView = cell.viewWithTag(4) as UITextView
    descriptionTextView.text = teamMember.valueForKey("memberDescription") as String?
    
    cell.addSubview(addBorderAroundImageView(cellImageView))
    
    return cell
  }
  
  func roundProfilePicture (imageView: UIImageView, indexPath: NSIndexPath) -> UIImageView {
    
    // load image
    let teamMember = allTeamMembersArray[indexPath.row]
    var imageData = teamMember.valueForKey("imageData") as NSData?
    imageView.image = UIImage(data: imageData!)
    
    // round the edges
    imageView.layer.cornerRadius = imageView.frame.size.width/2
    imageView.layer.masksToBounds = true
    
    return imageView
  }
  
  func addBorderAroundImageView (imageView: UIImageView) -> UIView {
    
    var orangeView = UIView(frame: CGRectMake(0, 0, 160, 160))
    orangeView.center = imageView.center
    orangeView.layer.cornerRadius = 80
    orangeView.layer.masksToBounds = true
    orangeView.layer.borderWidth = 3
    orangeView.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 0.4, 0.0, 1.0])
    
    return orangeView
  
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
    
    allTeamMembersArray.append(person)
    
  }
}

