//
//  ViewController.swift
//  Project21
//
//  Created by Максим Зыкин on 13.11.2023.
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }

    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    @objc func scheduleLocal() {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        let later = UNNotificationAction(identifier: "later", title: "Remind me later", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, later], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data receiver: \(customData)")
            
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                // the user swiped to unlock
                print("Default identifier")
            case "show":
                showAlert(with: "Some more info here...")
                print("Show more info...")
            case "later":
                timer = Timer(timeInterval: 86400, repeats: false) { [weak self] _ in
                    self?.scheduleLocal()
                }
                print("Will be shown the next day")
            default:
                break
            }
        }
        
        completionHandler()
    }
    
    func showAlert(with message: String?) {
        let ac = UIAlertController(title: "Notice", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }
}

