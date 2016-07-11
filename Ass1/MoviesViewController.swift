//
//  MoviesViewController.swift
//  Ass1
//
//  Created by HuyTTQ on 7/10/16.
//  Copyright © 2016 HuyTTQ. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
 
    @IBOutlet weak var lblNetErr: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var baseURL :String = ""
    var movies: [NSDictionary] = []
    var posterURLString : String = "";
    var overview : String = ""
    
    
    //Hide navigation bar
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Do any additional setup after loading the view.
        getResource(refreshControl)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if searchActive{
            return moviesFiltered.count
        }
        else
        {
            return movies.count;
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        var movie: NSDictionary
        
        if(searchActive){
            movie = moviesFiltered[indexPath.row]
        }
        else
        {
            movie = movies[indexPath.row]
            searchBar.text = ""
        }
        cell.titleLable.text = movie["original_title"] as? String
        overview = (movie["overview"] as? String)!
        cell.overviewLable.text = overview
        baseURL = "http://image.tmdb.org/t/p/w500"
        let path = movie["poster_path"] as! String
        posterURLString =  baseURL + path
//        let imageUrl = NSURL(string: posterURLString)
//        cell.posterImgView.setImageWithURL(imageUrl!)
        
        let imageRequest = NSURLRequest(URL: NSURL(string: posterURLString)!)
        
        cell.posterImgView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.posterImgView.alpha = 0.0
                    cell.posterImgView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterImgView.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.posterImgView.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        // No color when the user selects cell
        cell.selectionStyle = .None
        // Use a red color when the user selects the cell
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.redColor()
        cell.selectedBackgroundView = backgroundView
        
        return cell
        
    }
    
    func getResource(refreshControl: UIRefreshControl){
        let clientId = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        session.configuration.timeoutIntervalForRequest = 1
        session.configuration.timeoutIntervalForResource = 3
        
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.lblNetErr.hidden = true
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let error = error {
                print("Error")
                self.lblNetErr.hidden = false
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
            }
            else{
                print("Success")
                self.lblNetErr.hidden = true
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                        self.lblNetErr.hidden = true
                        NSLog("response: \(responseDictionary)")
                        self.movies = responseDictionary["results"] as! [NSDictionary]
                        self.tableView.reloadData()
                        // Tell the refreshControl to stop spinning
                        refreshControl.endRefreshing()
                    }
                }
            }
        })
        task.resume()
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let nextVC = segue.destinationViewController as! DetailsViewController
        let ip = tableView.indexPathForSelectedRow
        
        var overv = String("")
        var path = String("")
        var urlStr = String("")
        
        if(searchActive){
            overv = moviesFiltered[(ip?.row)!]["overview"] as! String
            path = moviesFiltered[(ip?.row)!]["backdrop_path"] as! String
        }
        else
        {
            overv = movies[(ip?.row)!]["overview"] as! String
            path = movies[(ip?.row)!]["backdrop_path"] as! String
        }
        
        urlStr = baseURL + path
        nextVC.overview = overv
        nextVC.urlImg = urlStr
    }
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        getResource(refreshControl)
    }
    
    
    //Fun for search bar*******************************************
    var searchActive : Bool = false
    var data = ["San Francisco","New York","San Jose","Chicago","Los Angeles","Austin","Seattle"]
    var filtered:[String] = []
    
    var moviesFiltered: [NSDictionary] = []
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        self.tableView.reloadData()
        self.searchBar.endEditing(true)
        self.searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        self.searchBar.endEditing(true)
        self.searchBar.showsCancelButton = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.showsCancelButton = true
        print(searchText)
        moviesFiltered = movies.filter({ (text) -> Bool in
            let tmpTitle = text["title"] as! String
            let tmpOverview = text["overview"] as! String
            
            let range1 = tmpTitle.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            let range2 = tmpOverview.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            
            //Return true if either match
            return range1 != nil || range2 != nil
            
        })
        searchActive = true;
        self.tableView.reloadData()
    }
}
