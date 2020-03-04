//
//  ViewController.swift
//  Project 27
//
//  Created by adrian cordova y quiroz on 2/29/20.
//  Copyright © 2020 adrian cordova y quiroz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    //property to cycle through
    var currentDrawType = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        drawRectangle()
    }
    
    func drawRectangle(){
        
        //makes a 512x512 canvas for us
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        //UIimage which is the result of our image
        let img = renderer.image { ctx in
            // awesome drawing code
            
            //ctx is context
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)

            //setFillColor() sets the fill color of our context, which is the color used on the insides of the rectangle we'll draw
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            //setStrokeColor() sets the stroke color of our context, which is the color used on the line around the edge of the rectangle we'll draw.
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            //setLineWidth() adjusts the line width that will be used to stroke our rectangle. Note that the line is drawn centered on the edge of the rectangle, so a value of 10 will draw 5 points inside the rectangle and five points outside
            ctx.cgContext.setLineWidth(10)

            //addRect() adds a CGRect rectangle to the context's current path to be drawn
            ctx.cgContext.addRect(rectangle)
            //drawPath() draws the context's current path using the state you have configured
            ctx.cgContext.drawPath(using: .fillStroke)
        }

        imageView.image = img
        
    }
    
    func drawCircle(){
        
        //makes a 512x512 canvas for us
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        //UIimage which is the result of our image
        let img = renderer.image { ctx in
            // awesome drawing code
            
            //ctx is context
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)

            //setFillColor() sets the fill color of our context, which is the color used on the insides of the rectangle we'll draw
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            //setStrokeColor() sets the stroke color of our context, which is the color used on the line around the edge of the rectangle we'll draw.
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            //setLineWidth() adjusts the line width that will be used to stroke our rectangle. Note that the line is drawn centered on the edge of the rectangle, so a value of 10 will draw 5 points inside the rectangle and five points outside
            ctx.cgContext.setLineWidth(10)

            //addEllipse() adds a CGEllipse ellipse to the context's current path to be drawn
            ctx.cgContext.addEllipse(in: rectangle)
            //drawPath() draws the context's current path using the state you have configured
            ctx.cgContext.drawPath(using: .fillStroke)
        }

        imageView.image = img
        
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)

            //makes checkerboard design for us
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }

        imageView.image = img
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        //translate the squares by
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)

            //rotate them 16 times
            let rotations = 16
            let amount = Double.pi / Double(rotations)

            for _ in 0 ..< rotations {
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }

            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }

        imageView.image = img
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        //translate the lines by
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)

            var first = true
            var length: CGFloat = 256

            //rotate the lines by pi/2
            for _ in 0 ..< 256 {
                ctx.cgContext.rotate(by: .pi / 2)

                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }

                length *= 0.99
            }

            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }

        imageView.image = img
    }
    
    func drawImagesAndText() {
        // 1 Create a renderer at the correct size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            // 2 Define a paragraph style that aligns text to the center
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center

            // 3 Create an attributes dictionary containing that paragraph style, and also a font
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]

            // 4 Wrap that attributes dictionary and a string into an instance of NSAttributedString
            let string = "Ratoliiii gueeeeeey"
            let attributedString = NSAttributedString(string: string, attributes: attrs)

            // Load an image from the project and draw it to the context
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)

            // Update the image view with the finished result
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }

        // 6
        imageView.image = img
    }

    @IBAction func redrawTapped(_ sender: Any) {
        currentDrawType += 1

        //wraps back to 0 once past 5
        if currentDrawType > 5 {
            currentDrawType = 0
        }

        switch currentDrawType {
        case 0:
            drawRectangle()
            
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()

        default:
            break
        }
    }
    

}

