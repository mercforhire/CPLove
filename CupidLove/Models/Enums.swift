//
//  Enums.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-18.
//

import Foundation
import UIKit

enum UserTypeMode: Int, Codable {
    case normal
    case cupid
    case admin
    
    func themeColor() -> UIColor {
        switch self {
        case .normal:
            return ThemeManager.shared.themeData!.pink.hexColor
        case .cupid:
            return ThemeManager.shared.themeData!.blue.hexColor
        case .admin:
            return ThemeManager.shared.themeData!.blue.hexColor
        }
    }
    
    static func random() -> UserTypeMode {
        return UserTypeMode(rawValue: Int.random(in: 0...1))!
    }
}

extension UserTypeMode {
    init(from decoder: Decoder) throws {
        self = try UserTypeMode(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .normal
    }
}

enum Horoscopes: String, Codable {
    case ARIES
    case TAURUS
    case GEMINI
    case CANCER
    case LEO
    case VIRGO
    case LIBRA
    case SCORPIO
    case SAGITTARIUS
    case CAPRICORN
    case AQUARIUS
    case PISCES
    case UNKNOWN
    
    func title() -> String {
        switch self {
        case .AQUARIUS:
            return "Aquarius"
        case .PISCES:
            return "Pisces"
        case .ARIES:
            return "Aries"
        case .TAURUS:
            return "Taurus"
        case .GEMINI:
            return "Gemini"
        case .CANCER:
            return "Cancer"
        case .LEO:
            return "Leo"
        case .VIRGO:
            return "Virgo"
        case .LIBRA:
            return "Libra"
        case .SCORPIO:
            return "Scorpio"
        case .SAGITTARIUS:
            return "Sagittarius"
        case .CAPRICORN:
            return "Capricorn"
        case .UNKNOWN:
            return ""
        }
    }
    
    func selections() -> String {
        switch self {
        case .AQUARIUS:
            return "Aquarius (Jan 20 – Feb 18)"
        case .PISCES:
            return "Pisces (Feby 19 – Mar 20)"
        case .ARIES:
            return "Aries (Mar 21 – Apr 19)"
        case .TAURUS:
            return "Taurus (Apr 20 – May 20)"
        case .GEMINI:
            return "Gemini (May 21 – Jun 20)"
        case .CANCER:
            return "Cancer (Jun 21 – Jul 22)"
        case .LEO:
            return "Leo (Jul 23 – Aug 22)"
        case .VIRGO:
            return "Virgo (Aug 23 – Sept 22)"
        case .LIBRA:
            return "Libra (Sept 23 – Oct 22)"
        case .SCORPIO:
            return "Scorpio (Octo 23 – Nov 21)"
        case .SAGITTARIUS:
            return "Sagittarius (Nov 22 – Dec 21)"
        case .CAPRICORN:
            return "Capricorn (Dec 22 – Jan 19)"
        case .UNKNOWN:
            return "Unknown"
        }
    }
    
    static func getHoroscope(date: Date) -> Horoscopes {
        let calendar = Calendar.current
        let d = calendar.component(.day, from: date)
        let m = calendar.component(.month, from: date)

        switch (d,m) {
        case (21...31,1),(1...19,2):
            return .AQUARIUS
        case (20...29,2),(1...20,3):
            return .PISCES
        case (21...31,3),(1...20,4):
            return .ARIES
        case (21...30,4),(1...21,5):
            return .TAURUS
        case (22...31,5),(1...21,6):
            return .GEMINI
        case (22...30,6),(1...22,7):
            return .CANCER
        case (23...31,7),(1...22,8):
            return .LEO
        case (23...31,8),(1...23,9):
            return .VIRGO
        case (24...30,9),(1...23,10):
            return .LIBRA
        case (24...31,10),(1...22,11):
            return .SCORPIO
        case (23...30,11),(1...21,12):
            return .SAGITTARIUS
        default:
            return .CAPRICORN
        }
    }
    
