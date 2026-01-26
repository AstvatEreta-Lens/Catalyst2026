//
//  PayNowView.swift
//  Talangin
//
//  Created by Ali Jazzy Rasyid on 23/01/26.
//

import SwiftUI
import PhotosUI

struct PayNowView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedMethod = "Choose Methods"
    
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var selectedFileName: String? = nil
    @State private var selectedImageData: Data? = nil
    
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
                        SettlementCard()
                            .zIndex(1)
                        
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
                                
                                Text("Chikmah")
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
                                            .foregroundStyle(.gray)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.primary)
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
                                            .foregroundStyle(selectedFileName == nil ? .gray : .black)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                    }
                                }
                                .onChange(of: pickerItem) { oldValue, newItem in
                                    Task {
                                        // 1. Ambil data gambar
                                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                            self.selectedImageData = data

                                            let formatter = DateFormatter()
                                            formatter.dateFormat = "yyyyMMdd_HHmm"
                                            let timestamp = formatter.string(from: Date())
                                            
                                            // Update State Nama File
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
            
            // MARK: - Navigation Bar
            .navigationTitle("Confirm Payment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // Helper untuk format rupiah
    private func formatRupiah(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return "Rp " + (formatter.string(from: NSNumber(value: amount)) ?? "0")
    }
}

enum PaymentMethod: String, CaseIterable{
    case transfer = "Bank Transfer"
    case cash = "Cash"
}

#Preview {
    PayNowView()
}
