import SwiftUI

struct SageViewData {
    let progress: Double
    let strokeBg: Color
    let circleBg: Color
    let progressColor: Color
    var remainingProgress: Double { 1.0 - progress }

    init(sensorAge: TimeInterval, sensorDurationDays: Double, colorScheme: ColorScheme) {
        strokeBg = colorScheme == .light ? Color(.systemGray5) : Color(.systemGray2)
        circleBg = colorScheme == .light ? Color.white : Color.black
        let secondsInDay: TimeInterval = 24 * 60 * 60
        let sensorDuration: TimeInterval = sensorDurationDays * secondsInDay

        guard sensorDuration > 0, sensorAge >= 0, sensorAge < sensorDuration
        else {
            progress = 1.0
            progressColor = .red.opacity(0.9)
            return
        }

        progress = sensorAge / sensorDuration
        let expiration = sensorDuration - sensorAge

        // Progress color stands out perfectly on top of strokeBg (gray)
        progressColor = switch expiration {
        case ...(0.5 * secondsInDay): Color.red.opacity(0.9)
        case ...(2 * secondsInDay): Color.orange
        default: colorScheme == .light ? .black : .white
        }
    }
}

// MARK: - Option 1: Horizontal Stroke Fill (Left to Right)

struct SageGradientBackground: View {
    let sensorAge: TimeInterval
    let sensorDurationDays: Double
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let data = SageViewData(sensorAge: sensorAge, sensorDurationDays: sensorDurationDays, colorScheme: colorScheme)

        ZStack {
            Circle()
                .fill(data.circleBg)
                .shadow(radius: 4)

            // The gray border underneath
            Circle()
                .stroke(data.strokeBg, lineWidth: 5)

            // The progress filling the border from left to right using a mask
            Circle()
                .stroke(data.progressColor, lineWidth: 5)
                .mask(
                    GeometryReader { geo in
                        Rectangle()
                            .frame(width: geo.size.width * data.progress)
                    }
                )
        }
    }
}

// MARK: - Option 2: Circular Stroke Fill (Clockwise)

struct SageCircularProgress: View {
    let sensorAge: TimeInterval
    let sensorDurationDays: Double
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let data = SageViewData(sensorAge: sensorAge, sensorDurationDays: sensorDurationDays, colorScheme: colorScheme)

        ZStack {
            Circle()
                .fill(data.circleBg)
                .shadow(radius: 4)

            Circle()
                .stroke(data.strokeBg, lineWidth: 5)

            Circle()
                .trim(from: 0.0, to: data.progress)
                .stroke(data.progressColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
