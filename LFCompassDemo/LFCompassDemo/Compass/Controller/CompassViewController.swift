//
//  CompassViewController.swift
//  LFCompassDemo
//
//  Created by ios开发 on 2017/12/12.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit
import CoreLocation
import AddressBook

class CompassViewController: UIViewController,CLLocationManagerDelegate{

    
    //位置信息
    var currentLocation:CLLocation?
    let locationManager = CLLocationManager()
    
    lazy var scaleView:ScaleView = {
        let scaleView = ScaleView()
        scaleView.backgroundColor = UIColor.black
        return scaleView
    }()
    //角度
    lazy var angleLabel:UILabel = {
        let angleLabel = UILabel()
        angleLabel.font = UIFont.systemFont(ofSize: 30)
        angleLabel.textAlignment = .center
        angleLabel.textColor = UIColor.white
        return angleLabel
    }()
    //方向
    lazy var directionLabel:UILabel = {
        let directionLabel = UILabel()
        directionLabel.font = UIFont.systemFont(ofSize: 15)
        directionLabel.textColor = UIColor.white
        return directionLabel
    }()
    
    //地理位置
    lazy var positionLabel:UILabel = {
        let positionLabel = UILabel()
        positionLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        positionLabel.numberOfLines = 3
        positionLabel.font = UIFont.systemFont(ofSize: 15)
        positionLabel.textColor = UIColor.white
        return positionLabel
    }()
    
    //经纬度Label
    lazy var latitudlongitudeLabel:UILabel = {
        let latitudlongitudeLabel = UILabel()
        latitudlongitudeLabel.textAlignment = .center
        latitudlongitudeLabel.font = UIFont.systemFont(ofSize: 16)
        latitudlongitudeLabel.textColor = UIColor.white
        return latitudlongitudeLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.navigationItem.title = "指南针"
        
        self.setupUI()
        
        self.createLocationManager()
    }

    private func setupUI() {
        scaleView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width - 30, height: self.view.frame.size.width - 30)
        scaleView.center = CGPoint(x: self.view.frame.size.width / 2, y: self.view.frame.size.height / 2)
        self.view.addSubview(scaleView)
        
        angleLabel.frame = CGRect(x: self.view.frame.size.width / 2 - 100, y: scaleView.frame.origin.y + scaleView.frame.size.height, width: 100, height: 100)
        self.view.addSubview(angleLabel)
        
        directionLabel.frame = CGRect(x: self.view.frame.size.width / 2, y: angleLabel.frame.origin.y, width: 50, height: 50)
        self.view.addSubview(directionLabel)
        
        positionLabel.frame = CGRect(x: self.view.frame.size.width / 2, y: angleLabel.frame.origin.y + directionLabel.frame.size.height, width: self.view.frame.size.width/2, height: 70)
        self.view.addSubview(positionLabel)
        
        latitudlongitudeLabel.frame = CGRect(x: 0, y: positionLabel.frame.origin.y + positionLabel.frame.size.height, width: self.view.frame.size.width, height: 30)
        self.view.addSubview(latitudlongitudeLabel)
    }
    
    private func createLocationManager() {
        self.locationManager.delegate = self
        //定位频率
        self.locationManager.distanceFilter = 0
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation //导航
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() && CLLocationManager.headingAvailable() {
            self.locationManager.startUpdatingLocation()
            self.locationManager.startUpdatingHeading()
        }else {
            print("不能获得航向数据")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
        }
        
        if let current = self.currentLocation {
            let latitudeStr = String.init(format: "%3.2f", current.coordinate.latitude)
            let longitudeStr = String.init(format: "%3.2f", current.coordinate.longitude)
            let altitudeStr = String.init(format: "%3.2f", current.altitude)
            latitudlongitudeLabel.text = "纬度:" + latitudeStr + " " + "经度:" + longitudeStr + " " + "海拔" + altitudeStr
            
            //反地理编码
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(current, completionHandler: { (placemarks, error) in
                if let placemarks = placemarks {
                    if placemarks.count > 0 {
                        let placemark = placemarks[0]
                        if let dic = placemark.addressDictionary {
                            let street = dic[kABPersonAddressStreetKey]
                            let country = placemark.country
                            let subLocality = placemark.subLocality
                            let city = dic[kABPersonAddressCityKey]
                            
                            if let street = street as? String,let country = country,let city = city as? String,let sub = subLocality {
                                self.positionLabel.text = String.init(format: "%@\n %@%@%@", country,city,sub,street)
                            }
                        }
                    }
                }
            })
            
        }
        
    }
    
    //获取方向
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let device = UIDevice.current
        if newHeading.headingAccuracy > 0 {
            let magneticHeading = self.heading(heading: CGFloat(newHeading.magneticHeading), orientation: device.orientation)
//            let trueHeading = self.heading(heading: CGFloat(newHeading.trueHeading), orientation: device.orientation)
            //地磁北方向
            let heading = -1.0 * Double.pi * newHeading.magneticHeading / 180.0
            angleLabel.text = String.init(format: "%3.1f", magneticHeading)
            scaleView.resetDirection(heading: CGFloat(heading))
            self.updateHeading(newHeading: newHeading)
            
        }
    }
    
    private func updateHeading(newHeading:CLHeading) {
        let theHeading = newHeading.magneticHeading > 0 ? newHeading.magneticHeading : newHeading.trueHeading
        let angle = Int(theHeading)
        switch angle {
        case 0:
            directionLabel.text = "北"
        case 90:
            directionLabel.text = "东"
        case 180:
            directionLabel.text = "南"
        case 270:
            directionLabel.text = "西"
        default:
            break
        }
        
        if angle > 0 && angle < 90 {
            directionLabel.text = "东北";
        }else if angle > 90 && angle < 180 {
            directionLabel.text = "东南";
        }else if angle > 180 && angle < 270 {
            directionLabel.text = "西南";
        }else if angle > 270 {
            directionLabel.text = "西北";
        }
    }
    
    
    private func heading(heading:CGFloat,orientation:UIDeviceOrientation) ->CGFloat {
        var realHeading = heading
        switch orientation {
        case .portrait:
            break
        case .portraitUpsideDown:
            realHeading = heading - 180.0
        case .landscapeLeft:
            realHeading = heading + 90.0
        case .landscapeRight:
            realHeading = heading - 90.0
        default:
            break
        }
        if realHeading > 360.0 {
            realHeading -= 360.0
        }else if realHeading < 0.0 {
            realHeading += 366.0
        }
        return realHeading
    }
    
    
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
