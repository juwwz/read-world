import SwiftUI

struct BookStoreView: View {
    @State private var searchText = ""
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    
    // 计算屏幕顶部的安全区域高度
    private var safeAreaTopInset: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
    }
    
    // 动态字体大小的计算
    private var dynamicFontSize: CGFloat {
        UIScreen.main.bounds.width * 0.04 // 根据屏幕宽度动态设置字体大小，可根据需要调整比例
    }

    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return recommendedBooks
        } else {
            return recommendedBooks.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading) {
                    // 搜索框
                    TextField("Search Books", text: $searchText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    // 推荐书籍部分
                    Text("Recommended For You")
                        .font(.headline)
                        .padding([.horizontal, .top])

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(filteredBooks) { book in
                                NavigationLink(destination: CatalogView(book: book)) {
                                    VStack {
                                        Image(book.coverImage)
                                            .resizable()
                                            .frame(width: 100, height: 150)
                                            .cornerRadius(8)

                                        Text(book.title)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .frame(width: 100)
                                    }
                                    .padding(.leading, book == filteredBooks.first ? 20 : 0)
                                    .padding(.trailing, 10)
                                }
                            }
                        }
                    }

                    // 书籍分类部分
                    Text("Categories")
                        .font(.headline)
                        .padding([.horizontal, .top])

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(getCategories()) { category in
                                NavigationLink(destination: CategoriesView(
                                    category: category.name,
                                    books: getBooksForCategory(category: category.name)
                                )) {
                                    ZStack {
                                        Image(category.image)
                                            .resizable()
                                            .frame(width: 100, height: 150)
                                            .cornerRadius(8)
                                            .overlay(
                                                Text(category.name.capitalized)
                                                    .font(.system(size: dynamicFontSize)) // 动态字体大小
                                                    .bold()
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 8)
                                                    .background(Color.black.opacity(0.7))
                                                    .cornerRadius(5)
                                                    .offset(y: 40)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.white, lineWidth: 2)
                                            )
                                    }
                                }
                                .padding(.leading, category == getCategories().first ? 20 : 0)
                                .padding(.trailing, 10)
                            }
                        }
                    }

                    // 热门书籍部分
                    Text("Popular Books")
                        .font(.headline)
                        .padding([.horizontal, .top])

                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(popularBooks) { book in
                            NavigationLink(destination: CatalogView(book: book)) {
                                HStack {
                                    Image(book.coverImage)
                                        .resizable()
                                        .frame(width: 50, height: 75)
                                        .cornerRadius(8)

                                    VStack(alignment: .leading) {
                                        Text(book.title)
                                            .font(.headline)

                                        Text(book.author)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)

                                        Text(book.description)
                                            .font(.caption)
                                            .lineLimit(2)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.leading, 10)

                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.bottom, 10)
            }
            // 使用更精确的偏移量控制，避免页面上方空白过多
            .padding(.bottom, max(0, keyboardResponder.currentHeight - safeAreaTopInset - 100))
            .animation(.easeOut(duration: 0.3), value: keyboardResponder.currentHeight)
        }
    }
}

// Main View with TabBar
struct BookstoreViewWithBar: View {
    var body: some View {
        NavigationView {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                BookStoreView()
                    .tabItem {
                        Image(systemName: "book.fill")
                        Text("Bookstore")
                    }

                BookshelfView()
                    .tabItem {
                        Image(systemName: "books.vertical.fill")
                        Text("Bookshelf")
                    }

                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Profile")
                    }
            }
            .accentColor(.blue)
        }
    }
}


struct BookStoreView_Previews: PreviewProvider {
    static var previews: some View {
        BookstoreViewWithBar()
    }
}
