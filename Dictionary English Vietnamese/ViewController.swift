//
//  ViewController.swift
//  Dictionary English Vietnamese
//
//  Created by MAC on 17/08/2016.
//  Copyright © 2016 o00ontcong. All rights reserved.
//

import Cocoa

let kDay = "keyDay"
let kCompleted = "kCompleted"
let kPoint = "kPoint"
let kTrain = "kTrain"

var kRandom = Int()
var numberOfCompletions = [String]()
var Completed = Array<String>()
var currentVoca = [Vocabulary]()
var kSound = true


class ViewController: NSViewController, NMDatePickerDelegate  {
    
    @IBOutlet weak var tableViewToday: NSTableView!
    @IBOutlet weak var tableViewList: NSTableView!
    @IBOutlet weak var random: NSButton!
    @IBOutlet weak var inputTime: NSTextField!
    @IBOutlet weak var labelPoint: NSTextField!
    @IBOutlet weak var btnPlayNow: NSButton!
    @IBOutlet weak var datePicker: NMDatePicker!
    
    @IBAction func abtnQuit(sender: AnyObject) {
        NSApp.terminate(self)
    }
    var timer = NSTimer()
    
    @IBAction func abtnPlayNow(sender: AnyObject) {
        if status == false {
            status = true
            btnPlayNow.image = NSImage(named: "Stop")
            showWindow()
            timer = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(Int(inputTime.stringValue)!), target: self, selector: #selector(ViewController.showWindow), userInfo: nil, repeats: true)
        } else {
            status = false
            btnPlayNow.image = NSImage(named: "Play Now")
            if timer.valid == true{
                timer.invalidate()
            }
            
        }
    }
    
    var showWC: ShowWindowController!
    var todayVocabulary = [Vocabulary]()
    var listVocabulary = [Vocabulary]()
    var key = 1
    var status = false
    var train = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleData()
        let userdefault = NSUserDefaults.standardUserDefaults()
        // reset
//                userdefault.setInteger(1, forKey: kDay)
//                userdefault.setObject(Completed, forKey: kCompleted)
        let keyDay: Int = userdefault.integerForKey(kDay)
        
        if keyDay == 1 {
            userdefault.setInteger(1, forKey: kDay)
        } else {
            self.key = keyDay
        }
        
        if let keyCompleted: Array<String> = userdefault.objectForKey(kCompleted) as? Array<String>{
            Completed = keyCompleted
        }
        if let train: Bool = userdefault.boolForKey(kTrain){
            self.train = train
        } else {
            userdefault.setBool(false, forKey: kTrain)
        }
        
