import 'package:flutter/foundation.dart';
import 'package:pgme/core/models/book_model.dart';
import 'package:pgme/core/models/book_order_model.dart';
import 'package:pgme/core/models/zoho_payment_models.dart';
import 'package:pgme/core/services/book_service.dart';
import 'package:pgme/core/services/book_order_service.dart';

class BookProvider extends ChangeNotifier {
  final BookService _bookService = BookService();
  final BookOrderService _bookOrderService = BookOrderService();

  // Books state
  List<BookModel> _books = [];
  bool _isLoadingBooks = false;
  String? _booksError;
  PaginationInfo? _pagination;
  String? _currentCategory;
  String? _searchQuery;

  // Cart state
  final Map<String, CartItem> _cart = {};

  // Orders state
  List<BookOrderModel> _orders = [];
  bool _isLoadingOrders = false;
  String? _ordersError;

  // Getters
  List<BookModel> get books => _books;
  bool get isLoadingBooks => _isLoadingBooks;
  String? get booksError => _booksError;
  PaginationInfo? get pagination => _pagination;
  String? get currentCategory => _currentCategory;
  String? get searchQuery => _searchQuery;

  Map<String, CartItem> get cart => _cart;
  List<CartItem> get cartItems => _cart.values.toList();
  int get cartItemCount => _cart.values.fold(0, (sum, item) => sum + item.quantity);
  bool get isCartEmpty => _cart.isEmpty;

  List<BookOrderModel> get orders => _orders;
  bool get isLoadingOrders => _isLoadingOrders;
  String? get ordersError => _ordersError;

