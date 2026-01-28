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
        
        let a4Size = CGSize(width: 595, height: 842)
        
        // Use Documents directory for better persistence during sharing process
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let invoicesDirectory = documentsURL.appendingPathComponent("Invoices", isDirectory: true)
        
        // Ensure directory exists
        try? fileManager.createDirectory(at: invoicesDirectory, withIntermediateDirectories: true)
        
        // Clean filename: remove spaces and special characters, add timestamp
        let cleanGroupName = (group.name ?? "Group").components(separatedBy: .punctuationCharacters).joined().replacingOccurrences(of: " ", with: "_")
        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "Invoice_\(cleanGroupName)_\(timestamp).pdf"
        let fileURL = invoicesDirectory.appendingPathComponent(fileName)
        
        // Remove old file if exists
        try? fileManager.removeItem(at: fileURL)
        
        // Create PDF Context
        guard let consumer = CGDataConsumer(url: fileURL as CFURL),
              let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil) else {
            return nil
        }
        
        let membersPerPage = 4
        let totalMembers = memberSettlements.count
        let pageCount = max(1, Int(ceil(Double(totalMembers) / Double(membersPerPage))))
        
        for pageIndex in 0..<pageCount {
            let renderer = ImageRenderer(content: SpecificInvoicePage(
                group: group,
                memberSettlements: memberSettlements,
                pageIndex: pageIndex,
                membersPerPage: membersPerPage,
                pageCount: pageCount,
                generatedDate: Date()
            ))
            
            renderer.proposedSize = ProposedViewSize(a4Size)
            
            renderer.render { size, renderFunction in
                var mediaBox = CGRect(origin: .zero, size: a4Size)
                pdfContext.beginPage(mediaBox: &mediaBox)
                renderFunction(pdfContext)
                pdfContext.endPage()
            }
        }
        
        pdfContext.closePDF()
        
        // Verification: ensure file exists and is readable
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        return nil
    }
    
    static func generateInvoiceImage(
        group: GroupEntity,
        members: [FriendEntity],
        expenses: [ExpenseEntity]
    ) -> UIImage? {
        // ... (remaining image logic is fine, let's just make it consistent with the page count)
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
        
        let renderer = ImageRenderer(content: SpecificInvoicePage(
            group: group,
            memberSettlements: memberSettlements,
            pageIndex: 0,
            membersPerPage: 4,
            pageCount: 1,
            generatedDate: Date()
        ))
        
        renderer.proposedSize = ProposedViewSize(width: 595, height: 842)
        renderer.scale = 2.0
        
        return renderer.uiImage
    }
}

/// Helper view to render a single isolated page for the PDF generator
struct SpecificInvoicePage: View {
    let group: GroupEntity
    let memberSettlements: [(member: FriendEntity, summary: MemberSettlementSummary)]
    let pageIndex: Int
    let membersPerPage: Int
    let pageCount: Int
    let generatedDate: Date
    
    var body: some View {
        InvoiceDocumentView(
            group: group,
            memberSettlements: memberSettlements,
            generatedDate: Date()
        )
        .offset(y: -CGFloat(pageIndex) * 842)
        .frame(width: 595, height: 842, alignment: .top)
        .clipped()
    }
}
