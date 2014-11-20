//
//  ViewController.swift
//  TAB-Parsing
//
//  Created by Jolanta Karwowska on 17/11/2014.
//  Copyright (c) 2014 Richard Szczerba. All rights reserved.
//

import UIKit
import QuartzCore

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  @IBOutlet var teamMembersCollectionView: UICollectionView!
  
  //create array to hold the team members
  var allTeamMembersArray = [TeamMember]()
  
  func loadAndParseWebsite () {
    // function takes raw data from url, parses it and assaigns parsed values to a TeamMember instance
    
    let websiteURL = NSURL(string: "http://www.theappbusiness.com/our-team/")
    let websiteHTMLData = NSData(contentsOfURL: websiteURL!)
    
    let websiteParser: TFHpple = TFHpple(HTMLData: websiteHTMLData)
    
    let websiteXpathQueryString = "//div[@class = 'col col2']"
    let teamMembersNodes = websiteParser.searchWithXPathQuery(websiteXpathQueryString)
    
    var teamMembersArray = [TeamMember]()
    
    for object in teamMembersNodes {
      var element = object as TFHppleElement
      
      // init teamMember and asign properties
      var teamMember = TeamMember()
      teamMember.profileImageURL = NSURL(string: element.children[0].firstChild!.objectForKey("src"))!
      teamMember.nameAndSurname = element.children[1].firstChild!.content
      teamMember.positionInCompany = element.children[2].firstChild!.content
      teamMember.description = element.children[3].firstChild!.content
      
      teamMembersArray.append(teamMember)
    }
    
    allTeamMembersArray  = teamMembersArray
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    loadAndParseWebsite()
    teamMembersCollectionView.reloadData()
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
    
    var cellImageView = cell.viewWithTag(1) as UIImageView
    cellImageView = addBoardedProfilePicture(cellImageView, indexPath: indexPath)
    
    var nameAndSurnameLabel = cell.viewWithTag(2) as UILabel
    nameAndSurnameLabel.text = allTeamMembersArray[indexPath.row].nameAndSurname
    
    var positionInCompanyLabel = cell.viewWithTag(3) as UILabel
    positionInCompanyLabel.text = allTeamMembersArray[indexPath.row].positionInCompany
    
    var descriptionTextView = cell.viewWithTag(4) as UITextView
    descriptionTextView.text = allTeamMembersArray[indexPath.row].description
    
    return cell
  }
  
  func addBoardedProfilePicture(imageView: UIImageView, indexPath: NSIndexPath) -> UIImageView {
    
    // load image
    var imageData = NSData(contentsOfURL: allTeamMembersArray[indexPath.row].profileImageURL)
    imageView.image = UIImage(data: imageData!)
    
    // round the edges and add boarder via CALayer
    imageView.layer.cornerRadius = imageView.frame.size.width/2
    imageView.layer.masksToBounds = true
    imageView.layer.borderWidth = 2
    imageView.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 0.4, 0.0, 1.0])
    
    
    return imageView
  }
  
}