        loadSqliteFull()
        labelPoint.stringValue = String(key)
        if train == true {
            loadSqliteThree(String(key))
        } else {
            loadSqliteOne(String(key))
        }
        
        
    }
    
    @IBAction func abtnHelp(sender: AnyObject) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Every vocabulary repeat 5 times, after 3 days will training 1 times. \np/s: you can input time repeat"
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        myPopup.runModal()
    }
    
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    
    //NMData Delegate and DataSource
    class func shortDateForDate(date: NSDate) -> NSString {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.currentLocale()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter.stringFromDate(date)
    }
    
    func nmDatePicker(datePicker: NMDatePicker, selectedDate: NSDate) {
        
    }
    
    func styleData() {
        let now = NSDate()
        self.datePicker.dateValue = now
        self.datePicker.delegate = self
        
        // NMDatePicker appearance properties
        datePicker.backgroundColor = NSColor.whiteColor()
        datePicker.font = NSFont.systemFontOfSize(13.0)
        datePicker.titleFont = NSFont.boldSystemFontOfSize(14.0)
        datePicker.textColor = NSColor.blackColor()
        datePicker.selectedTextColor = NSColor.whiteColor()
        datePicker.todayBackgroundColor = NSColor.whiteColor()
        datePicker.todayBorderColor = NSColor.blueColor()
        datePicker.highlightedBackgroundColor = NSColor.lightGrayColor()
        datePicker.highlightedBorderColor = NSColor.darkGrayColor()
        datePicker.selectedBackgroundColor = NSColor.orangeColor()
        datePicker.selectedBorderColor = NSColor.blueColor()
        
    }
    //MARK: sqlite
    func loadSqliteFull() {
        // ket noi CSDL
        let database:COpaquePointer = self.KhoaPhamTraining_Connect_DB_Sqlite("700TOEIC", type: "sqlite")
        //  Select table List
        let statement:COpaquePointer = KhoaPhamTraining_Select("SELECT * FROM ZVOCABWORD", database: database)
        // Do du lieu vao mang
        while sqlite3_step(statement) == SQLITE_ROW {
            // Do ra tung cot tuong ung voi no
            let id = sqlite3_column_text(statement, 0)
            let day = sqlite3_column_text(statement, 3)
            let english = sqlite3_column_text(statement, 6)
            let vietnamese = sqlite3_column_text(statement, 5)
            // Neu cot nao co dau tieng viet thi can phai lam them buoc nay
            let valueId = String.fromCString(UnsafePointer<CChar>(id))
            let valueDay = String.fromCString(UnsafePointer<CChar>(day))
            let valueEnglish = String.fromCString(UnsafePointer<CChar>(english))
            let valueVietnamese = String.fromCString(UnsafePointer<CChar>(vietnamese))
            // Them Vao mang da co
            if let vocabulary: Vocabulary = Vocabulary(ID: valueId!, DAY: valueDay!, ENGLISH: valueEnglish!, VIETNAMESE: valueVietnamese!){
                listVocabulary.append(vocabulary)
            }
            
        }
        sqlite3_finalize(statement)
        
    }
    func loadSqliteOne(myDay: String) {
        let database:COpaquePointer = self.KhoaPhamTraining_Connect_DB_Sqlite("700TOEIC", type: "sqlite")
        let today:COpaquePointer = KhoaPhamTraining_Select("SELECT * FROM ZVOCABWORD WHERE ZCATEGORy_ID = \(myDay)", database: database)
        while sqlite3_step(today) == SQLITE_ROW {
            // Do ra tung cot tuong ung voi no
            let id = sqlite3_column_text(today, 0)
            let day = sqlite3_column_text(today, 3)
            let english = sqlite3_column_text(today, 6)
            let vietnamese = sqlite3_column_text(today, 5)
            // Neu cot nao co dau tieng viet thi can phai lam them buoc nay
            let valueId = String.fromCString(UnsafePointer<CChar>(id))
            let valueDay = String.fromCString(UnsafePointer<CChar>(day))
            let valueEnglish = String.fromCString(UnsafePointer<CChar>(english))
            let valueVietnamese = String.fromCString(UnsafePointer<CChar>(vietnamese))
            // Them Vao mang da co
            if let vocabulary: Vocabulary = Vocabulary(ID: valueId!, DAY: valueDay!, ENGLISH: valueEnglish!, VIETNAMESE: valueVietnamese!){
                todayVocabulary.append(vocabulary)
            }
        }
        sqlite3_finalize(today)
        sqlite3_close(database)
        
        for b in todayVocabulary {
            var flag = false
            for a in Completed {
                if b.id == a {
                    flag = true
                }
            }
            if flag == false {
                currentVoca.append(b)
            }
        }
        
    }
    func loadSqliteThree(myDay: String) {
        let database:COpaquePointer = self.KhoaPhamTraining_Connect_DB_Sqlite("700TOEIC", type: "sqlite")
        
        let today:COpaquePointer = KhoaPhamTraining_Select("SELECT * FROM ZVOCABWORD WHERE ZCATEGORy_ID  >= \(key - 2) and ZCATEGORy_ID <= \(key)", database: database)
        while sqlite3_step(today) == SQLITE_ROW {
            // Do ra tung cot tuong ung voi no
            let id = sqlite3_column_text(today, 0)
            let day = sqlite3_column_text(today, 3)
            let english = sqlite3_column_text(today, 6)
            let vietnamese = sqlite3_column_text(today, 5)
            // Neu cot nao co dau tieng viet thi can phai lam them buoc nay
            let valueId = String.fromCString(UnsafePointer<CChar>(id))
            let valueDay = String.fromCString(UnsafePointer<CChar>(day))
            let valueEnglish = String.fromCString(UnsafePointer<CChar>(english))
            let valueVietnamese = String.fromCString(UnsafePointer<CChar>(vietnamese))
            // Them Vao mang da co
            if let vocabulary: Vocabulary = Vocabulary(ID: valueId!, DAY: valueDay!, ENGLISH: valueEnglish!, VIETNAMESE: valueVietnamese!){
                todayVocabulary.append(vocabulary)
            }
        }
        currentVoca = todayVocabulary
        
        sqlite3_finalize(today)
        sqlite3_close(database)
        
    }
    func KhoaPhamTraining_Select( query:String,  database:COpaquePointer)->COpaquePointer{
        var statement:COpaquePointer = nil
        sqlite3_prepare_v2(database, query, -1, &statement, nil)
        return statement
    }
    
    func KhoaPhamTraining_Query( sql:String, database:COpaquePointer){
        var errMsg:UnsafeMutablePointer<Int8> = nil
        let result = sqlite3_exec(database, sql, nil, nil, &errMsg);
        if (result != SQLITE_OK) {
            sqlite3_close(database)
            print("Cau truy van bi loi!")
            return
        }
    }
    
    func KhoaPhamTraining_Connect_DB_Sqlite( dbName:String, type:String)->COpaquePointer{
        var database:COpaquePointer = nil
        var dbPath:String = ""
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        let storePath : NSString = documentsPath.stringByAppendingPathComponent(dbName)
        let fileManager : NSFileManager = NSFileManager.defaultManager()
        dbPath = NSBundle.mainBundle().pathForResource(dbName , ofType:type)!
        do {
            try fileManager.copyItemAtPath(dbPath, toPath: storePath as String)
        } catch {
            
        }
        let result = sqlite3_open(dbPath, &database)
        if result != SQLITE_OK {
            sqlite3_close(database)
            print("Failed to open database")
        }
        return database
    }
    
    //MARK: Show window
    
    func showWindow() {
        let userdefault = NSUserDefaults.standardUserDefaults()
        
        if let temptrain:Bool = userdefault.boolForKey(kTrain){
            if temptrain == true {
                let n = currentVoca.count
                if n != 0 {
                    kRandom = Int(arc4random()) % n
                    showWC = ShowWindowController(windowNibName: "ShowWindowController")
                    showWC.window?.level = Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
                    showWC.showWindow(self)
                } else {
                    userdefault.setInteger(self.key + 1, forKey: kDay)
                    self.key = userdefault.integerForKey(kDay)
                    loadSqliteOne(String(key))
                    tableViewToday.reloadData()
                }
            }
                
                
            else {
                
                let n = currentVoca.count
                if n != 0 {
                    kRandom = Int(arc4random()) % n
                    showWC = ShowWindowController(windowNibName: "ShowWindowController")
                    showWC.window?.level = Int(CGWindowLevelForKey(.MaximumWindowLevelKey))
                    showWC.showWindow(self)
                } else {
                    let myPopup: NSAlert = NSAlert()
                    myPopup.messageText = "Finish"
                    myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
                    myPopup.addButtonWithTitle("OK")
                    myPopup.runModal()
                    let m = key % 3
                    if m == 0 {
                        userdefault.setBool(true, forKey: kTrain)
                        todayVocabulary.removeAll()
                        loadSqliteThree(String(key))
                        tableViewToday.reloadData()
                    } else {
                        userdefault.setInteger(self.key + 1, forKey: kDay)
                        self.key = userdefault.integerForKey(kDay)
                        loadSqliteOne(String(key))
                        tableViewToday.reloadData()
                    }
                }
                
                
            }
        }
        
        
    }
    
}

