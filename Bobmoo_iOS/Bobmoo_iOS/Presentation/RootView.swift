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
    private let analytics = BobmooAnalytics.shared
    @State private var route: Route = .splash
    @State private var homeViewModel: HomeViewModel
    @State private var searchViewModel: SearchViewModel
    @State private var pendingUpdateURL: URL?
    @State private var showUpdateAlert = false
    @State private var didLogInitialAnalytics = false

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
                    analytics.logOnboardingStarted(hasSelectedSchool: settings.selectedSchool != nil)
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = settings.selectedSchool != nil ? .home : .search
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .home {
                HomeView(viewModel: homeViewModel, onSetting: {
                    analytics.logSettingsOpened(source: "home", schoolName: settings.selectedSchool)
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
                    analytics.logSchoolSettingTapped(currentSchoolName: settings.selectedSchool)
                    withAnimation(.easeInOut(duration: 0.35)) {
                        route = .search
                    }
                })
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: route)
        .task {
            guard !didLogInitialAnalytics else { return }
            didLogInitialAnalytics = true
            analytics.logAppOpen(hasSelectedSchool: settings.selectedSchool != nil)
            trackRoute(route, entryPoint: "app_launch")
        }
        .alert("업데이트 안내", isPresented: $showUpdateAlert) {
            Button("업데이트") {
                analytics.logUpdatePromptAction("update")
                if let pendingUpdateURL {
                    UIApplication.shared.open(pendingUpdateURL)
                }
                pendingUpdateURL = nil
            }
            Button("나중에", role: .cancel) {
                analytics.logUpdatePromptAction("later")
                pendingUpdateURL = nil
            }
        } message: {
            Text("새로운 버전이 출시되었습니다.\n더 나은 경험을 위해 업데이트해 주세요.")
        }
        .onChange(of: route) { _, newRoute in
            trackRoute(newRoute)
            if newRoute == .home, pendingUpdateURL != nil {
                analytics.logUpdatePromptShown()
                showUpdateAlert = true
            }
        }
        .onOpenURL { url in
            guard url.scheme == "bobmoo" else { return }

            let destination = url.host ?? url.pathComponents.dropFirst().first ?? "home"
            analytics.logDeepLinkOpened(destination: destination, hasSelectedSchool: settings.selectedSchool != nil)
            if destination == "home" {
                homeViewModel.resetForSchoolChange()
                withAnimation(.easeInOut(duration: 0.35)) {
                    route = settings.selectedSchool != nil ? .home : .search
                }
            }
        }
    }

    private func trackRoute(_ route: Route, entryPoint: String? = nil) {
        switch route {
        case .search:
            analytics.logScreenView(.search, entryPoint: entryPoint)
        case .splash:
            analytics.logScreenView(.splash, entryPoint: entryPoint)
        case .onboarding:
            analytics.logScreenView(.onboarding, entryPoint: entryPoint)
        case .home:
            analytics.logScreenView(.home, entryPoint: entryPoint)
            analytics.logHomeOpened(schoolName: settings.selectedSchool, date: homeViewModel.currentDate)
        case .setting:
            analytics.logScreenView(.setting, entryPoint: entryPoint)
        }
    }
}

#Preview {
    let settings = AppSettings()
    RootView(settings: settings)
        .environment(settings)
}