    static func list() -> [Horoscopes] {
        return [.AQUARIUS, .PISCES, .ARIES, .TAURUS, .GEMINI, .CANCER, .LEO, .VIRGO, .LIBRA, .SCORPIO, .SAGITTARIUS, .CAPRICORN]
    }
}

extension Horoscopes {
    init(from decoder: Decoder) throws {
        self = try Horoscopes(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
    }
}

enum HeightSelections: Int, Codable {
    case height1
    case height2
    case height3
    case height4
    case height5
    case height6
    case height7
    case height8
    case height9
    case height10
    case height11
    case height12
    case height13
    case height14
    case height15
    case height16
    case height17
    case height18
    case height19
    case height20
    case height21
    case height22
    case height23
    case height24
    case height25
    case height26
    case height27
    case height28
    case height29
    case height30
    case height31
    case UNKNOWN
    
    func title() -> String {
        switch self {
        case .height1:
            return "4′4″ / 132 cm"
        case .height2:
            return "4′5″ / 135 cm"
        case .height3:
            return "4′6″ /137 cm"
        case .height4:
            return "4′7″ /140 cm"
        case .height5:
            return "4′8″ / 142 cm"
        case .height6:
            return "4′9″ / 145 cm"
        case .height7:
            return "4′10″ / 147 cm"
        case .height8:
            return "4′11″ / 150 cm"
        case .height9:
            return "5′ / 152 cm"
        case .height10:
            return "5′1″ / 155 cm"
        case .height11:
            return "5′2″ / 157 cm"
        case .height12:
            return "5′3″ / 160 cm"
        case .height13:
            return "5′4″ / 163 cm"
        case .height14:
            return "5′5″ / 165 cm"
        case .height15:
            return "5′6″ / 168 cm"
        case .height16:
            return "5′7″ / 170 cm"
        case .height17:
            return "5′8″ / 173 cm"
        case .height18:
            return "5′9″ / 175 cm"
        case .height19:
            return "5′10″ / 178 cm"
        case .height20:
            return "5′11″ / 180 cm"
        case .height21:
            return "6′ / 183 cm"
        case .height22:
            return "6′1″ / 185 cm"
        case .height23:
            return "6′2″ / 188 cm"
        case .height24:
            return "6′3″ / 190 cm"
        case .height25:
            return "6′4″ / 193 cm"
        case .height26:
            return "6′5″ / 196 cm"
        case .height27:
            return "6′6″ / 198 cm"
        case .height28:
            return "6′7″ / 201 cm"
        case .height29:
            return "6′8″ / 203 cm"
        case .height30:
            return "6′9″ / 206 cm"
        case .height31:
            return "6′10″ / 208 cm"
        case .UNKNOWN:
            return "Unknown"
        }
    }
    
    func height() -> Int {
        switch self {
        case .height1:
            return 132
        case .height2:
            return 135
        case .height3:
            return 137
        case .height4:
            return 140
        case .height5:
            return 142
        case .height6:
            return 145
        case .height7:
            return 147
        case .height8:
            return 150
        case .height9:
            return 152
        case .height10:
            return 155
        case .height11:
            return 157
        case .height12:
            return 160
        case .height13:
            return 163
        case .height14:
            return 165
        case .height15:
            return 168
        case .height16:
            return 170
        case .height17:
            return 173
        case .height18:
            return 175
        case .height19:
            return 178
        case .height20:
            return 180
        case .height21:
            return 183
        case .height22:
            return 185
        case .height23:
            return 188
        case .height24:
            return 190
        case .height25:
            return 193
        case .height26:
            return 196
        case .height27:
            return 198
        case .height28:
            return 201
        case .height29:
            return 203
        case .height30:
            return 206
        case .height31:
            return 208
        case .UNKNOWN:
            return 0
        }
    }
    
    static func getHeightFrom(heightCM: Int) -> HeightSelections {
        for i in HeightSelections.list() {
            if heightCM < i.height() {
                return i
            }
        }
        return .UNKNOWN
    }
    
