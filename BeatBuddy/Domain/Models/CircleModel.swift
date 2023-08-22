//
//  CountdownData.swift
//  BeatBuddy
//
//  Created by Muhammad Adha Fajri Jonison on 21/08/23.
//

import Foundation

struct CircleModel: Identifiable {
    var id: UUID
    var point: CGPoint
    var endTime: DispatchTime
    var originalDuration: Double
    var currentScale: CGFloat

    // This computed property calculates the current scale of the circle based on remaining time.
    var scale: CGFloat {
        let now = DispatchTime.now().uptimeNanoseconds
        if now >= endTime.uptimeNanoseconds {
            return 0.0
        } else {
            let remainingTime = Double(endTime.uptimeNanoseconds - now) / 1_000_000_000.0 // converting nanoseconds to seconds
            let greenCircleSize: CGFloat = 100.0
            let initialCircleSize: CGFloat = 150.0
            let scalePercentage = CGFloat(remainingTime / originalDuration)
            return greenCircleSize + ((initialCircleSize - greenCircleSize) * scalePercentage)
        }
    }

    init(point: CGPoint, duration: TimeInterval = 2.0) {
        self.id = UUID()
        self.point = point
        self.originalDuration = duration
        self.endTime = DispatchTime.now() + duration
        self.currentScale = 150.0 // Start size
    }
}
