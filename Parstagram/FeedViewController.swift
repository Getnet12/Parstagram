//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Getnet Mekuriyaw on 1/7/22.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var posts = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        query.includeKey("author")
        query.limit = 20
        
        query.findObjectsInBackground{ (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = posts[indexPath.row]
        let user = post["author"] as! PFUser
        
        cell.usernameLabel.text = user.username
        cell.captionLabel.text = post["caption"] as! String
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.photoView.af_setImage(withURL: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        let comment = PFObject(className: "Comments")
        comment["text"] = "This is a random comment"
        comment["comment"] = post
        comment["author"] = PFUser.current()!
        post.add(comment, forKey: "comments")
        post.saveInBackground{ (success, error) in
            if success {
                print("comment saved")
            }else{
                print("error saving comment")
            }        }
    }
    
    @IBAction func onLogoutButton(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        print("loggedout")
//        let main = UIStoryboard(name: "Main", bundle: nil)
//        let loginViewController = main.instantiateViewController(withIdentifier: "LoginView")
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        delegate.window?.rootViewController = loginViewController
        
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginView")
        //for full screen presentation
        loginVC?.modalPresentationStyle = .fullScreen
        let delegate = UIApplication.shared.delegate as! AppDelegate
        present(loginVC!, animated: true, completion: nil)
       
        
    }
    
    
}
