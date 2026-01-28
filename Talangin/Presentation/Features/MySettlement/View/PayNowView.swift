//
//  PayNowView.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 23/01/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct PayNowView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let transaction: SettlementTransaction
    
    @State private var selectedMethod = "Bank Transfer"
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var selectedFileName: String? = nil
    @State private var selectedImageData: Data? = nil
    @State private var isSubmitting = false
    
    let bankName: String = "BCA"
    let accountNumber: String = "120-12038-19333"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - SECTION 1: SETTLEMENT INFO
                        VStack(alignment: .center, spacing: 8) {
                            Text("Total Amount")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(transaction.amount.formatted(.currency(code: "IDR")))
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Text("Paying to \(transaction.toMemberName)")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 20)
                        
                        // MARK: - SECTION 2: PAYMENT ACCOUNT
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PAYMENT ACCOUNT")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 4)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Text(bankName)
                                    .font(.body)
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                Text(accountNumber)
                                    .font(.body)
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Divider()
                                
                                Text(transaction.toMemberName)
                                    .font(.body)
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // MARK: - SECTION 3: PAYMENT PROOF
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PAYMENT PROOF")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 4)
                            
                            VStack (spacing: 10){
                                Menu {
                                    Button{selectedMethod = "Bank Transfer"} label: {
                                        Text("Bank Transfer")
                                    }
                                    Button{selectedMethod = "Cash"} label: {
                                        Text("Cash")
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "creditcard")
                                            .font(.title2)
                                            .foregroundStyle(.blue)
                                            .frame(width: 24)
                                        
                                        Text(selectedMethod)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                Divider()
                                
                                PhotosPicker(selection: $pickerItem, matching: .images) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.up.document")
                                            .font(.title2)
                                            .foregroundStyle(.blue)
                                            .frame(width: 24)
                                        
                                        Text(selectedFileName ?? "Upload Transfer Proof")
                                            .font(.body)
                                            .foregroundStyle(selectedFileName == nil ? .secondary : .primary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .onChange(of: pickerItem) { _, newItem in
                                    Task {
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            self.selectedImageData = data
                                            let timestamp = Int(Date().timeIntervalSince1970)
                                            self.selectedFileName = "IMG_\(timestamp).jpg"
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Confirm Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Button("Submit") {
                            submitPayment()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    
    private func submitPayment() {
        isSubmitting = true
        
        // Create settlement entity
        let settlement = SettlementEntity(
            fromMemberID: transaction.fromMemberID,
            toMemberID: transaction.toMemberID,
            amount: transaction.amount,
            attachmentData: selectedImageData,
            paymentMethod: selectedMethod
        )
        
        modelContext.insert(settlement)
        
        try? modelContext.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSubmitting = false
            dismiss()
        }
    }
}