    static func list() -> [HeightSelections] {
        return [.height1, .height2, .height3, .height4, .height5, .height6, .height7, .height8, .height9, .height10, .height11, .height12, .height13, .height14, .height15, .height16, .height17, .height18, .height19, .height20, .height21, .height22, .height23, .height24, .height25, .height26, .height27, .height28, .height29, .height30, .height31]
    }
}

extension HeightSelections {
    init(from decoder: Decoder) throws {
        self = try HeightSelections(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
    }
}

enum Incomes: Int, Codable {
    case unknown
    case income0k
    case income50k
    case income100k
    case income150k
    case income250k
    case income500k
    case incomeInfinite
    
    static func getIncomeRangeFrom(income: Int) -> [Incomes]? {
        if income >= 200000 {
            return [.income150k, .income250k]
        }
        
        if income >= 100000 && income < 200000 {
            return [.income100k, .income150k]
        }
        
        if income >= 50000 && income < 100000 {
            return [.income50k, .income100k]
        }
        
        if income < 50000 {
            return [.income0k, .income50k]
        }
        
        return nil
    }
    
    func shortTitle() -> String {
        switch self {
        case .income0k:
            return "0"
        case .income50k:
            return "50k"
        case .income100k:
            return "100k"
        case .income150k:
            return "150k"
        case .income250k:
            return "250k"
        case .income500k:
            return "500k"
        case .incomeInfinite:
            return "500k+"
        case .unknown:
            return "Prefer not to say"
        }
    }
    
    func title() -> String {
        switch self {
        case .income0k:
            return "No income"
        case .income50k:
            return "50k"
        case .income100k:
            return "100k"
        case .income150k:
            return "150k"
        case .income250k:
            return "250k"
        case .income500k:
            return "500k"
        case .incomeInfinite:
            return "500k+"
        case .unknown:
            return "Prefer not to say"
        }
    }
    
    func partnerTitle() -> String {
        switch self {
        case .income0k:
            return "Does not matter"
        case .income50k:
            return "50k"
        case .income100k:
            return "100k"
        case .income150k:
            return "150k"
        case .income250k:
            return "250k"
        case .income500k:
            return "500k"
        case .incomeInfinite:
            return "500k+"
        case .unknown:
            return "Prefer not to say"
        }
    }
    
    static func list() -> [Incomes] {
        return [.income0k, .income50k, .income100k, .income150k, .income250k, .income500k, .incomeInfinite, .unknown]
    }
    
    static func partnerSelections() -> [Incomes] {
        return [.income0k, .income50k, .income100k, .income150k, .income250k, .income500k, .incomeInfinite]
    }
    
    func float() -> Float {
        switch self {
        case .income0k:
            return 1.0
        case .income50k:
            return 2.0
        case .income100k:
            return 3.0
        case .income150k:
            return 4.0
        case .income250k:
            return 5.0
        case .income500k:
            return 6.0
        case .incomeInfinite:
            return 7.0
        case .unknown:
            return 0.0
        }
    }
    
    static func fromFloat(float: Float) -> Incomes {
        switch float {
        case 1.0:
            return .income0k
        case 2.0:
            return .income50k
        case 3.0:
            return .income100k
        case 4.0:
            return .income150k
        case 5.0:
            return .income250k
        case 6.0:
            return .income500k
        case 7.0:
            return .incomeInfinite
        default:
            return .unknown
        }
    }
    
    static func fromInt(int: Int) -> Incomes {
        switch int {
        case 1:
            return .income0k
        case 2:
            return .income50k
        case 3:
            return .income100k
        case 4:
            return .income150k
        case 5:
            return .income250k
        case 6:
            return .income500k
        case 7:
            return .incomeInfinite
        default:
            return .unknown
        }
    }
    
    static func ranges() -> [[Incomes]] {
        return [[.income0k, .income50k],
                [.income50k, .income100k],
                [.income100k, .income150k],
                [.income150k, .income250k],
                [.income250k, .income500k],
                [.incomeInfinite],
                [unknown]]
    }
    
