//
//  EditAlarmViewController.swift
//  Adlarm
//
//  Created by Justin Platz on 4/2/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import UIKit
import CoreData


class EditAlarmViewController: UIViewController {

    @IBOutlet weak var editAlarmDatePicker: UIDatePicker!
    
    @IBOutlet weak var editAlarmTextField: UITextField!
    
    @IBOutlet weak var editAlarmSaveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func findSuperCellOfView(view: UIView?) -> UITableViewCell? {
        if view == nil {
            return nil
        } else if let cell = view as? UITableViewCell {
            return cell
        } else {
            println(findSuperCellOfView(view?.superview))
            return findSuperCellOfView(view?.superview)
        }
        
        
    }
    
    
    
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
    
    @IBAction func saveEditAlarm(sender: AnyObject) {
        
        var textField = editAlarmTextField.text
        var date = editAlarmDatePicker.date
        
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
        self.dismissViewControllerAnimated(true, completion: {});//This is intended to dismiss the edit sceen.


    }
    
    
    

}
