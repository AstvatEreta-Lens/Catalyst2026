//
//  Color.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 04/01/26.
//

//Dokumentasi semua kode warna yang dipakai tulis sini untuk constanta warna, open to change sesuaikan dengan design di figma

import SwiftUI

enum ColorTokens {

    // MARK: - BRAND
    
    // SystemWater
    static let systemWaterLight = Color( "#D6EDF5")
    static let systemWaterDark = Color( "#244975")
    static let systemWater02Light = Color( "#3C79C3")
    static let systemWater02Dark = Color( "#59CDF5")
    
    // SystemOlive
    static let systemOliveLight = Color( "#DFEEC9")
    static let systemOliveDark = Color( "#3C5111")
    static let systemOlive02Light = Color( "#99CA4C")
    static let systemOlive02Dark = Color( "#7BA426")
    

    // MARK: - NEUTRAL
    
    // SystemBackground - Primary
    static let systemBgPrimaryLight = Color( "#FFFFFF")
    static let systemBgPrimaryDark = Color( "#000000")
    
    // SystemBackground - Secondary
    static let systemBgSecondaryLight = Color( "#EFF0F3")
    static let systemBgSecondaryDark = Color( "#1C1C1E")
    
    // SystemLabel - Primary
    static let systemLabelPrimaryLight = Color( "#000000")
    static let systemLabelPrimaryDark = Color( "#FFFFFF")
    
    // SystemLabel - Secondary
    static let systemLabelSecondaryLight = Color( "#8A8A8E")
    static let systemLabelSecondaryDark = Color( "#98989F")
    
    // SystemGray
    static let systemGray01Light = Color( "#8E8E93")
    static let systemGray01Dark = Color( "#8E8E93")
    
    static let systemGray02Light = Color( "#AEAEB2")
    static let systemGray02Dark = Color( "#636366")
    
    static let systemGray03Light = Color( "#C7C7CC")
    static let systemGray03Dark = Color( "#48484A")
    
    static let systemGray04Light = Color( "#D1D1D6")
    static let systemGray04Dark = Color( "#3A3A3C")
    
    static let systemGray05Light = Color( "#E5E5EA")
    static let systemGray05Dark = Color( "#1C1C1E")
    
    static let systemGray06Light = Color( "#F2F2F7")
    static let systemGray06Dark = Color( "#1C1C1E")
    
    
    // MARK: - FEEDBACK
    
    // SystemBlue
    static let systemBlueLight = Color( "#007AFF")
    static let systemBlueDark = Color( "#0A84FF")
    static let systemBlue02Light = Color( "#007AFF").opacity(0.15)
    static let systemBlue02Dark = Color( "#0A84FF").opacity(0.15)
    
    // SystemGreen
    static let systemGreenLight = Color( "#34C759")
    static let systemGreenDark = Color( "#30D158")
    
    // SystemRed
    static let systemRedLight = Color( "#FF3B30")
    static let systemRedDark = Color( "#FF453A")

    // SystemYellow
    static let systemYellowLight = Color( "#FFCC00")
    static let systemYellowDark = Color( "#FFD60A")
}
