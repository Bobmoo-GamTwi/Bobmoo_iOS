import SwiftUI
import UIKit

struct RootView: View {
    private enum Route {
        case search
        case splash
        case onboarding
        case home
        case setting

        var analyticsScreen: BobmooScreen {
            switch self {
            case .search:
                return .search
            case .splash:
                return .splash
            case .onboarding:
                return .onboarding
            case .home:
                return .home
            case .setting:
                return .setting
            }
        }
    }

    let settings: AppSettings
    private let analytics = BobmooAnalytics.shared
    @State private var route: Route = .splash
    @State private var homeViewModel: HomeViewModel
    @State private var searchViewModel: SearchViewModel
    @State private var pendingUpdateURL: URL?
    @State private var showUpdateAlert = false
    @State private var didLogInitialAnalytics = false
    @State private var pendingScreenEntryPoint: String?

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
                    navigate(to: .home, entryPoint: "school_selection_completed")
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .splash {
                SplashView(
                    homeViewModel: homeViewModel,
                    hasSelectedSchool: settings.hasSelectedSchool
                ) { shouldGoHome, updateURL in
                    pendingUpdateURL = updateURL
                    navigate(to: shouldGoHome ? .home : .onboarding, entryPoint: "splash")
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .onboarding {
                OnboardingView {
                    analytics.logOnboardingStarted()
                    navigate(to: settings.hasSelectedSchool ? .home : .search, entryPoint: "onboarding")
                }
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }

            if route == .home {
                HomeView(viewModel: homeViewModel, onSetting: {
                    navigate(to: .setting, entryPoint: "home")
                })
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }

            if route == .setting {
                SettingView(onBack: {
                    homeViewModel.resetForSchoolChange()
                    navigate(to: .home, entryPoint: "setting")
                }, onSearchSchool: {
                    analytics.logSchoolSettingTapped()
                    navigate(to: .search, entryPoint: "settings_school")
                })
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: route)
        .task {
            guard !didLogInitialAnalytics else { return }
            didLogInitialAnalytics = true
            analytics.logAppOpened()
            trackRoute(route, entryPoint: "app_launch")
        }
        .alert("업데이트 안내", isPresented: $showUpdateAlert) {
            Button("업데이트") {
                analytics.logUpdatePromptClicked(action: "update")
                if let pendingUpdateURL {
                    UIApplication.shared.open(pendingUpdateURL)
                }
                pendingUpdateURL = nil
            }
            Button("나중에", role: .cancel) {
                analytics.logUpdatePromptClicked(action: "later")
                pendingUpdateURL = nil
            }
        } message: {
            Text("새로운 버전이 출시되었습니다.\n더 나은 경험을 위해 업데이트해 주세요.")
        }
        .onChange(of: route) { oldRoute, newRoute in
            trackRoute(newRoute, entryPoint: pendingScreenEntryPoint, routeSource: oldRoute.analyticsScreen.rawValue)
            pendingScreenEntryPoint = nil
            if newRoute == .home, pendingUpdateURL != nil {
                analytics.logUpdatePromptViewed()
                showUpdateAlert = true
            }
        }
        .onOpenURL { url in
            guard url.scheme == "bobmoo" else { return }

            let destination = url.host ?? url.pathComponents.dropFirst().first ?? "home"
            analytics.logDeepLinkOpened(destination: destination)
            if destination == "home" {
                homeViewModel.resetForSchoolChange()
                navigate(to: settings.hasSelectedSchool ? .home : .search, entryPoint: "deep_link")
            }
        }
    }

    private func trackRoute(_ route: Route, entryPoint: String? = nil, routeSource: String? = nil) {
        switch route {
        case .search:
            analytics.logSearchViewed(entryPoint: entryPoint, routeSource: routeSource)
        case .splash:
            analytics.logSplashViewed(entryPoint: entryPoint, routeSource: routeSource)
        case .onboarding:
            analytics.logOnboardingViewed(entryPoint: entryPoint, routeSource: routeSource)
        case .home:
            analytics.logHomeViewed(
                date: homeViewModel.currentDate,
                entryPoint: entryPoint,
                routeSource: routeSource
            )
        case .setting:
            analytics.logSettingsViewed(
                source: routeSource ?? "unknown",
                entryPoint: entryPoint,
                routeSource: routeSource
            )
        }
    }

    private func navigate(to route: Route, entryPoint: String? = nil) {
        pendingScreenEntryPoint = entryPoint
        withAnimation(.easeInOut(duration: 0.35)) {
            self.route = route
        }
    }
}

#Preview {
    let settings = AppSettings()
    RootView(settings: settings)
        .environment(settings)
}
