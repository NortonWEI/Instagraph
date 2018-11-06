//
//  ChoosePhotoViewController.swift
//  Instagraph
//
//  Created by 魏文洲 on 16/10/2018.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit
import YPImagePicker
import PhotoEditorSDK

struct TabIndex {
    static var currentSelectedIndex = 0
}

class ChoosePhotoViewController: UIViewController, PhotoEditViewControllerDelegate {
    var isBackFromShare = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        PESDK.bundleImageBlock = { imageName in
            switch imageName {
            case "imgly_icon_save":
                return UIImage(named: "upload")
            case "imgly_icon_cancel_44pt":
                return UIImage(named: "img-back")
            default:
                return nil
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isBackFromShare {
            isBackFromShare = false
            
            ActionBool.isFirstEnterFeedFromShare = true
            self.tabBarController?.selectedIndex = TabIndex.currentSelectedIndex
        } else {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 116.0/255.0, green: 116.0/255.0, blue: 165.0/255.0, alpha: 1.0)], for: .normal)
            
            var imageConfig = YPImagePickerConfiguration()
            imageConfig.overlayView = CameraGridOverlay()
            imageConfig.shouldSaveNewPicturesToAlbum = false
            let picker = YPImagePicker(configuration: imageConfig)
            
            picker.didFinishPicking { [unowned picker] items, cancelled in
                //cancel clicked
                if cancelled {
                    self.tabBarController?.selectedIndex = TabIndex.currentSelectedIndex
                    picker.dismiss(animated: true, completion: nil)
                }
                
                if let photo = items.singlePhoto {
                    let photoAsset = Photo(image: photo.image)
                    let photoEditViewController = PhotoEditViewController(photoAsset: photoAsset)
                    photoEditViewController.delegate = self
                    picker.present(photoEditViewController, animated: true, completion: nil)
                }
            }
            
            present(picker, animated: true, completion: nil)
        }
    }
    
    func photoEditViewController(_ photoEditViewController: PhotoEditViewController, didSave image: UIImage, and data: Data) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "sendFeedStoryBoard") as! SendFeedViewController
        vc.feedImage = image
        photoEditViewController.present(vc, animated: true, completion: nil)
    }
    
    func photoEditViewControllerDidFailToGeneratePhoto(_ photoEditViewController: PhotoEditViewController) {
        
    }
    
    func photoEditViewControllerDidCancel(_ photoEditViewController: PhotoEditViewController) {
        photoEditViewController.dismiss(animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    @IBAction func unwindToChoosePhotoViewController(segue: UIStoryboardSegue) {
        isBackFromShare = true
    }
}
