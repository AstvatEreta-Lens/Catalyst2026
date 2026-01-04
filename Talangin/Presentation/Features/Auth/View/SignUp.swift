//
//  SignUP.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 02/01/26.
//

import SwiftUI

struct SignUp: View {
    // State untuk menampung input user
    @State private var fullName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) var dismiss // Untuk kembali ke halaman Login
    
    var body: some View {
        ScrollView { // Menggunakan ScrollView agar aman di iPhone layar kecil saat keyboard muncul
            VStack(spacing: 20) {
                
                // Header Singkat
                VStack(alignment: .leading, spacing: 8) {
                    Text("Buat Akun Baru")
                        .font(.largeTitle)
                        .bold()
                    Text("Lengkapi data di bawah ini untuk mendaftar.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                

                VStack(spacing: 16) {
                    AuthTextField(image: "person",
                                  placeholder: "Nama Lengkap",
                                  text: $fullName)
                    
                    AuthTextField(image: "envelope",
                                  placeholder: "Email",
                                  text: $email)
                        .keyboardType(.emailAddress)
                    
                    AuthTextField(image: "phone",
                                  placeholder: "Nomor HP",
                                  text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    AuthTextField(image: "lock",
                                  placeholder: "Password",
                                  text: $password,
                                  isSecure: true)
                    
                    AuthTextField(image: "lock.fill",
                                  placeholder: "Verifikasi Password",
                                  text: $confirmPassword,
                                  isSecure: true)
                }
                
                // Register Button
                Button(action: {

                    print("Mendaftar...")
                }) {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.top, 10)
                
                // Footer: Kembali ke Login
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Text("Sudah punya akun?")
                            .foregroundColor(.secondary)
                        Text("Login")
                            .fontWeight(.bold)
                    }
                    .font(.footnote)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 25)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignUp()
    }
}
