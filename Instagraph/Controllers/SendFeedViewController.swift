//
//  SendFeedViewController.swift
//  Instagraph
//
//  Created by 魏文洲 on 18/10/2018.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import Firebase

class SendFeedViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, ReturnLocationProtocol {
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var feedTextView: UITextView!
    @IBOutlet weak var shareFeedTableView: UITableView!
    
    var feedImage: UIImage?
    let optionList = ["Add Location"]
    var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var selectedLocation: Location?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
        feedTextView.delegate = self
        feedTextView.text = "Share your ideas with us!"
        feedTextView.textColor = UIColor.lightGray
        
        feedImageView.image = feedImage
        
        shareFeedTableView.keyboardDismissMode = .onDrag
        shareFeedTableView.delegate = self
        shareFeedTableView.dataSource = self
        
        
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlaceAutoCompleteSegue" {
            if let destinationVC = segue.destination as? LocationAutoCompleteViewController {
                destinationVC.delegate = self
            }
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Share your ideas with us!"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func uploadUserFeed() {
        activityIndicator.startAnimating()
        if let feedImage = feedImage, let currentUser = Auth.auth().currentUser {
            FeedManager.share.labelImage(image: feedImage, onLabelling: {(labels) in
                let userFeed = UserFeed(uid: currentUser.uid, location: self.selectedLocation, imageURL: "", text: self.feedTextView.text, imageLabels: [], timestamp: Timestamp.timestampDateToInt(Date()))
                FeedManager.share.uploadFeedImage(feedId: userFeed.id, image: self.feedImage!, callback: {(url, error) in
                    if let url = url {
                        userFeed.imageURL = url.absoluteString
                        
                        let feedsRef = Database.database().reference().child("feeds")
                        
                        feedsRef.child(userFeed.id).setValue([
                            "id": userFeed.id,
                            "imageURL": userFeed.imageURL,
                            "text": userFeed.text,
                            "timestamp": userFeed.timestamp,
                            "imageLabels": userFeed.imageLabels,
                            "uid": userFeed.uid
                        ]) {
                            (error:Error?, ref:DatabaseReference) in
                            if error == nil {
                                feedsRef.child(userFeed.id).child("location").setValue(userFeed.location?.serialize()) {
                                    (error:Error?, ref:DatabaseReference) in
                                    if error == nil {
                                        UserManager.share.updateUserLabel(uid: currentUser.uid, labels: labels, onLabelSaved: {(error) in
                                            if error == nil {
                                                self.activityIndicator.stopAnimating()
                                                self.performSegue(withIdentifier: "unwindToPreviousSegue", sender: nil)
                                            } else {
                                                self.activityIndicator.stopAnimating()
                                                self.showAlert(title: "Network Error", message: "Upload labels failed. Please try again!", handler: {(alert: UIAlertAction!) in
                                                    self.performSegue(withIdentifier: "unwindToPreviousSegue", sender: nil)
                                                })
                                            }
                                        })
                                    } else {
                                        self.activityIndicator.stopAnimating()
                                        self.showAlert(title: "Network Error", message: "Upload failed. Please try again!", handler: {_ in })
                                        return
                                    }
                                }
                            } else {
                                self.activityIndicator.stopAnimating()
                                self.showAlert(title: "Network Error", message: "Upload failed. Please try again!", handler: {_ in })
                                return
                            }
                        }
                    } else {
                        self.activityIndicator.stopAnimating()
                    }
                })
            })
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    func showAlert(title: String, message: String, handler: @escaping (UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: handler))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func setLocation(title: String, long: Double, lat: Double) {
        if title != "" {
            let locDict = ["longitude": long, "latitude": lat, "title": title] as [String : Any]
            selectedLocation = Location(dict: locDict as NSDictionary)
        } else {
            selectedLocation = nil
        }
        shareFeedTableView.reloadData()
    }
    
    @IBAction func backbuttonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        uploadUserFeed()
    }
}

extension SendFeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = shareFeedTableView.dequeueReusableCell(withIdentifier: "shareOptionCell", for: indexPath)
        cell.textLabel?.text = optionList[indexPath.row]
        if let location = selectedLocation {
            cell.detailTextLabel?.text = location.title
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if optionList[indexPath.row].contains("Add Location") {
            performSegue(withIdentifier: "showPlaceAutoCompleteSegue", sender: nil)
        }
    }
}
