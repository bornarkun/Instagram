//
//  PostViewController.swift
//  Instagram
//
//  Created by Kevin Ho on 3/2/16.
//  Copyright © 2016 KevinHo. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class PostViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var selectPhotoCaption: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var captionField: UITextField!
    
    let imagePicker = UIImagePickerController()
    var image = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
            let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
            image = originalImage
            dismissViewControllerAnimated(true, completion: nil)
            self.userImageView.image = image
            if userImageView != nil {
                selectPhotoCaption.hidden = true
            }
    }
    
    @IBAction func addPhotoLibrary(sender: AnyObject) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onSubmitImage(sender: AnyObject) {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        if userImageView.image != nil || captionField.text != nil {
            UserMedia.postUserImage(userImageView.image, withCaption: self.captionField.text, withCompletion: nil)
            MBProgressHUD.hideHUDForView(self.view, animated: true)
        }
            
        else {
            print("ERROR! No image and/or caption")
        }
        
        let seconds = 3.5
        let delay = seconds * Double(NSEC_PER_SEC)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
            
            self.tabBarController!.selectedIndex = 0;
    
        })
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRectMake(0, 0, newSize.width, newSize.height))
        resizeImageView.contentMode = UIViewContentMode.ScaleAspectFill
        resizeImageView.image = image
        
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        resizeImageView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    class UserMedia: NSObject {
        
        class func postUserImage(image: UIImage?, withCaption caption: String?, withCompletion completion: PFBooleanResultBlock?) {
            let media = PFObject(className: "UserMedia")
            media["media"] = getPFFileFromImage(image)
            media["author"] = PFUser.currentUser()
            media["caption"] = caption
            media.saveInBackgroundWithBlock(completion)
        }
        
        class func getPFFileFromImage(image: UIImage?) -> PFFile? {
            if let image = image {
                if let imageData = UIImagePNGRepresentation(image) {
                    return PFFile(name: "image.png", data: imageData)
                }
            }
            return nil
        }
    }
    @IBAction func onTapOutside(sender: AnyObject) {
        self.view.endEditing(true)
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
