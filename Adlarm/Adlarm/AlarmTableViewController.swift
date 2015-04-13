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

class AlarmTableViewController: UITableViewController, UITableViewDataSource, ADInterstitialAdDelegate {
    
    var interAd = ADInterstitialAd()
    var interAdView: UIView = UIView()
    var closeButton = UIButton.buttonWithType(UIButtonType.System) as! UIButton
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
        
        let logo = UIImage(named: "adlarmname.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        
        
        var navColor = UIColorFromRGB(0x08ACFB)
        var textColor = UIColorFromRGB(0x006CA0)
        navigationController?.navigationBar.barTintColor = navColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:  textColor ]


        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"AlarmEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "time", ascending: true)]
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as! [NSManagedObject]?
        
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
            tableView.allowsSelection = false
            return alarmArray.count
    }
    
    override func tableView(tableView: UITableView,
        cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
            
            let cell =
            tableView.dequeueReusableCellWithIdentifier("AlarmTableViewCell")
                as! UITableViewCell
            
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm a" //format style. Browse online to get a format that fits your needs.
            //var dateString = dateFormatter.stringFromDate(alarmArray[indexPath.row].time)
            println(indexPath.row)
            var dateString = dateFormatter.stringFromDate(alarmArray[indexPath.row].valueForKey("time") as! NSDate)
 
            (cell as! AlarmTableViewCell).AlarmTimeLabel.text = dateString
            
            (cell as! AlarmTableViewCell).AlarmNameLabel.text = alarmArray[indexPath.row].valueForKey("label") as! String?

            (cell as! AlarmTableViewCell).AlarmOnOffSwitch.on = alarmArray[indexPath.row].valueForKey("repeat") as! Bool
            
            if(alarmArray[indexPath.row].valueForKey("repeat") as! Bool == false){
                cell.backgroundColor = UIColor.lightGrayColor()
            }
            else{
                cell.backgroundColor = UIColor.whiteColor()
            }
            
            
            return cell
    }
    
    @IBAction func addName(sender: AnyObject) {
        
    }
    
    @IBAction func editAlarm(sender: UIBarButtonItem) {
        //self.editing = !self.editing
        
        let cell =
        tableView.dequeueReusableCellWithIdentifier("AlarmTableViewCell")
            as! UITableViewCell

        if AlarmTableView.editing{
            AlarmTableView.setEditing(false, animated: false);
            editBarButton.style = UIBarButtonItemStyle.Plain;
            //editBarButton.title = "Edit";
            
            let visibleCells = tableView.visibleCells() as! [AlarmTableViewCell]
            //let lastView = visibleCells[visibleCells.count - 1] as AlarmTableViewCell

            for i in 0..<visibleCells.count {
                let cell = visibleCells[i]
                cell.AlarmOnOffSwitch.hidden = false
                cell.settingsButton.hidden = true

            }
            
            
        }
        else{
            AlarmTableView.setEditing(true, animated: true);
            //editBarButton.title = "Done";
            
//            let buttonBack: UIButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
//            buttonBack.frame = CGRectMake(0, 0, 40, 40)
//            buttonBack.setImage(UIImage(named:"done.png"), forState: UIControlState.Normal)
//            buttonBack.addTarget(self, action: "leftNavButtonClick:", forControlEvents: UIControlEvents.TouchUpInside)
//            
//            var leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(customView: buttonBack)
//            
//            self.navigationItem.setLeftBarButtonItem(leftBarButtonItem, animated: false)


            editBarButton.style =  UIBarButtonItemStyle.Done;
            
            let visibleCells = tableView.visibleCells() as! [AlarmTableViewCell]
            //let lastView = visibleCells[visibleCells.count - 1] as AlarmTableViewCell
            
            for i in 0..<visibleCells.count {
                let cell = visibleCells[i]
                cell.AlarmOnOffSwitch.hidden = true
                cell.settingsButton.hidden = false
            }
        }
        
        
    }
    
//    func leftNavButtonClick(sender:UIButton!)
//    {
//        self.navigationItem.setLeftBarButtonItem(editBarButton, animated: true)
//    }
    
    

    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//
//    }
//    
    

    
    

    
    // Update the data model according to edit actions delete or insert.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: (NSIndexPath!))
    {
        switch editingStyle {
            
        case .Delete:
            // remove the deleted item from the model
            deleteLocalNotification(alarmArray[indexPath.row].valueForKey("label") as! String)
            let appDel:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
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
        
//        if editingStyle == UITableViewCellEditingStyle.Delete{
//            alarmArray.removeAtIndex(indexPath.row);
//            self.editAlarm(editBarButton);
//            tableView.reloadData();
//        }
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
        self.navigationController?.navigationBarHidden = true
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
        notificationID = notification.userInfo!["id"] as! String
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
            handleSnoozeHelper(notificationID)
        }
        println("incrementing timer to " + String(secondTimer + 1))
        secondTimer++
        countdown.text = String(secondTimer)
    }
    
    func stopTiming(){
        println("stopping timer")
        timer.invalidate()
        if(secondTimer >= 10){
            handleSnoozeHelper(notificationID)
        }
    }
    
    func handleSnoozeHelper(alarmName: String){
        
        println("seting next snooze")
        alarmPlayer.stop()
        interAdView.removeFromSuperview()
        self.navigationController?.navigationBarHidden = false
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        var snoozeSound = String()
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        var localNotification = UILocalNotification()
        var id: [String: String] = ["id": notificationID as String]

        for obj in alarmArray{
            var nsmo = obj as NSManagedObject
            var name = nsmo.valueForKey("label") as! String
            if(name ==  alarmName){
                snoozeSound = nsmo.valueForKey("sound") as! String
                break
            }
        }
        
        localNotification.soundName = snoozeSound
        
        localNotification.fireDate = fixNotificationDate(NSDate(timeIntervalSinceNow: 60))
        localNotification.alertBody = "Hey, Wake Up!"
        localNotification.alertAction = "Let Me Snooze Again!"
        localNotification.userInfo = id
        
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)

    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return UIInterfaceOrientation.Portrait.rawValue
    }

}
