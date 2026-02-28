import SwiftUI
import UIKit

struct RootView: View {
    private enum Route {
        case search
        case splash
        case onboarding
        case home
        case setting
    }

    let settings: AppSettings
    @State private var route: Route = .splash
    @State private var homeViewModel: HomeViewModel
    @State private var searchViewModel: SearchViewModel
    @State private var pendingUpdateURL: URL?
    @State private var showUpdateAlert = false

    init(settings: AppSettings) {
        self.settings = settings
        self._homeViewModel = State(initialValue: HomeViewModel(service: HomeAPIMenuService(), settings: settings))
        self._searchViewModel = State(initialValue: SearchViewModel(service: SearchAPISchoolService(), settings: settings))
    }

    var body: some View {
        ZStack {
            if route == .search {
                SearchView(viewModel: searchViewModel) {
                    homeViewModel.resetForSchoolChange()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .home
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .splash {
                SplashView(
                    homeViewModel: homeViewModel,
                    hasSelectedSchool: settings.selectedSchool != nil
                ) { shouldGoHome, updateURL in
                    pendingUpdateURL = updateURL
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = shouldGoHome ? .home : .onboarding
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .onboarding {
                OnboardingView {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = settings.selectedSchool != nil ? .home : .search
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .home {
                HomeView(viewModel: homeViewModel, onSetting: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .setting
                    }
                })
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }

            if route == .setting {
                SettingView(onBack: {
                    homeViewModel.resetForSchoolChange()
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .home
                    }
                }, onSearchSchool: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .search
                    }
                })
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: route)
        .alert("업데이트 안내", isPresented: $showUpdateAlert) {
            Button("업데이트") {
                if let pendingUpdateURL {
                    UIApplication.shared.open(pendingUpdateURL)
                }
                pendingUpdateURL = nil
            }
            Button("나중에", role: .cancel) {
                pendingUpdateURL = nil
            }
        } message: {
            Text("새로운 버전이 출시되었습니다.\n더 나은 경험을 위해 업데이트해 주세요.")
        }
        .onChange(of: route) { _, newRoute in
            if newRoute == .home, pendingUpdateURL != nil {
                showUpdateAlert = true
            }
        }
        .onOpenURL { url in
            guard url.scheme == "bobmoo" else { return }

            let destination = url.host ?? url.pathComponents.dropFirst().first ?? "home"
            if destination == "home" {
                homeViewModel.resetForSchoolChange()
                withAnimation(.easeInOut(duration: 0.35)) {
                    route = settings.selectedSchool != nil ? .home : .search
                }
            }
        }
    }
}

#Preview {
    let settings = AppSettings()
    RootView(settings: settings)
        .environment(settings)
}
