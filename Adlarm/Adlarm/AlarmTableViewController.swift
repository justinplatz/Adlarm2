//
//  AlarmTableViewController.swift
//  Adlarm
//
//  Created by Justin Platz on 3/31/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import UIKit
import CoreData

struct alarmClass{
    var time :NSDate = NSDate()
    var label: String?
    var repeat: Bool = true
    
}




var alarmArray = [NSManagedObject]()

class AlarmTableViewController: UITableViewController, UITableViewDataSource {
    
    @IBOutlet var AlarmTableView: UITableView!
    
    
    
    
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Adlarm"
        
        //tableView.registerClass(UITableViewCell.self,forCellReuseIdentifier: "AlarmTableViewCell")
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"AlarmEntity")
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            alarmArray = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return alarmArray.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("AlarmTableViewCell")
                as UITableViewCell
            
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm" //format style. Browse online to get a format that fits your needs.
            //var dateString = dateFormatter.stringFromDate(alarmArray[indexPath.row].time)
            var dateString = dateFormatter.stringFromDate(alarmArray[indexPath.row].valueForKey("time") as NSDate)

            (cell as AlarmTableViewCell).AlarmTimeLabel.text = dateString
            
            (cell as AlarmTableViewCell).AlarmNameLabel.text = alarmArray[indexPath.row].valueForKey("label") as String?
            
            return cell
    }
    
    @IBAction func addName(sender: AnyObject) {
        
    }
    
    
    

    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("AlarmTableViewCell") as? UITableViewCell

      
    }
    

}
