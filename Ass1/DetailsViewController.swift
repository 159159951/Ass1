
//
//  DetailsViewController.swift
//  Ass1
//
//  Created by HuyTTQ on 7/11/16.
//  Copyright © 2016 HuyTTQ. All rights reserved.
//

import UIKit
import AFNetworking
class DetailsViewController: UIViewController {
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    
    var overview:String = ""
    var urlImg:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        let url = NSURL(string: urlImg)
        //        posterImage.setImageWithURL(url!)
        
        
        
        let imageRequest = NSURLRequest(URL: NSURL(string: urlImg)!)
        
        posterImage.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    self.posterImage.alpha = 0.0
                    self.posterImage.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.posterImage.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    self.posterImage.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        
        overviewLabel.text = overview
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
