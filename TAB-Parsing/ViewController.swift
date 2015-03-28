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
        let teamMember = allTeamMembersArray[indexPath.row]
        
        var memberCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellIdentifier, forIndexPath: indexPath) as MemberCollectionViewCell
        
        let memberImageURLString = teamMember.valueForKey(CoreDataAttributes.imageURLString) as String
        let memberImageURL = NSURL(string: memberImageURLString) as NSURL?

        if((teamMember.valueForKey(CoreDataAttributes.imageData)) != nil) {
            let imageData = teamMember.valueForKey(CoreDataAttributes.imageData) as NSData
            memberCell.cellImageView.image = UIImage(data: imageData)
            
        } else {
            memberCell.cellImageView.image = UIImage(named: "Image Buffer.jpeg")
            
            // download the image asynchronously and save
            downloadImageWithURL(memberImageURL!, completion: { (succeeded: Bool, data: NSData) -> Void in
                if (succeeded) {
                    memberCell.cellImageView.image = UIImage(data: data)
                    self.allTeamMembersArray[indexPath.row].setValue(data, forKey: CoreDataAttributes.imageData)
                    
                } else {
                    println("Error")
                }
            })
        }
        
        memberCell.nameLabel.text = teamMember.valueForKey(CoreDataAttributes.nameAndSurname) as String?
        memberCell.positionLabel.text = teamMember.valueForKey(CoreDataAttributes.positionInCompany) as String?
        memberCell.descriptionTextView.text = teamMember.valueForKey(CoreDataAttributes.memberDescription) as String?
        memberCell.cellImageView = roundImageView(memberCell.cellImageView)
        
        memberCell.addSubview(addBorderAroundImageView(memberCell.cellImageView))
        
        return memberCell
    }
    
    func downloadImageWithURL (url: NSURL, completion: ((Bool, NSData) -> Void)?) {
        var myRequest = NSMutableURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(myRequest, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError?) -> Void in
            if ((error) == nil) {
                completion!(true, data!)
            } else {
                completion!(false, data!)
            }
        }
    }
    
    func roundImageView (imageView: UIImageView) -> UIImageView {
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

