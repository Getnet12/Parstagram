//
//  CameraViewController.swift
//  Parstagram
//
//  Created by Getnet Mekuriyaw on 1/7/22.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmitButton(_ sender: UIButton) {
        
        let post = PFObject(className: "Posts")
        
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        let imageData = (imageView.image!.pngData())
        let file = PFFileObject(name:"image.png", data: imageData!)
        
        post["image"] = file
        
        post.saveInBackground{
            (success, error) in
            if success {
                self.dismiss(animated: true, completion: nil)
                print("saved")
            }else{
                print("error")
            }
        }
        
    }
    
    @IBAction func onCameraButton(_ sender: UITapGestureRecognizer) {
        //print(PFUser.current())
        let picker = UIImagePickerController()
        // call me after the users pick the picture
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }else{
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        //resizing the image since Huroku doesn't allow larger byte
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        imageView.image = scaledImage
        
        // dismissing the cameraview
        dismiss(animated: true, completion: nil)
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
