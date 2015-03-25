//
//  ViewController.swift
//  Adlarm
//
//  Created by Zaveri, Rishi on 3/10/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import UIKit
import AVFoundation
import iAd


class ViewController: UIViewController, UITextFieldDelegate, ADInterstitialAdDelegate{
    
    var interAd = ADInterstitialAd()
    var interAdView: UIView = UIView()
    var closeButton = UIButton.buttonWithType(UIButtonType.System) as UIButton
    var countdown = UILabel()
    
    @IBOutlet weak var btnAction: UIButton!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var OnOffSwitch: UISwitch!
    
    
    @IBOutlet weak var OnOffLabel: UILabel!
    
    @IBOutlet weak var ShowTime: UILabel!
    
    @IBAction func showAdd(sender: UIButton) {
    }
    
    var alarmPlayer = AVAudioPlayer()
    
    var shoppingList: NSMutableArray!
    
    var secondTimer = 0
    var timer = NSTimer()
    
    let mediumRectAdView = ADBannerView(adType: ADAdType.MediumRectangle) //Create banner
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        datePicker.hidden = true
        
        setupNotificationSettings()
        
        if(OnOffSwitch.on){//so next localnotification does not get set when alarm is off
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSnooze", name: "snoozeNotification", object: nil)
        }
        
        
        
        btnAction.backgroundColor = UIColor.clearColor()
        btnAction.layer.cornerRadius = 5
        btnAction.layer.borderWidth = 1
        btnAction.layer.borderColor = UIColor.blackColor().CGColor
        
        
        //Set the delegate        
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
    
    
    // MARK: IBAction method implementation
    
    @IBAction func scheduleReminder(sender: AnyObject) {
        if datePicker.hidden {
            datePicker.minimumDate = NSDate(timeIntervalSinceNow: 60)
            datePicker.hidden = false
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        else{
            datePicker.hidden = true
            if(NSDate().compare(datePicker.date) != NSComparisonResult.OrderedDescending){
                scheduleLocalNotification()
                var dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm" //format style. Browse online to get a format that fits your needs.
                var dateString = dateFormatter.stringFromDate(datePicker.date)
                
                ShowTime.text = dateString
            }
        }
    }
    
    func handleSnooze(){
        println("snooze is being handled")
        
        loadAd()
        
        var alarmSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("iphonesongw", ofType: "wav")!)
        println(alarmSound)
        
        var error:NSError?
        alarmPlayer = AVAudioPlayer(contentsOfURL: alarmSound, error: &error)
        alarmPlayer.numberOfLoops = -1
 
        btnAction.hidden = true
        OnOffSwitch.hidden = true
        OnOffLabel.hidden = true
        
        alarmPlayer.play()
        
    }
    
    func startTiming(){
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("incrementTimer"), userInfo: nil, repeats: true)
    }
    
    func incrementTimer(){
        println(secondTimer)
        if(secondTimer >= 15){
            timer.invalidate()
            handleSnoozeHelper()
        }
        secondTimer++
        countdown.text = String(secondTimer)
    }
    
    func stopTiming(){
        println(secondTimer)
        timer.invalidate()
        if(secondTimer >= 15){
            handleSnoozeHelper()
        }
    }
    
    func handleSnoozeHelper(){
        
        secondTimer = 0
        countdown.text = String(secondTimer)
        println("seting next snooze")
        alarmPlayer.stop()
        interAdView.removeFromSuperview()
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        var localNotification = UILocalNotification()
        localNotification.soundName = "iphonesong.caf"
        localNotification.fireDate = fixNotificationDate(NSDate(timeIntervalSinceNow: 60))
        localNotification.alertBody = "Hey, Wake Up!"
        localNotification.alertAction = "Let Me Snooze Again!"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        btnAction.hidden = false
        OnOffSwitch.hidden = false
        OnOffLabel.hidden = false
    }
    
    func setupNotificationSettings() {
        let notificationSettings: UIUserNotificationSettings! = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if (notificationSettings.types == UIUserNotificationType.None){
            // Specify the notification types.
            var notificationTypes: UIUserNotificationType = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        }
    }
    
    
    func scheduleLocalNotification() {
        var localNotification = UILocalNotification()
        localNotification.soundName = "iphonesong.caf"
        localNotification.fireDate = fixNotificationDate(datePicker.date)
        localNotification.alertBody = "Hey, Wake Up!"
        localNotification.alertAction = "Snooze"
        localNotification.hasAction = true
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    
    func fixNotificationDate(dateToFix: NSDate) -> NSDate {
        var dateComponets: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: dateToFix)
        
        dateComponets.second = 0
        
        var fixedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponets)
        
        return fixedDate
    }
    
    
    
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
    
    
}

