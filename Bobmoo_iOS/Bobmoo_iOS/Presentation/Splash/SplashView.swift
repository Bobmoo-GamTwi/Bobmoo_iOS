//
//  SplashView.swift
//  Bobmoo_iOS
//
//  Created by 송성용 on 2/20/26.
//

import SwiftUI
import UIKit

struct SplashView: View {
    let homeViewModel: HomeViewModel
    let updateService: AppUpdateService
    let didTapStart: () -> Void

    @State private var updateURL: URL?
    @State private var showUpdateAlert = false

    init(homeViewModel: HomeViewModel,
         updateService: AppUpdateService = AppUpdateAPIService(),
         didTapStart: @escaping () -> Void) {
        self.homeViewModel = homeViewModel
        self.updateService = updateService
        self.didTapStart = didTapStart
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image(.bobmooLogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                
                BobmooText("밥묵자", style: .head_b_48)
            }
            .padding(.top, 236)
            
            BobmooText("오늘 학식 뭐지?\n홈 화면에서 바로 확인하세요", style: .body_r_15, multiline: true)
                .foregroundStyle(.bobmooGray3)
                .multilineTextAlignment(.center)
                .padding(.top, 28)
            
            Spacer()
            
            BobmooButton(label: "시작하기") {
                didTapStart()
            }
                .padding(.bottom, 12)
                .padding(.horizontal, 40)
            
            BobmooText("로그인 없이도 바로 확인할 수 있어요", style: .body_sb_11)
                .foregroundStyle(.bobmooGray3)
                .padding(.bottom, 21)
        }
        .task {
            async let preloadTask: () = preloadIfNeeded()
            async let updateTask: () = checkForUpdate()
            _ = await (preloadTask, updateTask)
        }
        .alert("업데이트 안내", isPresented: $showUpdateAlert) {
            Button("업데이트") {
                if let url = updateURL {
                    UIApplication.shared.open(url)
                }
            }
            Button("나중에", role: .cancel) {}
        } message: {
            Text("새로운 버전이 출시되었습니다.\n더 나은 경험을 위해 업데이트해 주세요.")
        }
    }

    private func preloadIfNeeded() async {
        if !homeViewModel.isPreloaded {
            await homeViewModel.preload()
        }
    }

    @MainActor
    private func checkForUpdate() async {
        if case .updateAvailable(let storeURL) = await updateService.checkForUpdate() {
            updateURL = storeURL
            showUpdateAlert = true
        }
    }
}


#Preview("기본") {
    SplashView(homeViewModel: HomeViewModel(service: HomeMockMenuService(), settings: AppSettings())) {}
}

#Preview("업데이트 있음") {
    SplashView(
        homeViewModel: HomeViewModel(service: HomeMockMenuService(), settings: AppSettings()),
        updateService: AppUpdateMockService(result: .updateAvailable(
            storeURL: URL(string: "itms-apps://itunes.apple.com/app/id123456789")!
        ))
    ) {}
}
