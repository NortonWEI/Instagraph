//
//  MainMenuViewController.swift
//  Instagraph
//
//  Created by Margareta  Hardiyanti on 09/09/18.
//  Copyright © 2018 Wenzhou Wei. All rights reserved.
//

import UIKit

class MainMenuViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.title = "Instagraph"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    static func enter() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "MainMenuViewController") as! MainMenuViewController
        //        let navigationController = UINavigationController(rootViewController: viewController)
        UIApplication.shared.keyWindow?.rootViewController  = viewController
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
