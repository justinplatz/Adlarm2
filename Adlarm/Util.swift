//
//  Util.swift
//  Adlarm
//
//  Created by Zaveri, Rishi on 4/7/15.
//  Copyright (c) 2015 Zaveri, Rishi. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import AVFoundation
import iAd

struct alarmClass{
    var time :NSDate = NSDate()
    var label: String?
    var repeat: Bool = true
    var sound: String?
    
}

func deleteLocalNotification(label: String){
    var app:UIApplication = UIApplication.sharedApplication()
    for oneEvent in app.scheduledLocalNotifications {
        var notification = oneEvent as! UILocalNotification
        let userInfoCurrent = notification.userInfo! as! [String:String]
        let uid = userInfoCurrent["id"]! as String
        if uid == label {
            //Cancelling local notification
            app.cancelLocalNotification(notification)
            break;
        }
    }
}

func fixNotificationDate(dateToFix: NSDate) -> NSDate {
    var dateComponets: NSDateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: dateToFix)
    
    dateComponets.second = 0
    
    var fixedDate: NSDate! = NSCalendar.currentCalendar().dateFromComponents(dateComponets)
    
    return fixedDate
}

func scheduleLocalNotification(date: NSDate, uid: String, sound: String) {
    var localNotification = UILocalNotification()
    localNotification.soundName = sound + ".wav"
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

var labelToEdit = String()
