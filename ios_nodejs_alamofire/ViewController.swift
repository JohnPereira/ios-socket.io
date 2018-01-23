//
//  ViewController.swift
//  ios_nodejs_alamofire
//
//  Created by Makarena  Estay on 11-01-18.
//  Copyright © 2018 John. All rights reserved.
//

import UIKit
import SocketIO
import Foundation
import UserNotifications

class ViewController: UIViewController {

    //let manager = SocketManager(socketURL: URL(string: "http://192.168.1.34:3000")!, config: [.log(true), .compress])

    //var socket:SocketIOClient? = nil
    
    let socketThread = DispatchQueue(label: "socketQueue", attributes: .concurrent)
    
    @IBOutlet weak var btnAlert: UIButton!
    @IBOutlet weak var txtMessageSend: UITextField!
    @IBOutlet weak var txtMessageHistory: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("inicia");
        
        // Do any additional setup after loading the view, typically from a nib.
       
        //permitir notificaciones:
        //UNUserNotificationCenter.current().delegate = self;
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { didAllow, error in });
        
        //button:
        btnAlert.addTarget(self, action: #selector(sendMessage), for: .touchDown)
        
        //socket
        socketThread.async(execute: {
            AppDelegate.socket = AppDelegate.socketManager.defaultSocket;
            AppDelegate.socket?.on("server-response", callback: {data,_ in
                print("recibe data");
                if let responseData = data[0] as? Dictionary<String,Any> {
                    
                    let messageReceived = responseData["dato"] as? String;
                    self.txtMessageHistory.text = self.txtMessageHistory.text + messageReceived! + "\n";
                    
                    self.notificacion(message: messageReceived!);
                }
            })
            AppDelegate.socket?.connect()
        })
        
    }
    
    
    
    func notificacion(message: String){
        let content = UNMutableNotificationContent();
        content.title = "Chat";
        content.subtitle = "New Message";
        content.body = message;
        content.badge = 1;
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "timeDone", content: content, trigger: trigger);
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil);
    }
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func sendMessage() {
        print("mando data");
        let socket = AppDelegate.socketManager.defaultSocket;
        socket.emit("client-message", txtMessageSend.text!);
        self.txtMessageSend.text = "";
    }
    
}

