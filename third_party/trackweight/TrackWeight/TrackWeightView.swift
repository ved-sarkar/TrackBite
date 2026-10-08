//
//  TrackWeightView.swift
//  TrackWeight
//

import SwiftUI

struct TrackWeightView: View {
    @StateObject private var viewModel = WeighingViewModel()
    
    var body: some View {
        VStack(spacing: 30) {
            switch viewModel.state {
            case .welcome:
                WelcomeView {
                    viewModel.startWeighing()
                }
                
            case .waitingForFinger:
                FingerTimerView(
                    progress: viewModel.fingerTimer,
                    hasDetectedFinger: viewModel.fingerTimer > 0
                )
                
            case .waitingForItem:
                InstructionView(
                    title: "Place your item",
                    subtitle: "While maintaining contact with the trackpad, gently place your item. Use as little pressure as possible with your reference finger.",
                    disclaimer: "Keep your finger still and apply minimal pressure",
                    icon: "cube.box"
                )
                
            case .weighing:
                WeighingView(
                    currentPressure: viewModel.currentPressure,
                    isStabilizing: viewModel.isStabilizing,
                    stabilityProgress: viewModel.stabilityProgress
                )
                
            case .result(let weight):
                ResultView(weight: weight) {
                    viewModel.restart()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.windowBackgroundColor))
        .animation(.easeInOut(duration: 0.6), value: viewModel.state)
    }
}

struct WelcomeView: View {
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: "scalemass")
                .font(.system(size: 80, weight: .ultraLight))
                .foregroundStyle(.primary)
            
            Text("TrackWeight")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("Turn your trackpad into a precision scale. Place objects and get their weight in grams.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            
            VStack(spacing: 15) {
                Button(action: onStart) {
                    Text("Begin")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 120, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.blue)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct FingerTimerView: View {
    let progress: Float
    let hasDetectedFinger: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "hand.point.up.left")
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(.blue)
            
            Text("Hold your finger steady")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            VStack(spacing: 8) {
                Text("Keep your finger on the trackpad for 3 seconds")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                
                Text("This establishes your baseline pressure")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }
            
            // Bubble filling animation
            ZStack {
                Circle()
                    .stroke(.blue.opacity(0.3), lineWidth: 4)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .fill(.blue.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                if hasDetectedFinger {
                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: progress)
                    
                    // Gentle bubble effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                        .frame(width: CGFloat(progress) * 80 + 20, height: CGFloat(progress) * 80 + 20)
                        .animation(.easeInOut(duration: 0.2), value: progress)
                    
                    Text("\(Int((1 - progress) * 3) + 1)")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundStyle(.blue)
                }
            }
            .scaleEffect(hasDetectedFinger ? 1.0 : 0.8)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: hasDetectedFinger)
        }
    }
}

struct InstructionView: View {
    let title: String
    let subtitle: String
    let disclaimer: String?
    let icon: String
    
    init(title: String, subtitle: String, disclaimer: String? = nil, icon: String) {
        self.title = title
        self.subtitle = subtitle
        self.disclaimer = disclaimer
        self.icon = icon
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60, weight: .light))
                .foregroundStyle(.blue)
            
            Text(title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            VStack(spacing: 10) {
                Text(subtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 350)
                
                if let disclaimer = disclaimer {
                    Text(disclaimer)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 300)
                }
            }
        }
    }
}

struct WeighingView: View {
    let currentPressure: Float
    let isStabilizing: Bool
    let stabilityProgress: Float
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Weighing...")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
            
            VStack(spacing: 10) {
                Text(String(format: "%.1f", currentPressure))
                    .font(.system(size: 64, weight: .bold, design: .monospaced))
                    .foregroundStyle(.blue)
                    .animation(.easeInOut(duration: 0.2), value: currentPressure)
                
                Text("grams")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 12) {
                Text("Release pressure while maintaining contact")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.orange)
                    .multilineTextAlignment(.center)
                
                Text("Keep your finger on the trackpad but apply as little pressure as possible")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 350)
                
                if isStabilizing {
                    VStack(spacing: 8) {
                        Text("Stabilizing...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.orange)
                        
                        // Progress bar
                        ZStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.orange.opacity(0.2))
                                .frame(width: 200, height: 8)
                            
                            HStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(.orange)
                                    .frame(width: 200 * CGFloat(stabilityProgress), height: 8)
                                    .animation(.linear(duration: 0.1), value: stabilityProgress)
                                
                                Spacer()
                            }
                        }
                        .frame(width: 200)
                        
                        Text("\(Int((1 - stabilityProgress) * 2) + 1)s remaining")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.orange.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: 350)
        }
    }
}


struct ResultView: View {
    let weight: Float
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)
                .scaleEffect(1.0)
                .onAppear {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        // Animation handled by parent view
                    }
                }
            
            Text("Your object weighs")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 5) {
                Text(String(format: "%.1f", weight))
                    .font(.system(size: 56, weight: .bold, design: .monospaced))
                    .foregroundStyle(.primary)
                
                Text("grams")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Button(action: onRestart) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.blue)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(.blue.opacity(0.1))
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    TrackWeightView()
}
