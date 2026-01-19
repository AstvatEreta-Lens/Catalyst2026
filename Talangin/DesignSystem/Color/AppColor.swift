//
//  AppColor.swift
//  Talangin
//
//  Created by Ahmad Al Wabil on 06/01/26.
//
//  Semantic color definitions using ColorTokens for consistent theming.
//  Updated: Added comprehensive semantic colors for HIG compliance.
//
//  USAGE:
//  - Use AppColors for semantic meaning (e.g., AppColors.primary for main actions)
//  - ColorTokens contains raw color values
//  - AppColors provides context-aware color selection
//

import SwiftUI

enum AppColors {
    
    // MARK: - Brand Colors
    
    /// Primary brand color - used for main actions, links, selected states
    static var primary: Color {
        Color(light: ColorTokens.systemBlueLight, dark: ColorTokens.systemBlueDark)
    }
    
    /// Secondary brand color - water theme
    static var brandWater: Color {
        Color(light: ColorTokens.systemWaterLight, dark: ColorTokens.systemWaterDark)
    }
    
    /// Secondary brand color - olive/green theme
    static var brandOlive: Color {
        Color(light: ColorTokens.systemOliveLight, dark: ColorTokens.systemOliveDark)
    }
    
    /// Accent water color for highlights
    static var accentWater: Color {
        Color(light: ColorTokens.systemWater02Light, dark: ColorTokens.systemWater02Dark)
    }
    
    /// Accent olive color for highlights
    static var accentOlive: Color {
        Color(light: ColorTokens.systemOlive02Light, dark: ColorTokens.systemOlive02Dark)
    }
    
    // MARK: - Background Colors
    
    /// Primary background (white/black)
    static var backgroundPrimary: Color {
        Color(light: ColorTokens.systemBgPrimaryLight, dark: ColorTokens.systemBgPrimaryDark)
    }
    
    /// Secondary/grouped background
    static var backgroundSecondary: Color {
        Color(light: ColorTokens.systemBgSecondaryLight, dark: ColorTokens.systemBgSecondaryDark)
    }
    
    // MARK: - Label/Text Colors
    
    /// Primary text color
    static var labelPrimary: Color {
        Color(light: ColorTokens.systemLabelPrimaryLight, dark: ColorTokens.systemLabelPrimaryDark)
    }
    
    /// Secondary/subtitle text color
    static var labelSecondary: Color {
        Color(light: ColorTokens.systemLabelSecondaryLight, dark: ColorTokens.systemLabelSecondaryDark)
    }
    
    // MARK: - Gray Scale
    
    static var gray01: Color {
        Color(light: ColorTokens.systemGray01Light, dark: ColorTokens.systemGray01Dark)
    }
    
    static var gray02: Color {
        Color(light: ColorTokens.systemGray02Light, dark: ColorTokens.systemGray02Dark)
    }
    
    static var gray03: Color {
        Color(light: ColorTokens.systemGray03Light, dark: ColorTokens.systemGray03Dark)
    }
    
    static var gray04: Color {
        Color(light: ColorTokens.systemGray04Light, dark: ColorTokens.systemGray04Dark)
    }
    
    static var gray05: Color {
        Color(light: ColorTokens.systemGray05Light, dark: ColorTokens.systemGray05Dark)
    }
    
    static var gray06: Color {
        Color(light: ColorTokens.systemGray06Light, dark: ColorTokens.systemGray06Dark)
    }
    
    // MARK: - Feedback Colors
    
    /// Success state color (green)
    static var success: Color {
        Color(light: ColorTokens.systemGreenLight, dark: ColorTokens.systemGreenDark)
    }
    
    /// Error/destructive state color (red)
    static var error: Color {
        Color(light: ColorTokens.systemRedLight, dark: ColorTokens.systemRedDark)
    }
    
    /// Warning state color (yellow)
    static var warning: Color {
        Color(light: ColorTokens.systemYellowLight, dark: ColorTokens.systemYellowDark)
    }
    
    /// Info/link color (blue)
    static var info: Color {
        Color(light: ColorTokens.systemBlueLight, dark: ColorTokens.systemBlueDark)
    }
    
    // MARK: - Component Specific
    
    /// Badge background for premium/subscription status
    static var badgePremium: Color {
        Color(light: ColorTokens.systemWater02Light, dark: ColorTokens.systemWater02Dark)
    }
    
    /// Badge background for free account
    static var badgeFree: Color {
        Color(light: ColorTokens.systemOlive02Light, dark: ColorTokens.systemOlive02Dark)
    }
    
    /// Toggle tint color
    static var toggleTint: Color {
        Color(light: ColorTokens.systemGreenLight, dark: ColorTokens.systemGreenDark)
    }
}

// MARK: - Color Extension for Light/Dark Mode

extension Color {
    /// Creates a color that adapts to light/dark mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

// MARK: - ColorTokens Hex Initializer Fix

extension Color {
    /// Initialize Color from hex string (supports both # prefixed and plain hex)
    init(_ hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}
