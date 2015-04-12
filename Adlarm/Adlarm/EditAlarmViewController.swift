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
    
    @IBOutlet weak var EditNavBar: UINavigationBar!
    
    let pickerData = ["alarm22.wav","salmon.wav","fudale.wav"]
    
    var selectedSound: String?
    
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
        println(selectedSound)
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
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
                selectedSound = nsmo.valueForKey("sound") as String!
                var rowToGet = find(pickerData, selectedSound!)!
                editSoundPicker.selectRow(rowToGet, inComponent: 0, animated: true)
                break
            }
        }
        
        
                
        var navColor = UIColorFromRGB(0x08ACFB)
        var textColor = UIColorFromRGB(0x006CA0)
        EditNavBar.barTintColor = navColor
        EditNavBar.titleTextAttributes = [NSForegroundColorAttributeName:  textColor ]
        
        

        
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
    
    
    
    /*func saveName(alarmObject: alarmClass) {
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
        alarm.setValue(alarmObject.sound, forKey: "sound")
        
        //4
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        //5
        alarmArray.append(alarm)
    }*/
    
    @IBAction func saveEditAlarm(sender: AnyObject) {
        
        var textField = editAlarmTextField.text
        var date = editAlarmDatePicker.date
        //var newAlarm = alarmClass(time: date, label: textField, repeat: true, sound: selectedSound)

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
                managedObject.setValue(selectedSound, forKey: "sound")
                managedContext.save(nil)
            } else {
                println("Could not fetch \(error), \(error!.userInfo)")
            }

           deleteLocalNotification(labelToEdit)

           scheduleLocalNotification(date, textField as String, selectedSound!)

           self.dismissViewControllerAnimated(true, completion: {});//This is intended to dismiss the edit sceen.


    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    
    
    

}
