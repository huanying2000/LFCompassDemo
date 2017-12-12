//
//  ScaleView.swift
//  LFCompassDemo
//
//  Created by ios开发 on 2017/12/12.
//  Copyright © 2017年 ios开发. All rights reserved.
//

import UIKit

class ScaleView: UIView {

    lazy var backgroundView:UIView = {
        let backView = UIView()
        return backView;
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.layer.cornerRadius = frame.size.width / 2
        backgroundView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        self.addSubview(backgroundView)
        self.paintingScale()
    }
    //画刻度表
    private func paintingScale() {
        let perAngle = Double.pi / (90)
        let array = ["北","东","南","西"]
        //画圆环，每隔2°画一个弧线，总共180条
        for i in 0..<180 {
            let startAngle = (-(Double.pi / 2 + Double.pi / 180 / 2) + perAngle * Double(i))
            let endAngle = startAngle + perAngle / 2
            
            let bezPath = UIBezierPath(arcCenter: CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2), radius: self.frame.size.width/2 - 50, startAngle: CGFloat(startAngle), endAngle: CGFloat(endAngle), clockwise: true)
            let shapeLayer = CAShapeLayer()
            if i % 15 == 0 {
                shapeLayer.strokeColor = UIColor.white.cgColor
                shapeLayer.lineWidth = 20
            }else {
                shapeLayer.strokeColor = UIColor.gray.cgColor
                shapeLayer.lineWidth = 10
            }
            shapeLayer.path = bezPath.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            backgroundView.layer.addSublayer(shapeLayer)
            
            //刻度的标注
            if i % 15 == 0 {
                var tickText = String.init(format: "%d", i * 2)
                let textAngel = startAngle + (endAngle - startAngle) / 2
                let point = self.calculateTextPositon(center: CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2), angel: CGFloat(textAngel), scale: 1.2)
                let label = UILabel.init(frame: CGRect(x: point.x, y: point.y, width: 30, height: 20))
                label.center = point
                label.text = tickText
                label.textColor = UIColor.white
                label.font = UIFont.systemFont(ofSize: 15)
                label.textAlignment = .center
                backgroundView.addSubview(label)
                
                if i % 45 == 0 {
                    //北 东 南 西
                    tickText = array[i / 45]
                    let point2 = self.calculateTextPositon(center: CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2), angel: CGFloat(textAngel), scale: 0.8)
                    let label = UILabel.init(frame: CGRect(x: point2.x, y: point2.y, width: 30, height: 20))
                    label.center = point2
                    label.text = tickText
                    label.textColor = UIColor.white
                    label.font = UIFont.systemFont(ofSize: 20)
                    label.textAlignment = .center
                    if tickText == "北" {
                        let Marklabel = UILabel.init(frame: CGRect(x: point.x, y: point.y, width: 8, height: 8))
                        Marklabel.center = CGPoint(x: point.x, y: point.y + 8)
                        Marklabel.text = tickText
                        Marklabel.clipsToBounds = true
                        Marklabel.layer.cornerRadius = 4
                        Marklabel.textColor = UIColor.red
                        Marklabel.textAlignment = .center
                        backgroundView.addSubview(Marklabel)
                    }
                    
                    backgroundView.addSubview(label)
                }
                
            }
        }
        
        //画十字线
        let levelView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width / 2 / 2, height: 1))
        levelView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        levelView.backgroundColor = UIColor.white
        self.addSubview(levelView)
        
        let verticalView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: self.frame.size.height / 2 / 2))
        verticalView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        verticalView.backgroundColor = UIColor.white
        self.addSubview(verticalView)
        
        let lineView = UIView(frame: CGRect(x: self.frame.size.width / 2 - 1.5, y: self.frame.size.height/2 - (self.frame.size.width/2 - 50) - 50, width: 3, height: 60))
        lineView.backgroundColor = UIColor.white
        self.addSubview(lineView)
        
    }
    
    
    //计算坐标中心
    private func calculateTextPositon(center:CGPoint,angel:CGFloat,scale:CGFloat) ->CGPoint{
        let x = (self.frame.size.width / 2 - 50) * scale *    CGFloat(cosf(Float(angel)))
        let y = (self.frame.size.width / 2 - 50) * scale * CGFloat(sinf(Float(angel)))
        return CGPoint(x: x, y: y)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //重置刻度标志方向
    func resetDirection(heading:CGFloat) {
        backgroundView.transform = CGAffineTransform(rotationAngle: heading)
        for label in backgroundView.subviews {
            label.transform = CGAffineTransform(rotationAngle: -heading)
        }
    }

}
