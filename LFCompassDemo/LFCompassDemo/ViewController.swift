//
//  ViewController.swift
//  LFCompassDemo
//
//  Created by ios开发 on 2017/12/12.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func goCompass(_ sender: Any) {
        let vc = CompassViewController()
        let nav = UINavigationController.init(rootViewController: vc)
        self.present(nav, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

