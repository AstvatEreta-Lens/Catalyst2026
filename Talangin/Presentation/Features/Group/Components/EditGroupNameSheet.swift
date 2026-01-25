//
//  EditGroupNameSheet.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 25/01/26.
//

import SwiftUI

struct EditGroupNameSheet: View {
    @ObservedObject var viewModel: GroupPageViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Group Name")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                TextField("Enter group name", text: $viewModel.editedName)
                    .font(.title3.bold())
                    .padding()
                    .background(Color(uiColor: .systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text("Edit group name, All member can see the change")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button {
                    viewModel.updateGroupName()
                    viewModel.isEditingName = false
                } label: {
                    Text("Save Changes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.editedName.isEmpty ? Color.gray : Color(red: 60/255, green: 121/255, blue: 195/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(viewModel.editedName.isEmpty)
            }
            .padding(24)
            .navigationTitle("Edit Name")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.isEditingName = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
