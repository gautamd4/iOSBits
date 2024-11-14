import CoreSpotlight
import MobileCoreServices
import Foundation

class CharityCategory: Codable {
    let id: Int
    let nameEn: String
    let nameFr: String
    let slug: String
    let parentCatId: Int?
    let subcategories: [CharityCategory]?
}

class CharityCategoryManager {
    
    init() {
        if let categories = loadCharityCategories() {
            // Print the filtered categories
            categories.forEach { category in
                print("ID: \(category.id), Name (EN): \(category.nameEn), Name (FR): \(category.nameFr), Slug: \(category.slug)")
                self.index(charityCat: category)
            }
        }
    }
    
    func subCategoriesDesc(category: CharityCategory) -> String {
        var desc = ""
        category.subcategories?.forEach { sub in
           desc = desc + sub.nameEn + ", "
        }
        return desc
    }
    
    func index(charityCat: CharityCategory) {
        let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        searchableItemAttributeSet.title = "Donate to " + charityCat.nameEn
        searchableItemAttributeSet.contentDescription = subCategoriesDesc(category: charityCat)
        
        let searchableItem = CSSearchableItem(uniqueIdentifier: String("\(charityCat.id)"), domainIdentifier: "com.ourApp.charity", attributeSet: searchableItemAttributeSet)
        
        CSSearchableIndex.default().indexSearchableItems([searchableItem]) { error in
            if let error = error {
                print("Error indexing item: \(error.localizedDescription)")
            } else {
                print("Successfully indexed article: \(charityCat.nameEn)")
            }
        }
    }
    
    func loadCharityCategories() -> [CharityCategory]? {
        // Replace "charity_categories" with the actual name of your JSON file (without the .json extension)
        guard let url = Bundle.main.url(forResource: "categoriesAndSubCategories", withExtension: "json") else {
            print("JSON file not found.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let categories = try decoder.decode([CharityCategory].self, from: data)
            return categories
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}
