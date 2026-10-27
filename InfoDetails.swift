//
//  InfoDetails.swift
//  GreatWriter
//
//  Created by Pavel Savvateev on 27.10.2026.
//


import SwiftUI

struct InfoDetails: View {
    let work: Work
    let adaptations: [Adaptation]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(work.resolvedImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Text(work.title)
                    .font(.title)
                    .bold()

                Text(work.genre.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let years = work.yearsNote {
                    infoBlock("Годы", years)
                }
                if let cycle = work.cycle {
                    infoBlock("Цикл", cycle)
                }
                if let note = work.note {
                    infoBlock("Примечание", note)
                }

                if !work.awards.isEmpty {
                    sectionTitle("Награды и премии")
                    ForEach(work.awards, id: \.self) { award in
                        Text("• \(award.name), \(award.year)")
                    }
                }

                if !adaptations.isEmpty {
                    sectionTitle("Экранизации")
                    ForEach(adaptations, id: \.self) { film in
                        Text("• \(film.year), «\(film.title)», реж. \(film.director)")
                    }
                }
            }
            .padding()
        }
        .navigationTitle(work.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoBlock(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .padding(.top, 8)
    }
}

#Preview {
    NavigationView {
        InfoDetails(work: Work.seed[2], adaptations: [])
    }
}
