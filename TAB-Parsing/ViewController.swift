//
//  ViewController.swift
//  TAB-Parsing
//
//  Created by Jolanta Karwowska on 17/11/2014.
//  Copyright (c) 2014 Richard Szczerba. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  
  @IBOutlet var teamMembersCollectionView: UICollectionView!
  var allTeamMembersArray = [TeamMember]()
  
  func loadAndParseWebsite () {
    
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
      teamMember.profileImageURL = element.children[0].firstChild!.objectForKey("src")
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
    
    cell.backgroundColor = UIColor.whiteColor()
    
    return cell
  }
  
}

