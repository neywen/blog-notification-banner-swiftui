//
//  BannerView.swift
//  notification-banner-swiftui
//
//  Created by thomas on 4/11/19.
//  Copyright © 2019 thomas. All rights reserved.
//

import SwiftUI

struct BannerData {
    let title: String
    let subtitle: String
    var actionTitle: String? = nil
    var level: Level = .info
    
    let style: Style
    
    enum Style {
        case fullWidth
        case popUp
        case action
        case autodismiss
    }
    
    enum Level {
        case warning
        case info
        case error
        case success
        
        var tintColor: Color {
            switch self {
            case .error: return .red
            case .info: return Color(.sRGB, red: 0.25, green: 0.59, blue: 0.84, opacity: 1)
            case .success: return .green
            case .warning: return .yellow
            }
        }
    }
}

extension BannerData {
    func makeBanner(action: (() -> Void)? = nil) -> some View {
        switch style {
        case .popUp:
            return AnyView(LocalNotification(data: self))
        case .fullWidth:
            return AnyView(FullWidthBanner(data: self))
        case .action:
            return AnyView(BannerWithButton(data: self, action: action))
        case .autodismiss:
            return AnyView(AutoDismissBanner(data: self))
        }
    }
}

struct BannerView: ViewModifier {
    @Binding var isPresented: Bool
    let data: BannerData
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            if isPresented {
                data.makeBanner(action: action)
                    .animation(.easeInOut)
                    .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    .onTapGesture {
                        self.isPresented = false
                }
                .onAppear() {
                    Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (timer) in
                        self.isPresented = false
                    }
                }
            }
            content
        }
    }
}

extension View {
    func banner(isPresented: Binding<Bool>, data: BannerData, action: (() -> Void)? = nil) -> some View {
        self.modifier(BannerView(isPresented: isPresented, data: data, action: action))
    }
}

// MARK: - Some concrete banners

struct AutoDismissBanner: View {
    let data: BannerData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title).fontWeight(.semibold)
                Text(data.subtitle)
            }
            .padding(12)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .background(data.level.tintColor)
            .cornerRadius(8)
        }
        .foregroundColor(.white)
        .padding(.top, 8)
        .padding(.leading, 8)
        .padding(.trailing, 8)
    }
}

struct FullWidthBanner: View {
    let data: BannerData
    
    var body: some View {
        HStack {
            Text(data.title)//.foregroundColor(.white)
        }
        .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8))
        .background(data.level.tintColor)
    }
}

struct LocalNotification: View {
    let data: BannerData
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title)
                    .bold()
                Text(data.subtitle)
            }
            .multilineTextAlignment(.leading)
            .foregroundColor(.white)
        }
        .padding(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 12))
        .background(Color.white)
        .cornerRadius(8, antialiased: true)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 8)
        .padding()
    }
}

struct BannerWithButton: View {
    let data: BannerData
    var action: (() -> Void)?
    
    var body: some View {
        HStack {
            Text(data.title)
            Spacer()
            Button(action: {
                self.action?()
            }) {
                Text(data.actionTitle ?? "Action")
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                    .background(Rectangle().foregroundColor(Color.black.opacity(0.3)))
            }
        }
        .padding(EdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8))
        .background(data.level.tintColor)
    }
    
}
