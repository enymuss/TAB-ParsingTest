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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let parsedWebsiteArray: [TFHppleElement] = loadAndParseWebsite(NSURL(string: "http://www.theappbusiness.com/our-team/")!, "//div[@class = 'col col2']")
        for item in parsedWebsiteArray {
            var element = item as TFHppleElement
            saveToCoreData(element)
        }
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
            println(results)
            allTeamMembersArray = results
        }
        
        //teamMembersCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: (allTeamMembersArray.count-1), inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
        
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
        
        var memberCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as MemberCollectionViewCell
        
        let teamMember = allTeamMembersArray[indexPath.row]
        
        memberCell.cellImageView = roundProfilePicture(memberCell.cellImageView, indexPath: indexPath)
        memberCell.nameLabel.text = teamMember.valueForKey("nameAndSurname") as String?
        memberCell.positionLabel.text = teamMember.valueForKey("positionInCompany") as String?
        memberCell.descriptionTextView.text = teamMember.valueForKey("memberDescription") as String?
        
        memberCell.addSubview(addBorderAroundImageView(memberCell.cellImageView))
        
        return memberCell
    }
    
    func roundProfilePicture (imageView: UIImageView, indexPath: NSIndexPath) -> UIImageView {
        
        // load image
        let teamMember = allTeamMembersArray[indexPath.row]
        var imageData = teamMember.valueForKey("imageData") as NSData?
        // download image here and save it to coreData
        imageView.image = UIImage(data: imageData!)
        
        // round the edges
        imageView.layer.cornerRadius = imageView.frame.size.width/2
        imageView.layer.masksToBounds = true
        
        return imageView
    }
    
    func addBorderAroundImageView (imageView: UIImageView) -> UIView {
        
        var orangeBorder = UIView(frame: CGRectMake(0, 0, 160, 160))
        orangeBorder.center = imageView.center
        orangeBorder.layer.cornerRadius = 80
        orangeBorder.layer.masksToBounds = true
        orangeBorder.layer.borderWidth = 3
        orangeBorder.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), [1.0, 0.4, 0.0, 1.0])
        
        return orangeBorder
        
    }
    
}

