//
//  AlarmTableViewCell.swift
//  Adlarm
//
//  Created by Justin Platz on 3/31/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import UIKit
import CoreData


func deleteLocalNotification(label: String){
    var app:UIApplication = UIApplication.sharedApplication()
    for oneEvent in app.scheduledLocalNotifications {
        var notification = oneEvent as UILocalNotification
        let userInfoCurrent = notification.userInfo! as [String:String]
        let uid = userInfoCurrent["id"]! as String
        if uid == label {
            //Cancelling local notification
            app.cancelLocalNotification(notification)
            break;
        }
    }
}

class AlarmTableViewCell: UITableViewCell {

    @IBOutlet weak var AlarmTimeLabel: UILabel!
    
    @IBOutlet weak var AlarmNameLabel: UILabel!
    
    @IBOutlet weak var AlarmOnOffSwitch: UISwitch!
    
    @IBOutlet weak var trashButton: UIButton!
    
    @IBOutlet weak var settingsButton: UIButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func AlarmToggle(sender: AnyObject) {
        
        println("toggling")
        if(AlarmOnOffSwitch.on == false){
            println("disabling alarm")
            deleteLocalNotification(AlarmNameLabel.text!)
        }
        else{
            var date = NSDate()
            for obj in alarmArray{
                var nsmo = obj as NSManagedObject
                var name = nsmo.valueForKey("label") as String
                if(name == AlarmNameLabel.text){
                    date = nsmo.valueForKey("time") as NSDate
                    break
                }
            }
            if(NSDate().compare(date) != NSComparisonResult.OrderedDescending){
                println("enabling alarm")
                scheduleLocalNotification(date, AlarmNameLabel.text!)
            }
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"AlarmEntity")
        fetchRequest.predicate = NSPredicate(format: "label = %@", AlarmNameLabel.text!)
        var error: NSError?
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            var managedObject = results[0]
            managedObject.setValue(AlarmOnOffSwitch.on, forKey: "repeat")
            managedContext.save(nil)
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
}