extension ViewController : NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView.tag == 2 {
            return listVocabulary.count
        } else if tableView.tag == 3{
            return todayVocabulary.count
        }
        return 0
    }
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let identifierStr = (tableColumn?.identifier)!
        
        if tableView.tag == 2 {
            if (identifierStr == "id"){
                let cell = tableView.makeViewWithIdentifier("id", owner: self) as! NSTableCellView
                cell.textField?.stringValue = String(Int(listVocabulary[row].id)! - 600)
                return cell
            }
            else if (identifierStr == "english"){
                
                let cell = tableView.makeViewWithIdentifier("english", owner: self) as! NSTableCellView
                cell.textField?.stringValue = listVocabulary[row].english
                return cell
            }
            else if (identifierStr == "vietnamese"){
                
                let cell = tableView.makeViewWithIdentifier("vietnamese", owner: self) as! NSTableCellView
                cell.textField?.stringValue = listVocabulary[row].vietnamese
                return cell
            }
            else {
                let cell = tableView.makeViewWithIdentifier("day", owner: self) as! NSTableCellView
                cell.textField?.stringValue = listVocabulary[row].day
                return cell
            }
        } else {
            
            //Today
            
            if (identifierStr == "id"){
                let cell = tableView.makeViewWithIdentifier("id", owner: self) as! NSTableCellView
                cell.textField?.stringValue = String(Int(todayVocabulary[row].id)! - 600)
                if Completed.count != 0 {
                    for i in 0...Completed.count - 1 {
                        if todayVocabulary[row].id == Completed[i] {
                            cell.textField?.textColor = NSColor.redColor()
                        }
                    }
                }
                return cell
            }
            else if (identifierStr == "english"){
                
                let cell = tableView.makeViewWithIdentifier("english", owner: self) as! NSTableCellView
                cell.textField?.stringValue = todayVocabulary[row].english
                if Completed.count != 0 {
                    for i in 0...Completed.count - 1 {
                        if todayVocabulary[row].id == Completed[i] {
                            cell.textField?.textColor = NSColor.redColor()
                        }
                    }
                }
                return cell            }
            else if (identifierStr == "vietnamese"){
                
                let cell = tableView.makeViewWithIdentifier("vietnamese", owner: self) as! NSTableCellView
                cell.textField?.stringValue = todayVocabulary[row].vietnamese
                if Completed.count != 0 {
                    for i in 0...Completed.count - 1 {
                        if todayVocabulary[row].id == Completed[i] {
                            cell.textField?.textColor = NSColor.redColor()
                        }
                    }
                }
                return cell            }
            else {
                let cell = tableView.makeViewWithIdentifier("day", owner: self) as! NSTableCellView
                cell.textField?.stringValue = todayVocabulary[row].day
                if Completed.count != 0 {
                    for i in 0...Completed.count - 1 {
                        if todayVocabulary[row].id == Completed[i] {
                            cell.textField?.textColor = NSColor.redColor()
                        }
                    }
                }
                return cell
            }
        }
    }
    
}













