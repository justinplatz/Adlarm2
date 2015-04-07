//
//  AlarmTableViewController.swift
//  Adlarm
//
//  Created by Justin Platz on 3/31/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import iAd

struct alarmClass{
    var time :NSDate = NSDate()
    var label: String?
    var repeat: Bool = true
    
}

func fixNotificationDate(dateToFix: NSDate) -> NSDate {
    var dateComponets: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: dateToFix)
    
    dateComponets.second = 0
    
    var fixedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponets)
    
    return fixedDate
}

func scheduleLocalNotification(date: NSDate, uid: String) {
    var localNotification = UILocalNotification()
    localNotification.soundName = "alarm22.wav"
    localNotification.fireDate = fixNotificationDate(date)
    localNotification.repeatInterval = NSCalendarUnit.CalendarUnitDay
    localNotification.alertBody = uid
    localNotification.alertAction = "Snooze"
    localNotification.hasAction = true
    var id: [String: String] = ["id": uid as String]
    localNotification.userInfo = id
    
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
}

var alarmArray = [NSManagedObject]()

class AlarmTableViewController: UITableViewController, UITableViewDataSource, ADInterstitialAdDelegate {
    
    var interAd = ADInterstitialAd()
    var interAdView: UIView = UIView()
    var closeButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    var countdown = UILabel()
    var alarmPlayer = AVAudioPlayer()
    var secondTimer = 0
    var timer = NSTimer()
    var notificationID = String()
    
    @IBOutlet var AlarmTableView: UITableView!
    
    @IBOutlet weak var editBarButton: UIBarButtonItem!

    override init(style: UITableViewStyle) {
        super.init(style: style)
        // Custom initialization
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSnooze:", name: "snoozeNotification", object: nil)
    }

    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNotificationSettings()
        title = "Adlarm"

        //tableView.registerClass(UITableViewCell.self,forCellReuseIdentifier: "AlarmTableViewCell")
        let x = self.view.frame.size.width/4
        let y = self.view.frame.size.height/1.25
        closeButton.frame = CGRectMake(x, y, 100, 100)
        closeButton.layer.cornerRadius = 10
        closeButton.setTitle("Hold Down", forState: .Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        closeButton.backgroundColor = UIColor.whiteColor()
        closeButton.layer.borderColor = UIColor.blackColor().CGColor
        closeButton.layer.borderWidth = 1
        closeButton.addTarget(self, action: "startTiming", forControlEvents: UIControlEvents.TouchDown)
        closeButton.addTarget(self, action: "stopTiming", forControlEvents: UIControlEvents.TouchUpInside)
        
        countdown.text = String(secondTimer)
        countdown.frame = CGRectMake(self.view.frame.size.width/1.33, self.view.frame.size.height/1.25, 25, 25)
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"AlarmEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            alarmArray = results
            AlarmTableView.reloadData()
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
            dateFormatter.dateFormat = "hh:mm a" //format style. Browse online to get a format that fits your needs.
            //var dateString = dateFormatter.stringFromDate(alarmArray[indexPath.row].time)
            println(indexPath.row)
            var dateString = dateFormatter.stringFromDate(alarmArray[indexPath.row].valueForKey("time") as NSDate)
 
            (cell as AlarmTableViewCell).AlarmTimeLabel.text = dateString
            
            (cell as AlarmTableViewCell).AlarmNameLabel.text = alarmArray[indexPath.row].valueForKey("label") as String?

            (cell as AlarmTableViewCell).AlarmOnOffSwitch.on = alarmArray[indexPath.row].valueForKey("repeat") as Bool
            
            return cell
    }
    
    @IBAction func addName(sender: AnyObject) {
        
    }
    
