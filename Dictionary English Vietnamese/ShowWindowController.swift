//
//  ShowWindowController.swift
//  Dictionary English Vietnamese
//
//  Created by MAC on 18/08/2016.
//  Copyright © 2016 o00ontcong. All rights reserved.
//

import Cocoa
import AVFoundation

class ShowWindowController: NSWindowController {
    
    @IBOutlet weak var inputEnglish: NSTextField!
    @IBOutlet weak var labelVietnamese: NSTextField!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var labelEnglish: NSTextField!
    
    
    @IBAction func abtnSound(sender: AnyObject) {
        self.playSound(currentVoca[kRandom].english)
    }
    
    
    @IBAction func actionEnglish(sender: AnyObject) {
        let checkIn: Bool = CheckData(inputEnglish.stringValue, data: currentVoca[kRandom])
        if checkIn == true {
            self.window?.close()
            
            let userdefault = NSUserDefaults.standardUserDefaults()
            if let point: Int = userdefault.integerForKey(kPoint){
                userdefault.setInteger(point + 3, forKey: kPoint)
            }
        } else {
            let userdefault = NSUserDefaults.standardUserDefaults()
            if let point: Int = userdefault.integerForKey(kPoint){
                userdefault.setInteger(point - 1, forKey: kPoint)
            }

            labelEnglish.hidden = false
            labelEnglish.stringValue = currentVoca[kRandom].english
        }
        
    }

    var player: AVAudioPlayer?
    override func windowDidLoad() {
        super.windowDidLoad()
        print("ID: \(currentVoca[kRandom].id)")
        labelVietnamese.stringValue = currentVoca[kRandom].vietnamese
            imageView.image = NSImage(named: currentVoca[kRandom].english)
        playSound(currentVoca[kRandom].english)
        
        let queue: dispatch_queue_t = dispatch_queue_create("AutoEnglishVietnamese", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(queue, {
            for _ in 0..<2{
            sleep(3)
            self.playSound(currentVoca[kRandom].english)
            }
        })

    }
    func playSound(name:String) {
        if let url = NSBundle.mainBundle().URLForResource(name, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOfURL: url)
                guard let player = player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
        }
        

    }
    
    func CheckData(inputString: String, data: Vocabulary) -> Bool{
        if (inputString.lowercaseString == data.english.lowercaseString)
        {
            numberOfCompletions.append(data.id)
            var demx = 0
            for i in 0...numberOfCompletions.count - 1{
                if (data.id == numberOfCompletions[i]){
                    demx += 1
                }
            }
            if (demx >= 5){
                var flag = false
                if Completed.count != 0 {
                    
                    for i in 0...Completed.count - 1 {
                        if Completed[i] == data.id {
                            flag = true
                        }
                    }
                }
                if flag == false {
                    Completed.append(data.id)
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(Completed, forKey: kCompleted)
                    let destinationVC = storyboard?.instantiateControllerWithIdentifier("main") as? ViewController
                    destinationVC?.tableViewToday.reloadData()
                }
                
                currentVoca.removeAtIndex(kRandom)
            }
            return true
        } else {
            return false
        }
    }
}
