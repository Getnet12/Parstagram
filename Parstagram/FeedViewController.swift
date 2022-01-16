//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Getnet Mekuriyaw on 1/7/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var posts = [PFObject]()
    var commentBar = MessageInputBar()
    var showsCommentBar = false
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment ..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        // to interact with the user/ keyboard
        tableView.keyboardDismissMode = .interactive
    
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    //Hiding the keyboard when trying to refresh
    @objc func keyboardWillBeHidden(note: Notification){
        //
        
        
        // clearing the text from the keyboard
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
        
    }
    // adding the comment in the UI
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //creating a comment
        let comment = PFObject(className: "Comments")
        
        comment["text"] = text
        //because we don't know which post we touched
        comment["post"] = selectedPost
        //who made this comment
        comment["author"] = PFUser.current()!
        selectedPost.add(comment, forKey: "comments")
        selectedPost.saveInBackground{ (success, error) in
            if success {
                print("comment saved")
            }else{
                print("error saving comment")
            }        }
        
        tableView.reloadData()
        
        // clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    // displaying the textfield above the keyboard
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        //author and comments to get the comment and the author
        //comments.author to get the related author or the owner of the comment
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
//        query.skip = 2
        
        query.findObjectsInBackground{ (posts, error) in
//            print(query)
            if posts != nil{
                self.posts = posts!
                print(self.posts)
                self.tableView.reloadData()
            
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []

        //if it's the first row it's going to the post cell
       if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
            
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            cell.photoView.af.setImage(withURL: url)

            return cell

       }else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            //to get the first comment in the post
            let comment = comments[indexPath.row - 1]
            cell.commentLabel.text = comment["text"] as? String

            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
           
            return cell
       }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!

            return cell
        }

    }
    
    
    // Creating fake comments
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            showsCommentBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            selectedPost = post
            
        }
//        comment["text"] = "This is a random comment"
//        //the comment is attached to this specfic post or which post is this comment belongs to
//        comment["comment"] = post
//        //who made this comment
//        comment["author"] = PFUser.current()!
//        post.add(comment, forKey: "comments")
//        post.saveInBackground{ (success, error) in
//            if success {
//                print("comment saved")
//            }else{
//                print("error saving comment")
//            }        }
    }
    
    @IBAction func onLogoutButton(_ sender: UIBarButtonItem) {
        PFUser.logOut()
        
        //        let main = UIStoryboard(name: "Main", bundle: nil)
        //        let loginViewController = main.instantiateViewController(withIdentifier: "LoginView")
        //        let delegate = UIApplication.shared.delegate as! AppDelegate
        //        delegate.window?.rootViewController = loginViewController
        
        let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginView")
        //for full screen presentation
        loginVC?.modalPresentationStyle = .fullScreen
        let delegate = UIApplication.shared.delegate as! AppDelegate
        self.present(loginVC!, animated: true, completion: nil)
        
    }
    
    
}
