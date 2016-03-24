//
//  ModDataViewController.swift
//  QianHongBao
//
//  Created by arkic on 16/3/2.
//  Copyright (c) 2016年 arkic. All rights reserved.
//

import UIKit

class ModDataViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var btnHeadImg: UIButton!
    
    @IBOutlet weak var tfName: UITextField!
    @IBAction func btnBack(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func btnImage(sender: AnyObject) {
        if(!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)){
            MyDialog.showErrorAlert(self, msg: "不能打开相册")
            return
        }
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let gotImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let midImage:UIImage = self.imageWithImageSimple(gotImage, scaledToSize: CGSizeMake(100, 100))
//        
        self.btnHeadImg.setImage(midImage, forState: UIControlState.Normal)
        
        uploadImg(midImage)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imageWithImageSimple(image:UIImage,scaledToSize size:CGSize)->UIImage{
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    func uploadImg(img:UIImage){
        let data = UIImagePNGRepresentation(img)
        let url = URL_UserHeadImage + "/uid/\(Common.getUid())"
        MyHttp.doUpload(url, filename: "photo2", fileData: data!){ (data, rep, error) in
            
        }
    
    }
    @IBAction func btnConfirm(sender: AnyObject) {
        let nackname = tfName.text!
        if(nackname == ""){
            MyDialog.showErrorAlert(self, msg: "数据不能为空")
            return
        }

        
        let data:Dictionary<String,AnyObject> = ["uid":Common.getUid(),"nackname":nackname]
        MyHttp.doPost(URL_UserModPwd, data: data) { (data, rep, error) in
            dispatch_sync(dispatch_get_main_queue(), {
                do{
                    var jobj = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! Dictionary<String,AnyObject>
                    let status = (jobj["status"] as! NSNumber).integerValue
                    if(status==0){
                        MyDialog.showErrorAlert(self, msg: jobj["info"] as! String)
                        return
                    }
                    
                    MyDialog.showSuccessAlert(self, msg: jobj["info"] as! String)
                    Common.setNickName(nackname)
                }catch{
                    MyDialog.showErrorAlert(self, msg: "未知错误")
                    return
                }
            })
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tfName.text = Common.getNickName()
        btnHeadImg.sd_setImageWithURL(NSURL(string: Common.getHeadImg()), forState: UIControlState.Normal, placeholderImage: UIImage(named: IMG_LOADING))
        // Do any additional setup after loading the view.
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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