  /// Calculate cart subtotal
  int get cartSubtotal {
    return _cart.values.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Calculate shipping cost (flat rate for now)
  int get shippingCost => _cart.isNotEmpty ? 50 : 0;

  /// Calculate cart total
  int get cartTotal => cartSubtotal + shippingCost;

  /// Load books from API
  Future<void> loadBooks({
    String? category,
    String? search,
    int page = 1,
    bool refresh = false,
  }) async {
    if (_isLoadingBooks && !refresh) return;

    _isLoadingBooks = true;
    _booksError = null;
    if (refresh || page == 1) {
      _books = [];
    }
    notifyListeners();

    try {
      _currentCategory = category;
      _searchQuery = search;

      final response = await _bookService.getBooks(
        category: category,
        search: search,
        page: page,
      );

      if (page == 1 || refresh) {
        _books = response.books;
      } else {
        _books.addAll(response.books);
      }
      _pagination = response.pagination;
    } catch (e) {
      _booksError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingBooks = false;
      notifyListeners();
    }
  }

  /// Load more books (pagination)
  Future<void> loadMoreBooks() async {
    if (_pagination == null || !_pagination!.hasNext || _isLoadingBooks) return;

    await loadBooks(
      category: _currentCategory,
      search: _searchQuery,
      page: _pagination!.currentPage + 1,
    );
  }

  /// Search books
  Future<void> searchBooks(String query) async {
    if (query.trim().isEmpty) {
      await loadBooks(refresh: true);
      return;
    }
    await loadBooks(search: query, refresh: true);
  }

  /// Filter by category
  Future<void> filterByCategory(String? category) async {
    await loadBooks(category: category, refresh: true);
  }

  /// Add item to cart
  void addToCart(BookModel book, {int quantity = 1}) {
    if (_cart.containsKey(book.bookId)) {
      _cart[book.bookId]!.quantity += quantity;
    } else {
      _cart[book.bookId] = CartItem(
        bookId: book.bookId,
        title: book.title,
        author: book.author,
        thumbnailUrl: book.thumbnailUrl,
        price: book.actualPrice,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  /// Remove item from cart
  void removeFromCart(String bookId) {
    _cart.remove(bookId);
    notifyListeners();
  }

  /// Update cart item quantity
  void updateCartQuantity(String bookId, int quantity) {
    if (!_cart.containsKey(bookId)) return;

    if (quantity <= 0) {
      _cart.remove(bookId);
    } else {
      _cart[bookId]!.quantity = quantity;
    }
    notifyListeners();
  }

  /// Increment cart item quantity
  void incrementQuantity(String bookId) {
    if (_cart.containsKey(bookId)) {
      _cart[bookId]!.quantity++;
      notifyListeners();
    }
  }

  /// Decrement cart item quantity
  void decrementQuantity(String bookId) {
    if (_cart.containsKey(bookId)) {
      if (_cart[bookId]!.quantity > 1) {
        _cart[bookId]!.quantity--;
      } else {
        _cart.remove(bookId);
      }
      notifyListeners();
    }
  }

  /// Clear cart
  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  /// Check if book is in cart
  bool isInCart(String bookId) {
    return _cart.containsKey(bookId);
  }

  /// Get cart item quantity for a book
  int getCartQuantity(String bookId) {
    return _cart[bookId]?.quantity ?? 0;
  }

  /// Get cart items as order items format
  List<Map<String, dynamic>> getCartAsOrderItems() {
    return _cart.values.map((item) => item.toOrderItem()).toList();
  }

  /// Create order (with Razorpay)
  Future<BookOrderResponse> createOrder({
    required String recipientName,
    required String shippingPhone,
    required String shippingAddress,
  }) async {
    final items = getCartAsOrderItems();
    return await _bookOrderService.createOrder(
      items: items,
      recipientName: recipientName,
      shippingPhone: shippingPhone,
      shippingAddress: shippingAddress,
    );
  }

  /// Verify payment
  Future<PaymentVerifyResponse> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final response = await _bookOrderService.verifyPayment(
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );

    // Clear cart on successful payment
    if (response.success) {
      clearCart();
    }

    return response;
  }

  /// Create test order (bypasses Razorpay)
  Future<Map<String, dynamic>> createTestOrder({
    required String recipientName,
    required String shippingPhone,
    required String shippingAddress,
  }) async {
    final items = getCartAsOrderItems();
    final response = await _bookOrderService.createTestOrder(
      items: items,
      recipientName: recipientName,
      shippingPhone: shippingPhone,
      shippingAddress: shippingAddress,
    );

    // Clear cart on successful order
    if (response['success'] == true) {
      clearCart();
    }

    return response;
  }

  // ============================================================================
  // ZOHO PAYMENTS METHODS
  // ============================================================================

  /// Create Zoho payment session for book order
  Future<ZohoPaymentSession> createPaymentSession({
    required String recipientName,
    required String shippingPhone,
    required String shippingAddress,
  }) async {
    final items = getCartAsOrderItems();
    return await _bookOrderService.createPaymentSession(
      items: items,
      recipientName: recipientName,
      shippingPhone: shippingPhone,
      shippingAddress: shippingAddress,
    );
  }

  /// Verify Zoho payment for book order
  Future<ZohoVerificationResponse> verifyZohoPayment({
    required String paymentSessionId,
    required String paymentId,
    String? signature,
  }) async {
    final result = await _bookOrderService.verifyZohoPayment(
      paymentSessionId: paymentSessionId,
      paymentId: paymentId,
      signature: signature,
    );

    // Clear cart on successful payment
    if (result.success) {
      clearCart();
    }

    return result;
  }

  /// Load user's orders
  Future<void> loadOrders({bool refresh = false}) async {
    if (_isLoadingOrders && !refresh) return;

    _isLoadingOrders = true;
    _ordersError = null;
    if (refresh) {
      _orders = [];
    }
    notifyListeners();

    try {
      _orders = await _bookOrderService.getUserOrders();
    } catch (e) {
      _ordersError = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  /// Get order by ID
  Future<BookOrderModel> getOrderById(String orderId) async {
    return await _bookOrderService.getOrderById(orderId);
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId) async {
    await _bookOrderService.cancelOrder(orderId);
    // Refresh orders list
    await loadOrders(refresh: true);
  }

  /// Clear all state
  void clearAll() {
    _books = [];
    _booksError = null;
    _pagination = null;
    _currentCategory = null;
    _searchQuery = null;
    _cart.clear();
    _orders = [];
    _ordersError = null;
    notifyListeners();
  }
}
