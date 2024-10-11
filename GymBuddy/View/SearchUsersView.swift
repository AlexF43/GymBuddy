//
//  SearchUsersView.swift
//  GymBuddy
//
//  Created by Alex Fogg on 11/10/2024.
//

import SwiftUI

struct SearchUsersView: View {
    @ObservedObject var viewModel: UserViewModel
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @State private var suggestedUsers: [User] = []
    @State private var searchResults: [User] = []
    
    var body: some View {
        NavigationView {
            List {
                if searchText.isEmpty {
                    Section(header: Text("Suggested Users")) {
                        ForEach(suggestedUsers, id: \.id) { user in
                            UserRowView(user: user, viewModel: viewModel)
                        }
                    }
                } else {
                    ForEach(searchResults, id: \.id) { user in
                        UserRowView(user: user, viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Search Users")
            .searchable(text: $searchText, prompt: "Search users")
            .onChange(of: searchText) { _ in
                if !searchText.isEmpty {
                    searchUsers()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            fetchSuggestedUsers()
        }
    }
    
    private func fetchSuggestedUsers() {
        viewModel.fetchMostFollowedUsers { users, error in
            if let users = users {
                self.suggestedUsers = users
            }
        }
    }
    
    private func searchUsers() {
        viewModel.searchUsers(by: searchText) { users, error in
            if let users = users {
                self.searchResults = users
            }
        }
    }
}