    @IBAction func editAlarm(sender: UIBarButtonItem) {
        //self.editing = !self.editing
        
        let cell =
        tableView.dequeueReusableCellWithIdentifier("AlarmTableViewCell")
            as UITableViewCell

        if AlarmTableView.editing{
            AlarmTableView.setEditing(false, animated: false);
            editBarButton.style = UIBarButtonItemStyle.Plain;
            editBarButton.title = "Edit";
            
            let visibleCells = tableView.visibleCells() as [AlarmTableViewCell]
            //let lastView = visibleCells[visibleCells.count - 1] as AlarmTableViewCell

            for i in 0..<visibleCells.count {
                let cell = visibleCells[i]
                cell.AlarmOnOffSwitch.hidden = false
                cell.settingsButton.hidden = true

            }
            
            
        }
        else{
            AlarmTableView.setEditing(true, animated: true);
            editBarButton.title = "Done";
            editBarButton.style =  UIBarButtonItemStyle.Done;
            
            let visibleCells = tableView.visibleCells() as [AlarmTableViewCell]
            //let lastView = visibleCells[visibleCells.count - 1] as AlarmTableViewCell
            
            for i in 0..<visibleCells.count {
                let cell = visibleCells[i]
                cell.AlarmOnOffSwitch.hidden = true
                cell.settingsButton.hidden = false
            }
        }
        
        
    }
    
    

    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        
        case .Delete:
            // remove the deleted item from the model
            deleteLocalNotification(alarmArray[indexPath.row].valueForKey("label") as String)
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context:NSManagedObjectContext = appDel.managedObjectContext!
            context.deleteObject(alarmArray[indexPath.row] as NSManagedObject)
            alarmArray.removeAtIndex(indexPath.row)
            context.save(nil)
            
            //tableView.reloadData()
            // remove the deleted item from the `UITableView`
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        default:
            return
            
        }
    }
    
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        NSLog("did select and the text is \(cell?.textLabel.text)")
    }
    
    
    

    
    // Update the data model according to edit actions delete or insert.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: (NSIndexPath!))
    {
        if editingStyle == UITableViewCellEditingStyle.Delete{
            alarmArray.removeAtIndex(indexPath.row);
            self.editAlarm(editBarButton);
            tableView.reloadData();
        }
    }

    func setupNotificationSettings() {
        //let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        //if (notificationSettings.types == UIUserNotificationType.None){
        // Specify the notification types.
        println("setting notification settings")
        var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        var mySettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(mySettings)
        //}
    }
    
    //FUNCTIONS FOR ADS
    func loadAd() {
        println("load ad")
        interAd = ADInterstitialAd()
        interAd.delegate = self
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        println("ad did load")
        
        interAdView = UIView()
        interAdView.frame = self.view.bounds
        view.addSubview(interAdView)
        
        interAd.presentInView(interAdView)
        UIViewController.prepareInterstitialAds()
        
        interAdView.addSubview(closeButton)
        println(secondTimer)
        interAdView.addSubview(countdown)
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        println("failed to receive")
        println(error.localizedDescription)
        
        closeButton.removeFromSuperview()
        countdown.removeFromSuperview()
        interAdView.removeFromSuperview()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //FUNCTIONS FOR SNOOZING
    func handleSnooze(notification: NSNotification){
        println("handling snooze")
        notificationID = notification.userInfo!["id"] as String
        secondTimer = 0
        countdown.text = String(secondTimer)
        loadAd()
        
        var alarmSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("iphonesongw", ofType: "wav")!)
        
        var error:NSError?
        alarmPlayer = AVAudioPlayer(contentsOfURL: alarmSound, error: &error)
        alarmPlayer.numberOfLoops = -1

        
        alarmPlayer.play()
    }
    
    func startTiming(){
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("incrementTimer"), userInfo: nil, repeats: true)
    }
    
    func incrementTimer(){
        if(secondTimer >= 10){
            timer.invalidate()
            handleSnoozeHelper()
        }
        println("incrementing timer to " + String(secondTimer + 1))
        secondTimer++
        countdown.text = String(secondTimer)
    }
    
    func stopTiming(){
        println("stopping timer")
        timer.invalidate()
        if(secondTimer >= 10){
            handleSnoozeHelper()
        }
    }
    
    func handleSnoozeHelper(){
        
        println("seting next snooze")
        alarmPlayer.stop()
        interAdView.removeFromSuperview()
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        var localNotification = UILocalNotification()
        localNotification.soundName = "alarm22.wav"
        localNotification.fireDate = fixNotificationDate(NSDate(timeIntervalSinceNow: 60))
        localNotification.alertBody = "Hey, Wake Up!"
        localNotification.alertAction = "Let Me Snooze Again!"
        var id: [String: String] = ["id": notificationID as String]
        localNotification.userInfo = id
        
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)

    }

}
