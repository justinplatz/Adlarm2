//
//  NewAlarmViewController.swift
//  Adlarm
//
//  Created by Justin Platz on 3/31/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class NewAlarmViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var newAlarmDatePicker: UIDatePicker!
    
    @IBOutlet weak var newAlarmLabelTextField: UITextField!
    
    @IBOutlet weak var soundPicker: UIPickerView!
    let pickerData = ["alarm22.wav","salmon.wav","fudale.wav"]
    
    var selectedSound = "alarm22.wav"
    var alarmPlayer = AVAudioPlayer()

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
    
    
    @IBOutlet weak var testSoundButton: UIButton!
    
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
        alarm.setValue(alarmObject.sound, forKey: "sound")

        
        
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
        
        var newAlarm = alarmClass(time: date, label: textField, repeat: true, sound: selectedSound )
        println(newAlarm.time)
        
        //AlarmTableViewCell.AlarmTimeLabel.text = newAlarm.time as String
        
        self.saveName(newAlarm)
        
        if date.timeIntervalSinceNow.isSignMinus{
            //If the date added is < currentdate then add 24 hours to the date
            date = date.dateByAddingTimeInterval(86400)
        }

        scheduleLocalNotification(date, textField as String, selectedSound)
        
        //AlarmTableViewController.AlarmTableView.reloadData()
        self.navigationController?.popToRootViewControllerAnimated(true)

    }
    
    @IBAction func playAlarmSound(sender: AnyObject) {
        var alarmSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(selectedSound.stringByDeletingPathExtension, ofType: "wav")!)
        var error:NSError?
        alarmPlayer = AVAudioPlayer(contentsOfURL: alarmSound, error: &error)
        alarmPlayer.numberOfLoops = 1
        alarmPlayer.play()
        var timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("stopPlaying"), userInfo: nil, repeats: false)
    }
    
    func stopPlaying() {
        alarmPlayer.stop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        soundPicker.dataSource = self
        soundPicker.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
