//
//  InvoiceGenerator.swift
//  Talangin
//
//  Created by System on 26/01/26.
//

import SwiftUI
import PDFKit

/// Service to generate invoice PDF from group settlement data
@MainActor
class InvoiceGenerator {
    
    /// Generate invoice PDF for a group
    static func generateInvoicePDF(
        group: GroupEntity,
        members: [FriendEntity],
        expenses: [ExpenseEntity]
    ) async -> URL? {
        
        // Calculate settlements for all members
        var memberSettlements: [(member: FriendEntity, summary: MemberSettlementSummary)] = []
        
        for member in members {
            let summary = SettlementCalculator.calculateSettlementSummary(
                for: member.id ?? UUID(),
                memberName: member.fullName ?? "Unknown",
                memberInitials: member.avatarInitials,
                expenses: expenses,
                allMembers: members
            )
            memberSettlements.append((member, summary))
        }
        
        // Create invoice view
        let invoiceView = InvoiceDocumentView(
            group: group,
            memberSettlements: memberSettlements,
            generatedDate: Date()
        )
        
        // Render to PDF
        let renderer = ImageRenderer(content: invoiceView)
        
        // A4 size in points (595 x 842)
        let a4Size = CGSize(width: 595, height: 842)
        renderer.proposedSize = ProposedViewSize(a4Size)
        
        // Create temporary file URL
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "Invoice_\(group.name ?? "Group")_\(Date().timeIntervalSince1970).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        // Render to PDF
        guard let consumer = CGDataConsumer(url: fileURL as CFURL),
              let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            return nil
        }
        
        renderer.render { size, renderFunction in
            var mediaBox = CGRect(origin: .zero, size: a4Size)
            
            pdfContext.beginPage(mediaBox: &mediaBox)
            renderFunction(pdfContext)
            pdfContext.endPage()
            pdfContext.closePDF()
        }
        
        return fileURL
    }
    
    /// Generate invoice PNG image for a group
    static func generateInvoiceImage(
        group: GroupEntity,
        members: [FriendEntity],
        expenses: [ExpenseEntity]
    ) -> UIImage? {
        
        // Calculate settlements for all members
        var memberSettlements: [(member: FriendEntity, summary: MemberSettlementSummary)] = []
        
        for member in members {
            let summary = SettlementCalculator.calculateSettlementSummary(
                for: member.id ?? UUID(),
                memberName: member.fullName ?? "Unknown",
                memberInitials: member.avatarInitials,
                expenses: expenses,
                allMembers: members
            )
            memberSettlements.append((member, summary))
        }
        
        // Create invoice view
        let invoiceView = InvoiceDocumentView(
            group: group,
            memberSettlements: memberSettlements,
            generatedDate: Date()
        )
        
        // Render to image
        let renderer = ImageRenderer(content: invoiceView)
        
        // A4 size in points (595 x 842) at 2x scale for better quality
        let a4Size = CGSize(width: 595, height: 842)
        renderer.proposedSize = ProposedViewSize(a4Size)
        renderer.scale = 2.0
        
        return renderer.uiImage
    }
}
