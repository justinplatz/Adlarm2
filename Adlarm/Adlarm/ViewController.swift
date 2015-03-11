//
//  ViewController.swift
//  Adlarm
//
//  Created by Zaveri, Rishi on 3/10/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate {
    
    //@IBOutlet weak var txtAddItem: UITextField!
    
   // @IBOutlet weak var tblShoppingList: UITableView!
    
    @IBOutlet weak var btnAction: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var OnOffSwitch: UISwitch!
    
    @IBOutlet weak var adImage: UIImageView!
    
    @IBOutlet weak var OnOffLabel: UILabel!
    
    @IBOutlet weak var ShowTime: UILabel!
    
    var alarmPlayer = AVAudioPlayer()
    
    var shoppingList: NSMutableArray!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        adImage.image =  UIImage(named:("ad-250x500"))
        adImage.hidden = true
        // Do any additional setup after loading the view, typically from a nib.
        
        //alarmPlayer.prepareToPlay()
        
        //self.tblShoppingList.delegate = self
        //self.tblShoppingList.dataSource = self
        
        //self.txtAddItem.delegate = self
        
        datePicker.hidden = true
        
        
        //loadShoppingList()
        
        setupNotificationSettings()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSnooze", name: "snoozeNotification", object: nil)
        
        btnAction.backgroundColor = UIColor.clearColor()
        btnAction.layer.cornerRadius = 5
        btnAction.layer.borderWidth = 1
        btnAction.layer.borderColor = UIColor.blackColor().CGColor
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: IBAction method implementation
    
    @IBAction func scheduleReminder(sender: AnyObject) {
        if datePicker.hidden {
            datePicker.minimumDate = NSDate(timeIntervalSinceNow: 60)
            //animateMyViews(tblShoppingList, viewToShow: datePicker)
            
            
            datePicker.hidden = false
            
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        else{
            //animateMyViews(datePicker, viewToShow: tblShoppingList)
            datePicker.hidden = true
            if(NSDate().compare(datePicker.date) != NSComparisonResult.OrderedDescending){
                scheduleLocalNotification()
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm" //format style. Browse online to get a format that fits your needs.
                var dateString = dateFormatter.stringFromDate(datePicker.date)
                
                ShowTime.text = dateString
            }
        }
        
        //txtAddItem.enabled = !txtAddItem.enabled
    }
    
    func handleSnooze(){
        println("snooze is being handled")
        
        var alarmSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("iphonesongw", ofType: "wav")!)
        println(alarmSound)
        
        var error:NSError?
        alarmPlayer = AVAudioPlayer(contentsOfURL: alarmSound, error: &error)
        
        //txtAddItem.hidden = true
        //tblShoppingList.hidden = true
        btnAction.hidden = true
        OnOffSwitch.hidden = true
        OnOffLabel.hidden = true
        adImage.hidden = false
        
        alarmPlayer.play()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("handleSnoozeHelper"), userInfo: nil, repeats: false)
        
    }
    
    func handleSnoozeHelper(){
        
        println("seting next snooze")
        alarmPlayer.stop()
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        var localNotification = UILocalNotification()
        localNotification.soundName = "iphonesong.caf"
        localNotification.fireDate = fixNotificationDate(NSDate(timeIntervalSinceNow: 60))
        localNotification.alertBody = "Hey, Wake Up!"
        localNotification.alertAction = "Let Me Snooze Again!"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        adImage.hidden = true
        //txtAddItem.hidden = false
        //tblShoppingList.hidden = false
        btnAction.hidden = false
        OnOffSwitch.hidden = false
        OnOffLabel.hidden = false
    }
    
    func setupNotificationSettings() {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if (notificationSettings.types == UIUserNotificationType.None){
            // Specify the notification types.
            var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
            
            
            // Specify the notification actions.
            /*var justInformAction = UIMutableUserNotificationAction()
            justInformAction.identifier = "justInform"
            justInformAction.title = "OK, got it"
            justInformAction.activationMode = UIUserNotificationActivationMode.Background
            justInformAction.destructive = false
            justInformAction.authenticationRequired = false*/
            
            /*var modifyListAction = UIMutableUserNotificationAction()
            modifyListAction.identifier = "editList"
            modifyListAction.title = "Edit list"
            modifyListAction.activationMode = UIUserNotificationActivationMode.Foreground
            modifyListAction.destructive = false
            modifyListAction.authenticationRequired = true*/
            
            /*var trashAction = UIMutableUserNotificationAction()
            trashAction.identifier = "trashAction"
            trashAction.title = "Delete list?"
            trashAction.activationMode = UIUserNotificationActivationMode.Background
            trashAction.destructive = true
            trashAction.authenticationRequired = true*/
            
            /*let actionsArray = NSArray(objects: modifyListAction)
            let actionsArrayMinimal = NSArray(objects: modifyListAction)*/
            
            // Specify the category related to the above actions.
            /*var shoppingListReminderCategory = UIMutableUserNotificationCategory()
            shoppingListReminderCategory.identifier = "shoppingListReminderCategory"
            shoppingListReminderCategory.setActions(actionsArray, forContext: UIUserNotificationActionContext.Default)
            shoppingListReminderCategory.setActions(actionsArrayMinimal, forContext: UIUserNotificationActionContext.Minimal)*/
            
            
            //let categoriesForSettings = NSSet(objects: shoppingListReminderCategory)
            
            
            // Register the notification settings.
            //let newNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: categoriesForSettings)
            //UIApplication.sharedApplication().registerUserNotificationSettings(newNotificationSettings)
        }
    }
    
    
    func scheduleLocalNotification() {
        var localNotification = UILocalNotification()
        localNotification.soundName = "iphonesong.caf"
        //localNotification.repeatInterval = NSCalendarUnit.CalendarUnitMinute
        localNotification.fireDate = fixNotificationDate(datePicker.date)
        localNotification.alertBody = "Hey, Wake Up!"
        localNotification.alertAction = "Snooze"
        localNotification.hasAction = true
        //localNotification.category = "shoppingListReminderCategory"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    
    func fixNotificationDate(dateToFix: NSDate) -> NSDate {
        var dateComponets: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: dateToFix)
        
        dateComponets.second = 0
        
        var fixedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponets)
        
        return fixedDate
    }
    
    
    //func handleModifyListNotification() {
        //txtAddItem.becomeFirstResponder()
    //}
    
    
    //func handleDeleteListNotification() {
        //shoppingList.removeAllObjects()
        //saveShoppingList()
        //tblShoppingList.reloadData()
    //}
    
    
    // MARK: Method implementation
    
    //func removeItemAtIndex(index: Int) {
        //shoppingList.removeObjectAtIndex(index)
        
        //tblShoppingList.reloadData()
        
        //saveShoppingList()
    //}
    
    
    
    //func saveShoppingList() {
        //let pathsArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        //let documentsDirectory = pathsArray[0] as String
        //let savePath = documentsDirectory.stringByAppendingPathComponent("shopping_list")
        //shoppingList.writeToFile(savePath, atomically: true)
    //}
    
    
    //func loadShoppingList() {
    //    let pathsArray = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
   //     let documentsDirectory = pathsArray[0] as String
   //     let shoppingListPath = documentsDirectory.stringByAppendingPathComponent("shopping_list")
        
     //   if NSFileManager.defaultManager().fileExistsAtPath(shoppingListPath){
       //     shoppingList = NSMutableArray(contentsOfFile: shoppingListPath)
         //   tblShoppingList.reloadData()
        //}
    //}
    
    
    /* func animateMyViews(viewToHide: UIView, viewToShow: UIView) {
        let animationDuration = 0.35
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            viewToHide.transform = CGAffineTransformScale(viewToHide.transform, 0.001, 0.001)
            }) { (completion) -> Void in
                
                viewToHide.hidden = true
                viewToShow.hidden = false
                
                viewToShow.transform = CGAffineTransformScale(viewToShow.transform, 0.001, 0.001)
                
                UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                    viewToShow.transform = CGAffineTransformIdentity
                })
        }
    } */
    
    
    
    
    
    
    // MARK: UITableView method implementation
    
    /* func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        
        if let list = shoppingList{
            rows = list.count
        }
        
        return rows
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("idCellItem") as UITableViewCell
        
        cell.textLabel!.text = shoppingList.objectAtIndex(indexPath.row) as NSString
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            removeItemAtIndex(indexPath.row)
        }
        
    } */
    
    
    
    // MARK: UITextFieldDelegate method implementation
    
    /* func textFieldShouldReturn(textField: UITextField) -> Bool {
        if shoppingList == nil{
            shoppingList = NSMutableArray()
        }
        shoppingList.addObject(textField.text)
        
        tblShoppingList.reloadData()
        
        txtAddItem.text = ""
        txtAddItem.resignFirstResponder()
        
        saveShoppingList()
        
        return true
    } */
    
    
    
    @IBAction func AlarmToggle(sender: AnyObject) {
        
        if(OnOffSwitch.on == false){
            OnOffLabel.text = "Alarm is Off"
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            
        }
        else{
            if(NSDate().compare(datePicker.date) != NSComparisonResult.OrderedDescending){
                scheduleLocalNotification()
            }
            OnOffLabel.text = "Alarm is On"
        }
    }
    
    
    
    
    // MARK: - Table view delegate
    /*
    func colorForIndex(index: Int) -> UIColor {
        let itemCount = shoppingList.count - 1
        let val = (CGFloat(index) / CGFloat(itemCount)) * 0.6
        return UIColor(red: 1.0, green: val, blue: 0.0, alpha: 1.0)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell,
        forRowAtIndexPath indexPath: NSIndexPath) {
            cell.backgroundColor = colorForIndex(indexPath.row)
    } */
    
    
    
}

