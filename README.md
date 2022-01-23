# Detect Swipe

This project demonstrates how to recognize swipe gesture in SwiftUI.

Limitation: If your finger moves in a curve quickly, for example moves up a little bit and then moves right a large distance, the UIKit API may not recognize it as a swipe. But here we only consider the latest position of your finger instead of the whole trajectory.