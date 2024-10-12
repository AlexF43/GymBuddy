//
//  HomeView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 9/10/2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: UserViewModel
    @State private var feedItems: [FeedItem] = []
    @State private var isLoading = false
    @State private var searchUsers = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if (!(viewModel.currentUser?.following.isEmpty ?? false)) {
                    VStack(spacing: 30) {
                        if isLoading {
                            ProgressView()
                        } else {
                            ForEach(feedItems) { item in
                                switch item {
                                case .workout(let workout, let user):
                                    FeedWorkoutView(workout: workout, user: user)
                                        .padding(.horizontal)
                                case .personalBest(let pb, let user):
                                    FeedPersonalBestView(personalBest: pb, user: user)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                } else {
                    Text("Looks like you havent added any friends yet, try adding some here.")
                    Button {
                        searchUsers = true
                    } label: {
                        Text("Add Friends")
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Friend Activity")
            .onAppear(perform: loadData)
            .refreshable {
                loadData()
            }
            .sheet(isPresented: $searchUsers) {
                SearchUsersView(viewModel: viewModel, isPresented: $searchUsers)
            }
            .onChange(of: searchUsers) {
                loadData()
            }
        }
    }

    private func loadData() {
        guard let user = viewModel.currentUser else {
            return
        }
        
        if (user.following.isEmpty) {
            return
        }
        isLoading = true
        let group = DispatchGroup()

        var workouts: [Workout] = []
        var personalBests: [PersonalBest] = []

        group.enter()
        viewModel.getRecentWorkoutsFromFollowing { fetchedWorkouts, error in
            if let fetchedWorkouts = fetchedWorkouts {
                workouts = fetchedWorkouts
            }
            group.leave()
        }

        group.enter()
        viewModel.getRecentPersonalBestsFromFollowing { fetchedPBs, error in
            if let fetchedPBs = fetchedPBs {
                personalBests = fetchedPBs
            }
            group.leave()
        }

        group.notify(queue: .main) {
            let combinedItems = workouts.map { FeedItem.workout($0, nil) } + personalBests.map { FeedItem.personalBest($0, nil) }
            self.feedItems = combinedItems.sorted {
                switch ($0, $1) {
                case (.workout(let w1, _), .workout(let w2, _)):
                    return w1.date > w2.date
                case (.personalBest(let pb1, _), .personalBest(let pb2, _)):
                    return pb1.dateAchieved > pb2.dateAchieved
                case (.workout(let w, _), .personalBest(let pb, _)):
                    return w.date > pb.dateAchieved
                case (.personalBest(let pb, _), .workout(let w, _)):
                    return pb.dateAchieved > w.date
                }
            }

            for (index, item) in self.feedItems.enumerated() {
                switch item {
                case .workout(let workout, _):
                    group.enter()
                    viewModel.getUserInfo(userId: workout.userId) { user, _ in
                        DispatchQueue.main.async {
                            self.feedItems[index] = .workout(workout, user)
                            group.leave()
                        }
                    }
                case .personalBest(let pb, _):
                    group.enter()
                    viewModel.getUserInfo(userId: pb.userId) { user, _ in
                        DispatchQueue.main.async {
                            self.feedItems[index] = .personalBest(pb, user)
                            group.leave()
                        }
                    }
                }
            }

            group.notify(queue: .main) {
                self.isLoading = false
            }
        }
    }
}
