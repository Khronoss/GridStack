//
//  GridStack.swift
//
//  Created by Peter Minarik on 07.07.19.
//  Copyright © 2019 Peter Minarik. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
public struct GridStack<Content>: View where Content: View {
    public enum ViewWidth {
        case absolute(CGFloat)
        case automatic

        var isAutomatic: Bool {
            guard case .automatic = self else { return false }
            return true
        }

        var absoluteWidth: CGFloat? {
            guard case .absolute(let width) = self else { return nil }
            return width
        }
    }

    private let viewWidth: ViewWidth
    private let isScrollable: Bool
    private let minCellWidth: CGFloat
    private let spacing: CGFloat
    private let numItems: Int
    private let alignment: HorizontalAlignment
    private let content: (Int, CGFloat) -> Content
    private let gridCalculator = GridCalculator()

    public init(
        width: ViewWidth,
        isScrollable: Bool,
        minCellWidth: CGFloat,
        spacing: CGFloat,
        numItems: Int,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping (Int, CGFloat) -> Content
    ) {
        self.viewWidth = width
        self.isScrollable = isScrollable
        self.minCellWidth = minCellWidth
        self.spacing = spacing
        self.numItems = numItems
        self.alignment = alignment
        self.content = content
    }
    
    var items: [Int] {
        Array(0..<numItems).map { $0 }
    }
    
    public var body: some View {
        if viewWidth.isAutomatic {
            GeometryReader { geometry in
                self.innerGrid(width: geometry.size.width)
            }
        } else {
            self.innerGrid(width: viewWidth.absoluteWidth!)
        }
    }

    private func innerGrid(width: CGFloat) -> some View {
        InnerGrid(
            width: width,
            isScrollable: isScrollable,
            spacing: self.spacing,
            items: self.items,
            alignment: self.alignment,
            content: self.content,
            gridDefinition: self.gridCalculator.calculate(
                availableWidth: width,
                minimumCellWidth: self.minCellWidth,
                cellSpacing: self.spacing
            )
        )
    }
}

@available(iOS 13.0, OSX 10.15, tvOS 13.0, watchOS 6.0, *)
private struct InnerGrid<Content>: View where Content: View {
    
    private let width: CGFloat
    private let isScrollable: Bool
    private let spacing: CGFloat
    private let rows: [[Int]]
    private let alignment: HorizontalAlignment
    private let content: (Int, CGFloat) -> Content
    private let columnWidth: CGFloat
    
    init(
        width: CGFloat,
        isScrollable: Bool,
        spacing: CGFloat,
        items: [Int],
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: @escaping (Int, CGFloat) -> Content,
        gridDefinition: GridCalculator.GridDefinition
    ) {
        self.width = width
        self.isScrollable = isScrollable
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
        self.columnWidth = gridDefinition.columnWidth
        rows = items.chunked(into: gridDefinition.columnCount)
    }
    
    var body : some View {
        if isScrollable {
            ScrollView(.vertical) {
                gridView
            }
        } else {
            gridView
        }
    }

    private var gridView: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: self.spacing) {
                    ForEach(row, id: \.self) { item in
                        // Pass the index and the cell width to the content
                        self.content(item, self.columnWidth)
                            .frame(width: self.columnWidth)
                    }
                }.padding(.horizontal, self.spacing)
            }
        }
        .padding(.top, spacing)
        .frame(width: width)
    }
}
