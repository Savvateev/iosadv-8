//
//  InfoRow.swift
//  GreatWriter
//
//  Created by Pavel Savvateev on 27.10.2026.
//


import SwiftUI

struct InfoRow: View {
    let work: Work

    var body: some View {
        HStack(spacing: 12) {
            Image(work.resolvedImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 56, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 4) {
                Text(work.title)
                    .font(.headline)
                if let years = work.yearsNote {
                    Text(years)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        InfoRow(work: Work.seed[0])
        InfoRow(work: Work.seed[3])
    }
}
