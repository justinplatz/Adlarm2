//
//  EditAlarmViewController.swift
//  Adlarm
//
//  Created by Justin Platz on 4/2/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import UIKit
import CoreData


class EditAlarmViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var editAlarmDatePicker: UIDatePicker!
    
    @IBOutlet weak var editAlarmTextField: UITextField!
    
    @IBOutlet weak var editAlarmSaveButton: UIBarButtonItem!
    
    @IBOutlet weak var editSoundPicker: UIPickerView!
    
    
    let pickerData = ["alarm22.wav","salmon.wav","fudale.wav"]
    
    //MARK: - Delegates and data sources
    //MARK: Data Sources
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSound = pickerData[row]
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        editSoundPicker.dataSource = self
        editSoundPicker.delegate = self
        
        
        for obj in alarmArray{
            var nsmo = obj as NSManagedObject
            var name = nsmo.valueForKey("label") as String
            if(name == labelToEdit){
                editAlarmDatePicker.date = nsmo.valueForKey("time") as NSDate
                editAlarmTextField.text = nsmo.valueForKey("label") as String
                break
            }
        }
        
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
        
        var newAlarm = alarmClass(time: date, label: textField, repeat: true, sound: selectedSound)

            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName:"AlarmEntity")
            fetchRequest.predicate = NSPredicate(format: "label = %@", labelToEdit)
            var error: NSError?
            let fetchedResults =
            managedContext.executeFetchRequest(fetchRequest,
                error: &error) as [NSManagedObject]?
            if let results = fetchedResults {
                var managedObject = results[0]
                managedObject.setValue(date, forKey: "time")
                managedObject.setValue(textField, forKey: "label")

                managedContext.save(nil)
            } else {
                println("Could not fetch \(error), \(error!.userInfo)")
            }

           deleteLocalNotification(labelToEdit)

           scheduleLocalNotification(date, textField as String, selectedSound)

           self.dismissViewControllerAnimated(true, completion: {});//This is intended to dismiss the edit sceen.


    }
    
    
    

}
