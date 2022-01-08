//
//  ViewController.swift
//  Parstagram
//
//  Created by Getnet Mekuriyaw on 1/7/22.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onSignIn(_ sender: UIButton) {
        let username = usernameField.text
        let password = passwordField.text
        
        PFUser.logInWithUsername(inBackground: username!, password: password!) {
          (user: PFUser?, error: Error?) -> Void in
          if user != nil {
              self.performSegue(withIdentifier: "loginSegue", sender: nil)
          } else {
              let errorString = error?.localizedDescription
          }
        }
    }
    
    @IBAction func onSignUp(_ sender: UIButton) {
        var user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
          user.signUpInBackground {
            (succeeded: Bool, error: Error?) -> Void in
            if let error = error {
              let errorString = error.localizedDescription
              // Show the errorString somewhere and let the user try again.
            } else {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
          }
    }
}

