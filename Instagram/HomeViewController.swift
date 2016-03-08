//
//  ViewController.swift
//  Instagram
//
//  Created by Kevin Ho on 2/28/16.
//  Copyright © 2016 KevinHo. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var instaPosts: [PFObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        self.getPosts()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 250
        self.tableView.rowHeight = UITableViewAutomaticDimension
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:", name:"load", object: nil)

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPosts()
    {
        let query = PFQuery(className: "UserMedia")
        query.orderByDescending("createdAt")
        query.includeKey("author")
        query.limit = 20
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                self.instaPosts = results
                self.tableView.reloadData()
            } else {
                print(error)
            }
        }
        
    }
    
    func loadList(notification: NSNotification){
        self.getPosts()
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if instaPosts != nil {
            return instaPosts!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ICELL", forIndexPath: indexPath) as! InstaCell
        
        cell.getPhotoandCaption = instaPosts[indexPath.row]
        
        return cell
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.getPosts()
        refreshControl.endRefreshing()
    }
    
}

