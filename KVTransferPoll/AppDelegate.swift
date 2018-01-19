//
//  AppDelegate.swift
//  KVTransferPoll
//
//  Created by zhoupanpan on 2017/10/20.
//  Copyright © 2017年 panzhow. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,NSWindowDelegate {

    @IBOutlet weak var window: NSWindow!
    let ctrl = KVTPMainViewController.init()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        ctrl.view.frame = (window.contentView?.bounds)!
        window.delegate = self
        window.contentView?.addSubview(ctrl.view)
        
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in sender.windows{
                window.makeKeyAndOrderFront(sender)
            }
        }
        return true
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func windowDidResize(_ notification: Notification) {
        ctrl.view.frame = (window.contentView?.bounds)!
    }

}

