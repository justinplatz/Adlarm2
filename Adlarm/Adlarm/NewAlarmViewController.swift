//
//  NewAlarmViewController.swift
//  Adlarm
//
//  Created by Justin Platz on 3/31/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import UIKit
import CoreData

class NewAlarmViewController: UIViewController {
    
    @IBOutlet weak var newAlarmDatePicker: UIDatePicker!
    
    @IBOutlet weak var newAlarmLabelTextField: UITextField!
    

    
    func saveName(alarmObject: alarmClass) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entityForName("AlarmEntity",
            inManagedObjectContext:
            managedContext)
        
        let alarm = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //3
        alarm.setValue(alarmObject.time, forKey: "time")
        alarm.setValue(alarmObject.label, forKey: "label")
        alarm.setValue(alarmObject.repeat, forKey: "repeat")
        
        
        //4
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        //5
        alarmArray.append(alarm)
    }
    
    
    @IBAction func addNewAlarm(sender: AnyObject) {
        var textField = newAlarmLabelTextField.text
        var date = newAlarmDatePicker.date
        
        var newAlarm = alarmClass(time: date, label: textField, repeat: true)
        println(newAlarm.time)
        
        //AlarmTableViewCell.AlarmTimeLabel.text = newAlarm.time as String
        
        self.saveName(newAlarm)
        
        if date.timeIntervalSinceNow.isSignMinus{
            //If the date added is < currentdate then add 24 hours to the date
            date = date.dateByAddingTimeInterval(86400)
        }

        scheduleLocalNotification(date, textField as String)
        
        //AlarmTableViewController.AlarmTableView.reloadData()
        self.navigationController?.popToRootViewControllerAnimated(true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let currentDate = NSDate()
        //newAlarmDatePicker.minimumDate = currentDate
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
