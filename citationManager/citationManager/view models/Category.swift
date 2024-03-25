//
//  Category.swift
//  citationManager
//
//  Created by Jort Boxelaar on 17/01/2024.
//

import Foundation

enum Category: Hashable, CaseIterable, Identifiable {
    case all
    case unread
    case read
    case favourites
    case readingList
    case authors
    case keywords
    case list(Collection)
    case tags(Tag)
    
    var id: String {
        switch self {
        case .all:
            "All"
        case .unread:
            "Unread"
        case .read:
            "Read"
        case .favourites:
            "Favourites"
        case .readingList:
            "Reading List"
        case .authors:
            "Authors"
        case .keywords:
            "Keywords"
        case .list(let PaperGroup):
            PaperGroup.id.uuidString
        case .tags(let TagGroup):
            TagGroup.id.uuidString
        }
    }
    
    func title() -> String {
        switch self {
        case .all:
            return "All"
        case .unread:
            return "Unread"
        case .read:
            return "Read"
        case .favourites:
            return "Favourites"
        case .readingList:
            return "Redaing List"
        case .authors:
            return "Authors"
        case .keywords:
            return "Keywords"
        case .list(let Group):
            return Group.title
        case .tags(let Group):
            return Group.title
        }
    }

    
    var iconName: String {
        switch self {
        case .all:
            "books.vertical"
        case .unread:
            "book.closed"
        case .read:
            "book"
        case .favourites:
            "star"
        case .readingList:
            "eyeglasses"
        case .authors:
            "person.2"
        case .keywords:
            "key.viewfinder"
        case .list(_):
            "folder"
        case .tags(_):
            "tag"
        }
    }

    
    static var allCases: [Category] {
        [.all, .unread, .read, .favourites, .readingList]
    }
    
    static var allCasesString: [String] {
        ["All", "Unread", "Read", "Favourites", "Reading List"]
    }
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id
    }
}
