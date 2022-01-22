//
//  ContentView.swift
//  DetectSwipe
//
//  Created by Pan Yusheng on 2021/11/20.
//

import SwiftUI

enum MainViewType {
    case uiView, dragLog, swipe
}

struct ContentView: View {
    let viewType = MainViewType.swipe
    @GestureState var swipeState = SwipeState()

    var body: some View {
        let dragGesture = DragGesture(minimumDistance: 0)
            .onChanged { value in
                print("Translation: \(value.translation.width) \(value.translation.height)")
                print("Predict \(value.predictedEndTranslation.width) \(value.predictedEndTranslation.height)")
            }

        switch viewType {
        case .uiView:
            SwipeView()
        case .dragLog:
            Color.white
                .gesture(dragGesture)
        case .swipe:
            Color.white
                .gesture(swipeGesture($swipeState))
                .onChange(of: swipeState.isSwipe) { newValue in
                    print("Swipe \(newValue)")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct SwipeView: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UISwipeView()
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {

    }
}

fileprivate class UISwipeView: UIView {
    var beginLocation: CGPoint?
    var beginTime: Double = 0.0

    var printMove = true
    var checkMySwipe = true
    var printSwipe = true

    override func draw(_ rect: CGRect) {
        guard let beginLocation = beginLocation else {
            return
        }

        UIColor.black.setStroke()

        let halfCrossSize = 10.0

        let crossVertical = UIBezierPath()
        crossVertical.move(to: CGPoint(x: beginLocation.x, y: beginLocation.y - halfCrossSize))
        crossVertical.addLine(to: CGPoint(x: beginLocation.x, y: beginLocation.y + halfCrossSize))
        crossVertical.lineWidth = 1.0
        crossVertical.stroke()

        let crossHorizontal = UIBezierPath()
        crossHorizontal.move(to: CGPoint(x: beginLocation.x - halfCrossSize, y: beginLocation.y))
        crossHorizontal.addLine(to: CGPoint(x: beginLocation.x + halfCrossSize, y: beginLocation.y))
        crossHorizontal.lineWidth = 1.0
        crossHorizontal.stroke()

        let halfAway = UIBezierPath()
        halfAway.move(to: CGPoint(x: beginLocation.x + 25, y: beginLocation.y - 25))
        halfAway.addLine(to: CGPoint(x: beginLocation.x + 25, y: beginLocation.y + 25))
        halfAway.lineWidth = 1.0
        halfAway.stroke()

        let wholeAway = UIBezierPath()
        wholeAway.move(to: CGPoint(x: beginLocation.x + 50, y: beginLocation.y - 50))
        wholeAway.addLine(to: CGPoint(x: beginLocation.x + 50, y: beginLocation.y + 50))
        wholeAway.lineWidth = 1.0
        wholeAway.stroke()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func commonInit() {
        backgroundColor = UIColor.white

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swiped(sender:)))
        swipe.direction = .right
        swipe.cancelsTouchesInView = true

        addGestureRecognizer(swipe)
    }

    @objc func swiped(sender: Any?) {
        print("Swipe")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beginLocation = touches.first!.location(in: self)
        beginTime = event!.timestamp

        setNeedsDisplay()

        super.touchesBegan(touches, with: event)
    }

    func translation(to touch: UITouch) -> CGSize {
        let begin = beginLocation ?? .zero
        let current = touch.location(in: self)

        return CGSize(width: current.x - begin.x, height: current.y - begin.y)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTranslation = translation(to: touches.first!)
        let time = event!.timestamp - beginTime

        let xyt = xytText(translation: currentTranslation, time: time)

        if printMove {
            print("Move \(xyt)")
        }

        if checkMySwipe {
            if isSwipe(translation: currentTranslation, time: time) {
                print("Unexpected move, edge \(edge(time))")
            }
        }

        super.touchesMoved(touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTranslation = translation(to: touches.first!)
        let time = event!.timestamp - beginTime

        let xyt = xytText(translation: currentTranslation, time: time)

        // This is when the swipe fails
        print("End \(xyt)")

        if checkMySwipe {
            if isSwipe(translation: currentTranslation, time: time) {
                print("Unexpected end, edge \(edge(time))")
            }
        }

        super.touchesEnded(touches, with: event)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTranslation = translation(to: touches.first!)
        let time = event!.timestamp - beginTime

        let xyt = xytText(translation: currentTranslation, time: time)

        // This is when the swipe gesture is recognized
        print("Cancel \(xyt)")

        if checkMySwipe {
            if !isSwipe(translation: currentTranslation, time: time) {
                print("Unexpected cancel, edge \(edge(time))")
            }
        }

        super.touchesCancelled(touches, with: event)
    }

    func xytText(translation: CGSize, time: Double) -> String {
        return "\(translation.width) \(translation.height) \(time)"
    }
}
