//
//  AuthTextField.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 02/01/26.
//

import SwiftUI
import Foundation


struct AuthTextField: View {
    
    var image: String
    var placeholder: String
    @Binding var text: String
    var isSecure:Bool = false
    
    var body: some View {
        HStack{
            Image(systemName:image)
                .foregroundColor(.secondary)
                .frame(width:30)
            if isSecure {
                SecureField(placeholder, text: $text)
                
            }
            else {
                TextField(placeholder, text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    VStack {
        AuthTextField(image: "envelope", placeholder: "Email", text: .constant(""))
        AuthTextField(image: "lock", placeholder: "Password", text: .constant(""), isSecure: true)
    }
    .padding()
}