    static func rangeText(range: [Incomes]) -> String {
        if range.count == 1 {
            return range.first!.title()
        }
        
        if range.count == 2 {
            if range.first! == range.last! {
                return "\(range.first!.title())"
            } else {
                return "\(range.first!.title()) - \(range.last!.title())"
            }
        }
        
        return ""
    }
}

extension Incomes {
    init(from decoder: Decoder) throws {
        self = try Incomes(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}

enum Ethnicities: String, Codable {
    case ASIAN
    case BLACK
    case HISPANIC
    case WHITE
    case MIDDLE_EASTERN
    case SOUTH_ASIAN
    case OTHER
    
    func title() -> String {
        switch self {
        case .ASIAN:
            return "Asian"
        case .BLACK:
            return "Black or African-American"
        case .HISPANIC:
            return "Hispanic or Latino"
        case .WHITE:
            return "White"
        case .MIDDLE_EASTERN:
            return "Middle Eastern"
        case .SOUTH_ASIAN:
            return "South Asian"
        case .OTHER:
            return "Other"
        }
    }
    
    static func list() -> [Ethnicities] {
        return [.ASIAN, .BLACK, .HISPANIC, .WHITE, .MIDDLE_EASTERN, .SOUTH_ASIAN, .OTHER]
    }
}

extension Ethnicities {
    init(from decoder: Decoder) throws {
        self = try Ethnicities(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .OTHER
    }
}

enum Religions: String, Codable {
    case BUDDHIST
    case CHRISTIAN
    case CATHOLIC
    case HINDU
    case MUSLIM
    case JEWISH
    case SIKH
    case OTHERS
    case NO_RELIGION
    case DOESNT_MATTER
    
    func title() -> String {
        switch self {
        case .BUDDHIST:
            return "Buddhist"
        case .CHRISTIAN:
            return "Christian"
        case .CATHOLIC:
            return "Catholic"
        case .HINDU:
            return "Hindu"
        case .MUSLIM:
            return "Muslim"
        case .JEWISH:
            return "Jewish"
        case .SIKH:
            return "Sikh"
        case .OTHERS:
            return "Others"
        case .NO_RELIGION:
            return "Atheist"
        case .DOESNT_MATTER:
            return "Any religion"
        }
    }
    
    static func list() -> [Religions] {
        return [.BUDDHIST, .CHRISTIAN, .CATHOLIC, .HINDU, .MUSLIM, .SIKH, .OTHERS, .NO_RELIGION, .DOESNT_MATTER]
    }
    
    static func partnerSelections() -> [Religions] {
        return [.BUDDHIST, .CHRISTIAN, .CATHOLIC, .HINDU, .MUSLIM, .SIKH, .OTHERS, .NO_RELIGION, .DOESNT_MATTER]
    }
    
    static func random() -> Religions {
        return Religions.list().randomElement()!
    }
}

extension Religions {
    init(from decoder: Decoder) throws {
        self = try Religions(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .NO_RELIGION
    }
}

enum GenderChoice: Int, Codable {
    case male
    case female
    case others
    
    func title() -> String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .others:
            return "Others"
        }
    }
    
    func casualTitle() -> String {
        switch self {
        case .male:
            return "man"
        case .female:
            return "woman"
        case .others:
            return "trans-gender"
        }
    }
    
    static func list() -> [GenderChoice] {
        return [.male, .female]
    }
    
    static func random() -> GenderChoice {
        return [.male, .female].randomElement()!
    }
}

extension GenderChoice {
    init(from decoder: Decoder) throws {
        self = try GenderChoice(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .male
    }
}

enum RelationshipTypes: String, Codable {
    case RELATIONSHIP
    case FRIENDSHIP
    case CASUAL
    case MARRIAGE
    case NOT_SURE

    func title() -> String {
        switch self {
        case .RELATIONSHIP:
            return "Relationship"
        case .FRIENDSHIP:
            return "Friendship"
        case .CASUAL:
            return "Something casual"
        case .MARRIAGE:
            return "Marriage"
        case .NOT_SURE:
            return "Not sure yet"
        }
    }
    
    static func list() -> [RelationshipTypes] {
        return [.RELATIONSHIP, .FRIENDSHIP, .CASUAL, .MARRIAGE, .NOT_SURE]
    }
}

extension RelationshipTypes {
    init(from decoder: Decoder) throws {
        self = try RelationshipTypes(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .RELATIONSHIP
    }
}

enum Assets: String, Codable {
    case HOUSE
    case CONDO
    case CAR
    case MOTORBIKE
    case YACHT
    case PLANE
    case UNKNOWN
    
    func title() -> String {
        switch self {
        case .HOUSE:
            return "House"
        case .CONDO:
            return "Condo"
        case .CAR:
            return "Car"
        case .MOTORBIKE:
            return "Motorcycle"
        case .YACHT:
            return "Yacht"
        case .PLANE:
            return "Plane"
        case .UNKNOWN:
            return "Unknown"
        }
    }
    
    static func list() -> [Assets] {
        return [.HOUSE, .CONDO, .CAR, .MOTORBIKE, .YACHT, .PLANE]
    }
}

extension Assets {
    init(from decoder: Decoder) throws {
        self = try Assets(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
    }
}

enum Siblings: Int, Codable {
    case onlyChild
    case brother
    case sister
    case brotherAndSister
    
    func title() -> String {
        switch self {
        case .onlyChild:
            return "Only child"
        case .brother:
            return "Brother(s)"
        case .sister:
            return "Sister(s)"
        case .brotherAndSister:
            return "Brother(s) & sister(s)"
        }
    }
    
    static func list() -> [Siblings] {
        return [.onlyChild, .brother, .sister, .brotherAndSister]
    }
}

extension Siblings {
    init(from decoder: Decoder) throws {
        self = try Siblings(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .onlyChild
    }
}

enum ChildPreference: Int, Codable {
    case want
    case doNotWant
    case notSure
    
    func title() -> String {
        switch self {
        case .want:
            return "Want a child"
        case .doNotWant:
            return "Do not want a child"
        case .notSure:
            return "Not sure"
        }
    }
    
    static func list() -> [ChildPreference] {
        return [.want, .doNotWant, .notSure]
    }
    
    static func random() -> ChildPreference {
        return Bool.random() ? .want : (Bool.random() ? .doNotWant : .notSure)
    }
}

extension ChildPreference {
    init(from decoder: Decoder) throws {
        self = try ChildPreference(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .want
    }
}

enum Personality: String, Codable {
    case ADVENTUROUS
    case ATHLETIC
    case CALM
    case COMPASSIONATE
    case COURAGEOUS
    case CREATIVE
    case DEDICATED
    case DISCIPLINED
    case ELOQUENT
    case EMPATHETIC
    case ENERGETIC
    case FAITHFUL
    case FREE_THINKING
    case GENTLE
    case GENEROUS
    case HARDWORKING
    case HONEST
    case LOGICAL
    case LOYAL
    case ORGANIZED
    case PATIENT
    case PLAYFUL
    case ROMANTIC
    case WARM
    case UNKNOWN
    
    static func list() -> [Personality] {
        return [.ADVENTUROUS, .ATHLETIC, .CALM, .COMPASSIONATE, .COURAGEOUS, .CREATIVE, .DEDICATED, .DISCIPLINED, .ELOQUENT, .EMPATHETIC, .ENERGETIC, .FAITHFUL, .FREE_THINKING, .GENTLE, .GENEROUS, .HARDWORKING, .HONEST, .LOGICAL, .LOYAL, .ORGANIZED, .PATIENT, .PLAYFUL, .ROMANTIC, .WARM]
    }
    
    func title() -> String {
        switch self {
        case .ADVENTUROUS:
            return "Adventurous"
        case .ATHLETIC:
            return "Athletic"
        case .CALM:
            return "Calm"
        case .COMPASSIONATE:
            return "Compassionate"
        case .COURAGEOUS:
            return "Courageous"
        case .CREATIVE:
            return "Creative"
        case .DEDICATED:
            return "Dedicated"
        case .DISCIPLINED:
            return "Disciplined"
        case .ELOQUENT:
            return "Eloquent"
        case .EMPATHETIC:
            return "Empathetic"
        case .ENERGETIC:
            return "Energetic"
        case .FAITHFUL:
            return "Faithful"
        case .FREE_THINKING:
            return "Freethinking"
        case .GENTLE:
            return  "Gentle"
        case .GENEROUS:
            return "Generous"
        case .HARDWORKING:
            return "Hardworking"
        case .HONEST:
            return "Honest"
        case .LOGICAL:
            return "Logical"
        case .LOYAL:
            return "Loyal"
        case .ORGANIZED:
            return "Organized"
        case .PATIENT:
            return "Patient"
        case .PLAYFUL:
            return "Playful"
        case .ROMANTIC:
            return "Romantic"
        case .WARM:
            return "Warm"
        case .UNKNOWN:
            return ""
        }
    }
}

extension Personality {
    init(from decoder: Decoder) throws {
        self = try Personality(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .UNKNOWN
    }
}

enum UserSortMethod: Int, Codable {
    case popularity
    case endorsement
    case nearest
    case active
}

enum CupidSortMethod: Int, Codable {
    case reputation
    case popularity
    case reference
    case active
}

enum CommentType: Int, Codable {
    case review
    case endorsement
}

extension CommentType {
    init(from decoder: Decoder) throws {
        self = try CommentType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .review
    }
}

enum Interests: String {
    case basketball
    case golf
    case running
    case soccer
    case volleyball
    case badminton
    case yoga
    case swimming
    case ice_skating
    case bowling
    case ice_hockey
    case cycling
    case hiking
    case camping
    case tennis
    case painting
    case drawing
    case calligraphy
    case poetry_writing
    case designing
    case pottery_ceramics
    case floral_design
    case photography
    case acting
    case fashion_design
    case sculpture
    case nail_art
    case reading
    case journaling
    case blogging
    case volunteering
    case listening_to_podcasts
    case learning_a_new_language
    case singing
    case dancing
    case piano
    case violin
    case trumpet
    case music
    case guitar
    case drum
    case saxophone
    case baseball_cards
    case magnets
    case LEGO_sets
    case postcards
    case autographed_items
    case sea_shells
    case cooking
    case baking
    case cocktail
    case BBQ_grilling
    case beer
    case wine
    case bingo
    case video_games
    case puzzles
    case chess
    case sukoku
    case board_games
    
    static func random() -> Interests {
        return [. basketball, . golf,. running,. soccer,. volleyball,. badminton,. yoga,. swimming,. ice_skating,. bowling,. ice_hockey,. cycling,. painting,. drawing,. calligraphy,. poetry_writing,. designing,. pottery_ceramics,. floral_design,. photography,. acting,. fashion_design,. sculpture,. nail_art,. reading,. journaling,. blogging,. volunteering,. listening_to_podcasts,. learning_a_new_language,. singing,. dancing,. piano,. violin,. trumpet,. music,. guitar,. drum,. saxophone,. baseball_cards,. magnets,. LEGO_sets,. postcards,. autographed_items,. sea_shells,. cooking,. baking,. cocktail,. BBQ_grilling,. beer,. wine,. bingo,. video_games,. puzzles,. chess,. sukoku,. board_games].randomElement()!
    }
    
    static func sports() -> [Interests] {
        return [. basketball, . golf,. running,. soccer,. volleyball,. badminton,. yoga,. swimming,. ice_skating,. bowling,. ice_hockey,. cycling, .hiking, .camping, .tennis]
    }
    
    static func arts() -> [Interests] {
        return [. painting,. drawing,. calligraphy,. poetry_writing,. designing,. pottery_ceramics,. floral_design,. photography,. acting,. fashion_design,. sculpture,. nail_art]
    }
    
    static func mental() -> [Interests] {
        return [.reading,. journaling,. blogging,. volunteering,. listening_to_podcasts,. learning_a_new_language]
    }

    static func music() -> [Interests] {
        return [.singing, . dancing,. piano,. violin,. trumpet,. music,. guitar,. drum,. saxophone]
    }
    
    static func collecting() -> [Interests] {
        return [.baseball_cards, .magnets, .LEGO_sets, .postcards, .autographed_items, .sea_shells]
    }
    
    static func food() -> [Interests] {
        return [.cooking, . baking,. cocktail, . BBQ_grilling, . beer, . wine]
    }
    
    static func games() -> [Interests] {
        return [.bingo, . video_games, . puzzles, . chess, . sukoku, . board_games]
    }
    
    func iconAndTitle() -> String {
        return self.icon() + self.title()
    }
    
    func title() -> String {
        switch self {
        case .basketball:
            return "Basketball"
        case .golf:
            return "Golf"
        case .running:
            return "Running"
        case .soccer:
            return "Soccer"
        case .volleyball:
            return "Volleyball"
        case .badminton:
            return "Badminton"
        case .yoga:
            return "Yoga"
        case .swimming:
            return "Swimming"
        case .ice_skating:
            return "Ice skating"
        case .bowling:
            return "Bowling"
        case .ice_hockey:
            return "Ice hockey"
        case .cycling:
            return "Cycling"
        case .painting:
            return "Painting"
        case .drawing:
            return "Drawing"
        case .calligraphy:
            return "Calligraphy"
        case .poetry_writing:
            return "Poetry writing"
        case .designing:
            return "Designing"
        case .pottery_ceramics:
            return "Pottery / ceramics"
        case .floral_design:
            return "Floral design"
        case .photography:
            return "Photography"
        case .acting:
            return "Acting"
        case .fashion_design:
            return "Fashion design"
        case .sculpture:
            return "Sculpture"
        case .nail_art:
            return "Nail art"
        case .reading:
            return "Reading"
        case .journaling:
            return "Journaling"
        case .blogging:
            return "Blogging"
        case .volunteering:
            return "Volunteering"
        case .listening_to_podcasts:
            return "Listening to podcasts"
        case .learning_a_new_language:
            return "Learning a new language"
        case .singing:
            return "Singing"
        case .dancing:
            return "Dancing"
        case .piano:
            return "Piano"
        case .violin:
            return "Violin"
        case .trumpet:
            return "Trumpet"
        case .music:
            return "Music"
        case .guitar:
            return "Guitar"
        case .drum:
            return "Drum"
        case .saxophone:
            return "Saxophone"
        case .baseball_cards:
            return "Baseball cards"
        case .magnets:
            return "Magnets"
        case .LEGO_sets:
            return "LEGO sets"
        case .postcards:
            return "Postcards"
        case .autographed_items:
            return "Autographed items"
        case .sea_shells:
            return "Sea shells"
        case .cooking:
            return "Cooking"
        case .baking:
            return "Baking"
        case .cocktail:
            return "Cocktail"
        case .BBQ_grilling:
            return "BBQ grilling"
        case .beer:
            return "Beer"
        case .wine:
            return "Wine"
        case .bingo:
            return "Bingo"
        case .video_games:
            return "Video games"
        case .puzzles:
            return "Puzzles"
        case .chess:
            return "Chess"
        case .sukoku:
            return "Sukoku"
        case .board_games:
            return "Board games"
        case .hiking:
            return "Hiking"
        case .camping:
            return "Camping"
        case .tennis:
            return "Tennis"
        }
    }
    
    func icon() -> String {
        switch self {
        case .basketball:
            return "🏀"
        case .golf:
            return "⛳"
        case .running:
            return "🏃"
        case .soccer:
            return ""
        case .volleyball:
            return "🏐"
        case .badminton:
            return "🏸"
        case .yoga:
            return "🧘"
        case .swimming:
            return "🏊"
        case .ice_skating:
            return "⛸️"
        case .bowling:
            return "🎳"
        case .ice_hockey:
            return "🏒"
        case .cycling:
            return "🚲"
        case .painting:
            return "🎨"
        case .drawing:
            return "🖍️"
        case .calligraphy:
            return "✒️"
        case .poetry_writing:
            return "✏️"
        case .designing:
            return "💻"
        case .pottery_ceramics:
            return "🏺"
        case .floral_design:
            return "💐"
        case .photography:
            return "📷"
        case .acting:
            return "🎭"
        case .fashion_design:
            return "👗"
        case .sculpture:
            return "🗿"
        case .nail_art:
            return "💅"
        case .reading:
            return "📖"
        case .journaling:
            return "✍️"
        case .blogging:
            return "⌨️"
        case .volunteering:
            return "🎗️"
        case .listening_to_podcasts:
            return "📻"
        case .learning_a_new_language:
            return "🗣️"
        case .singing:
            return "🎤"
        case .dancing:
            return "💃🏻"
        case .piano:
            return "🎹"
        case .violin:
            return "🎻"
        case .trumpet:
            return "🎺"
        case .music:
            return "🎶"
        case .guitar:
            return "🎸"
        case .drum:
            return "🥁"
        case .saxophone:
            return "🎷"
        case .baseball_cards:
            return "⚾"
        case .magnets:
            return "🧲"
        case .LEGO_sets:
            return "🧱"
        case .postcards:
            return "💌"
        case .autographed_items:
            return "✍️"
        case .sea_shells:
            return "🐚"
        case .cooking:
            return "🥘"
        case .baking:
            return "🧁"
        case .cocktail:
            return "🍸"
        case .BBQ_grilling:
            return "🍖"
        case .beer:
            return "🍺"
        case .wine:
            return "🍷"
        case .bingo:
            return "🎲"
        case .video_games:
            return "🎮"
        case .puzzles:
            return "🧩"
        case .chess:
            return "♟️"
        case .sukoku:
            return "🔟"
        case .board_games:
            return "🎰"
        case .hiking:
            return "🚶🏻"
        case .camping:
            return "🏕️"
        case .tennis:
            return "🎾"
        }
    }
}


enum ReportType: String {
    case ADVERTISER_SPAM
    case EXPLICIT_CONTENT
    case FAKE_PROFILE
    case FRAUD
    case OTHERS
    case PROFANITY_HARASSMENT
    
    func title() -> String {
        switch self {
        case .FAKE_PROFILE:
            return "Fake profile"
        case .ADVERTISER_SPAM:
            return "Advertiser/Spam"
        case .FRAUD:
            return "Fraud"
        case .EXPLICIT_CONTENT:
            return "Explicit Content"
        case .PROFANITY_HARASSMENT:
            return "Profanity/Harassment"
        case .OTHERS:
            return "Others"
        }
    }
    
    static func list() -> [ReportType] {
        return [.ADVERTISER_SPAM, .EXPLICIT_CONTENT, .FAKE_PROFILE, .FRAUD, .OTHERS]
    }
}


enum BodyTypes {
        case SKINNY
        case FIT
        case ATHLETIC
        case CURVY
        case CHUBBY
        case STRONG
        case FAT
    
    func title() -> String {
        switch self {
        case .SKINNY:
            return "Skinny"
        case .FIT:
            return "Fit"
        case .ATHLETIC:
            return "Athletic"
        case .CURVY:
            return "Curvy"
        case .CHUBBY:
            return "Chubby"
        case .STRONG:
            return "Strong"
        case .FAT:
            return "Fat"
        }
    }
    
    static func list() -> [BodyTypes] {
        return [.SKINNY, .FIT, .ATHLETIC, .CURVY, .CHUBBY, .STRONG, .FAT]
    }
}
