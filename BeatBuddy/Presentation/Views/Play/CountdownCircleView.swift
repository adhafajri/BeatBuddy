//
//  CountdownCircleView.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation
import UIKit
import SwiftUI

struct CountdownCircleView: View {
    @State private var circles: [CircleModel] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(circles) { circle in
                    // Rendering the main circle
                    Circle()
                        .fill(Color.green.opacity(0.5))
                        .frame(width: 100, height: 100)
                        .position(x: circle.point.x * geometry.size.width, y: circle.point.y * geometry.size.height)
                    
                    // Rendering the shrinking circle
                    Circle()
                        .stroke(Color.red, lineWidth: 5.0)
                        .frame(width: circle.currentScale, height: circle.currentScale)
                        .position(x: circle.point.x * geometry.size.width, y: circle.point.y * geometry.size.height)
                    
                    // If the circle is expired, draw an "X"
                    if circle.scale == 0 {
                        CrossMark(center: circle.point)
                    }
                }
            }
        }
    }
}

struct CrossMark: Shape {
    var center: CGPoint
    var lineLength: CGFloat = 50
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: center.x - lineLength / 2, y: center.y - lineLength / 2))
        path.addLine(to: CGPoint(x: center.x + lineLength / 2, y: center.y + lineLength / 2))
        
        path.move(to: CGPoint(x: center.x + lineLength / 2, y: center.y - lineLength / 2))
        path.addLine(to: CGPoint(x: center.x - lineLength / 2, y: center.y + lineLength / 2))
        
        return path
    }
}
