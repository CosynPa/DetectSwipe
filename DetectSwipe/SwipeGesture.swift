//
//  SwipeGesture.swift
//  DetectSwipe
//
//  Created by Pan Yusheng on 2022/1/9.
//

import Foundation
import SwiftUI

func edge(_ t: Double) -> CGFloat {
    let a = CGFloat(25)
    return (a - 50.0) / 0.5 * t + 50.0
}

func isSwipe(translation: CGSize, time: Double) -> Bool {
    // Note: when the time increases, the required x distance decreases, this mean for example when you finger moves 35 points to the right in less than 0.02 seconds and stay there, it can still be detected as swipe even if your finger's velocity is near zero when the swipe is detected.
    let edgeX = edge(time)
    let edgeYMin = -edge(time)
    let edgeYMax = edge(time)

    return translation.width > edgeX && edgeYMin < translation.height && translation.height < edgeYMax && time < 0.5
}

public struct SwipeState {
    fileprivate var startTime: Date?

    public var isSwipe = false
    public init() {}
}

public func swipeGesture(_ state: GestureState<SwipeState>) -> GestureStateGesture<DragGesture, SwipeState> {
    return DragGesture(minimumDistance: 0)
        .updating(state) { (value, state, transaction) in
            if state.isSwipe {
                // Do nothing, don't update back to non swipe
            } else {
                if let startTime = state.startTime {
                    let t = value.time.timeIntervalSince(startTime)
                    if isSwipe(translation: value.translation, time: t) {
                        state.isSwipe = true
                    }
                } else {
                    // The first touch event
                    state.startTime = value.time
                }
            }
        }
}
