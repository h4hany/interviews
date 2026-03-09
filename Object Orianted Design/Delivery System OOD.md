### Object-Oriented Design for Delivery System (Toters/Uber Eats Style)

## Overview

This document outlines the object-oriented design for a delivery application system. The design follows SOLID principles and incorporates various design patterns to ensure maintainability, scalability, and extensibility.

## Core Classes and Relationships

### **1. User Management Classes**

#### **User (Abstract Base Class)**
```ruby
class User
  attr_accessor :id, :name, :email, :phone, :address, :created_at
  
  def initialize(id, name, email, phone, address)
    @id = id
    @name = name
    @email = email
    @phone = phone
    @address = address
    @created_at = Time.now
  end
  
  def authenticate(password)
    raise NotImplementedError, 'Subclass must implement authenticate'
  end
  
  def update_profile(attributes)
    # Common profile update logic
  end
end
```

#### **Customer (Inherits from User)**
```ruby
class Customer < User
  attr_accessor :payment_methods, :favorite_restaurants, :order_history
  
  def initialize(id, name, email, phone, address)
    super(id, name, email, phone, address)
    @payment_methods = []
    @favorite_restaurants = []
    @order_history = []
  end
  
  def place_order(restaurant, items)
    order = OrderFactory.create_order(self, restaurant, items)
    @order_history << order
    order
  end
  
  def add_favorite_restaurant(restaurant)
    @favorite_restaurants << restaurant unless @favorite_restaurants.include?(restaurant)
  end
  
  def rate_order(order, rating, review)
    order.add_rating(rating, review)
  end
end
```

#### **Driver (Inherits from User)**
```ruby
class Driver < User
  attr_accessor :vehicle, :license_number, :status, :current_location, :earnings, :rating
  
  def initialize(id, name, email, phone, address, vehicle, license_number)
    super(id, name, email, phone, address)
    @vehicle = vehicle
    @license_number = license_number
    @status = :offline  # :offline, :available, :busy
    @current_location = nil
    @earnings = 0.0
    @rating = 0.0
    @active_orders = []
  end
  
  def go_online
    @status = :available
    DriverLocationTracker.instance.update_driver_location(self)
  end
  
  def go_offline
    @status = :offline
    DriverLocationTracker.instance.remove_driver(self)
  end
  
  def accept_order(order)
    if @status == :available && order.status == :pending_assignment
      @status = :busy
      @active_orders << order
      order.assign_driver(self)
    else
      raise "Cannot accept order: Driver not available or order not pending"
    end
  end
  
  def update_location(latitude, longitude)
    @current_location = Location.new(latitude, longitude)
    DriverLocationTracker.instance.update_driver_location(self)
  end
  
  def complete_delivery(order)
    @active_orders.delete(order)
    @earnings += order.delivery_fee
    @status = :available if @active_orders.empty?
  end
end
```

#### **RestaurantOwner (Inherits from User)**
```ruby
class RestaurantOwner < User
  attr_accessor :restaurants
  
  def initialize(id, name, email, phone, address)
    super(id, name, email, phone, address)
    @restaurants = []
  end
  
  def add_restaurant(restaurant)
    @restaurants << restaurant
    restaurant.owner = self
  end
  
  def update_menu(restaurant, menu_item, attributes)
    restaurant.update_menu_item(menu_item, attributes)
  end
end
```

### **2. Restaurant Management Classes**

#### **Restaurant**
```ruby
class Restaurant
  attr_accessor :id, :name, :cuisine_type, :location, :rating, :menu, :owner, 
                :operating_hours, :is_active, :delivery_zones
  
  def initialize(id, name, cuisine_type, location, owner)
    @id = id
    @name = name
    @cuisine_type = cuisine_type
    @location = location
    @owner = owner
    @rating = 0.0
    @menu = Menu.new
    @operating_hours = {}
    @is_active = true
    @delivery_zones = []
    @orders = []
  end
  
  def add_menu_item(item)
    @menu.add_item(item)
  end
  
  def update_availability(item, available)
    @menu.update_item_availability(item, available)
  end
  
  def receive_order(order)
    @orders << order
    order.status = :confirmed
    notify_kitchen(order)
  end
  
  def prepare_order(order)
    order.status = :preparing
  end
  
  def mark_order_ready(order)
    order.status = :ready_for_pickup
    notify_driver_service(order)
  end
  
  private
  
  def notify_kitchen(order)
    # Notify kitchen staff
  end
  
  def notify_driver_service(order)
    # Notify driver matching service
  end
end
```

#### **Menu**
```ruby
class Menu
  attr_accessor :items, :categories
  
  def initialize
    @items = []
    @categories = []
  end
  
  def add_item(item)
    @items << item
    add_category_if_new(item.category)
  end
  
  def get_items_by_category(category)
    @items.select { |item| item.category == category && item.available? }
  end
  
  def update_item_availability(item, available)
    item.available = available
  end
  
  private
  
  def add_category_if_new(category)
    @categories << category unless @categories.include?(category)
  end
end
```

#### **MenuItem**
```ruby
class MenuItem
  attr_accessor :id, :name, :description, :price, :category, :available, :image_url, :preparation_time
  
  def initialize(id, name, description, price, category, preparation_time = 15)
    @id = id
    @name = name
    @description = description
    @price = price
    @category = category
    @available = true
    @image_url = nil
    @preparation_time = preparation_time
  end
  
  def available?
    @available
  end
end
```

### **3. Order Management Classes**

#### **Order**
```ruby
class Order
  attr_accessor :id, :customer, :restaurant, :items, :status, :total_amount, 
                :delivery_address, :driver, :created_at, :estimated_delivery_time,
                :rating, :review
  
  def initialize(id, customer, restaurant, items, delivery_address)
    @id = id
    @customer = customer
    @restaurant = restaurant
    @items = items
    @delivery_address = delivery_address
    @status = :pending  # :pending, :confirmed, :preparing, :ready_for_pickup, 
                        # :out_for_delivery, :delivered, :cancelled
    @total_amount = calculate_total
    @driver = nil
    @created_at = Time.now
    @estimated_delivery_time = nil
    @rating = nil
    @review = nil
  end
  
  def calculate_total
    subtotal = @items.sum { |item| item.price * item.quantity }
    delivery_fee = calculate_delivery_fee
    tax = calculate_tax(subtotal)
    subtotal + delivery_fee + tax
  end
  
  def assign_driver(driver)
    @driver = driver
    @status = :out_for_delivery
    update_estimated_delivery_time
  end
  
  def update_status(new_status)
    @status = new_status
    notify_customer if should_notify_customer?(new_status)
  end
  
  def cancel(reason)
    if can_cancel?
      @status = :cancelled
      process_refund if payment_processed?
      notify_parties
    else
      raise "Order cannot be cancelled at current status: #{@status}"
    end
  end
  
  def add_rating(rating, review)
    @rating = rating
    @review = review
    update_restaurant_rating
    update_driver_rating if @driver
  end
  
  private
  
  def calculate_delivery_fee
    # Distance-based calculation
    DistanceCalculator.calculate(@restaurant.location, @delivery_address) * 0.5
  end
  
  def calculate_tax(subtotal)
    subtotal * 0.1  # 10% tax
  end
  
  def can_cancel?
    [:pending, :confirmed, :preparing].include?(@status)
  end
  
  def payment_processed?
    # Check if payment was processed
  end
  
  def process_refund
    PaymentProcessor.refund(self)
  end
  
  def update_estimated_delivery_time
    # Calculate ETA based on driver location and route
    @estimated_delivery_time = RouteOptimizer.calculate_eta(@driver.current_location, 
                                                             @restaurant.location, 
                                                             @delivery_address)
  end
  
  def should_notify_customer?(status)
    [:confirmed, :preparing, :ready_for_pickup, :out_for_delivery, :delivered].include?(status)
  end
  
  def notify_customer
    NotificationService.send_order_update(@customer, self)
  end
  
  def notify_parties
    NotificationService.send_order_cancellation(@customer, @restaurant, @driver, self)
  end
  
  def update_restaurant_rating
    @restaurant.update_rating(@rating)
  end
  
  def update_driver_rating
    @driver.update_rating(@rating)
  end
end
```

#### **OrderItem**
```ruby
class OrderItem
  attr_accessor :menu_item, :quantity, :special_instructions, :price
  
  def initialize(menu_item, quantity, special_instructions = "")
    @menu_item = menu_item
    @quantity = quantity
    @special_instructions = special_instructions
    @price = menu_item.price * quantity
  end
end
```

### **4. Location and Tracking Classes**

#### **Location**
```ruby
class Location
  attr_accessor :latitude, :longitude, :address, :city, :zip_code
  
  def initialize(latitude, longitude, address = nil, city = nil, zip_code = nil)
    @latitude = latitude
    @longitude = longitude
    @address = address
    @city = city
    @zip_code = zip_code
  end
  
  def distance_to(other_location)
    DistanceCalculator.calculate(self, other_location)
  end
end
```

#### **DriverLocationTracker (Singleton)**
```ruby
require 'singleton'

class DriverLocationTracker
  include Singleton
  
  attr_accessor :driver_locations
  
  def initialize
    @driver_locations = {}  # {driver_id => Location}
  end
  
  def update_driver_location(driver)
    @driver_locations[driver.id] = driver.current_location
    broadcast_location_update(driver)
  end
  
  def remove_driver(driver)
    @driver_locations.delete(driver.id)
  end
  
  def find_nearby_drivers(location, radius_km = 5)
    @driver_locations.select do |driver_id, driver_location|
      location.distance_to(driver_location) <= radius_km
    end.keys
  end
  
  private
  
  def broadcast_location_update(driver)
    # Broadcast to customers tracking their orders
    LocationUpdateBroadcaster.broadcast(driver)
  end
end
```

### **5. Payment Classes**

#### **Payment (Abstract Base Class)**
```ruby
class Payment
  attr_accessor :id, :order, :amount, :status, :transaction_id, :created_at
  
  def initialize(id, order, amount)
    @id = id
    @order = order
    @amount = amount
    @status = :pending  # :pending, :processing, :completed, :failed, :refunded
    @transaction_id = nil
    @created_at = Time.now
  end
  
  def process
    raise NotImplementedError, 'Subclass must implement process'
  end
  
  def refund
    raise NotImplementedError, 'Subclass must implement refund'
  end
end
```

#### **CreditCardPayment (Strategy Pattern)**
```ruby
class CreditCardPayment < Payment
  attr_accessor :card_number, :cardholder_name, :expiry_date, :cvv
  
  def initialize(id, order, amount, card_number, cardholder_name, expiry_date, cvv)
    super(id, order, amount)
    @card_number = card_number
    @cardholder_name = cardholder_name
    @expiry_date = expiry_date
    @cvv = cvv
  end
  
  def process
    @status = :processing
    result = PaymentGateway.process_credit_card(self)
    if result.success?
      @status = :completed
      @transaction_id = result.transaction_id
    else
      @status = :failed
      raise PaymentError, result.error_message
    end
  end
  
  def refund
    @status = :refunded
    PaymentGateway.refund_credit_card(@transaction_id, @amount)
  end
end
```

#### **DigitalWalletPayment (Strategy Pattern)**
```ruby
class DigitalWalletPayment < Payment
  attr_accessor :wallet_type, :wallet_id  # :paypal, :apple_pay, :google_pay
  
  def initialize(id, order, amount, wallet_type, wallet_id)
    super(id, order, amount)
    @wallet_type = wallet_type
    @wallet_id = wallet_id
  end
  
  def process
    @status = :processing
    result = PaymentGateway.process_digital_wallet(self)
    if result.success?
      @status = :completed
      @transaction_id = result.transaction_id
    else
      @status = :failed
      raise PaymentError, result.error_message
    end
  end
  
  def refund
    @status = :refunded
    PaymentGateway.refund_digital_wallet(@transaction_id, @amount)
  end
end
```

#### **PaymentProcessor (Factory Pattern)**
```ruby
class PaymentProcessor
  def self.create_payment(order, payment_method, payment_details)
    case payment_method
    when :credit_card
      CreditCardPayment.new(
        generate_id, order, order.total_amount,
        payment_details[:card_number],
        payment_details[:cardholder_name],
        payment_details[:expiry_date],
        payment_details[:cvv]
      )
    when :paypal, :apple_pay, :google_pay
      DigitalWalletPayment.new(
        generate_id, order, order.total_amount,
        payment_method,
        payment_details[:wallet_id]
      )
    else
      raise ArgumentError, "Unsupported payment method: #{payment_method}"
    end
  end
  
  def self.process_payment(payment)
    payment.process
  end
  
  def self.refund(order)
    payment = find_payment_by_order(order)
    payment.refund if payment
  end
  
  private
  
  def self.generate_id
    SecureRandom.uuid
  end
  
  def self.find_payment_by_order(order)
    # Query payment repository
  end
end
```

### **6. Notification Classes (Observer Pattern)**

#### **NotificationService**
```ruby
class NotificationService
  attr_accessor :observers
  
  def initialize
    @observers = []
  end
  
  def subscribe(observer)
    @observers << observer
  end
  
  def unsubscribe(observer)
    @observers.delete(observer)
  end
  
  def send_order_update(customer, order)
    notification = OrderUpdateNotification.new(customer, order)
    notify_observers(notification)
  end
  
  def send_order_cancellation(customer, restaurant, driver, order)
    notification = OrderCancellationNotification.new(customer, restaurant, driver, order)
    notify_observers(notification)
  end
  
  private
  
  def notify_observers(notification)
    @observers.each { |observer| observer.update(notification) }
  end
end
```

#### **Notification (Abstract)**
```ruby
class Notification
  attr_accessor :recipient, :message, :type, :created_at
  
  def initialize(recipient, message, type)
    @recipient = recipient
    @message = message
    @type = type
    @created_at = Time.now
  end
end
```

#### **OrderUpdateNotification**
```ruby
class OrderUpdateNotification < Notification
  def initialize(customer, order)
    message = "Your order ##{order.id} status: #{order.status}"
    super(customer, message, :order_update)
  end
end
```

#### **NotificationObserver (Observer Pattern)**
```ruby
class PushNotificationObserver
  def update(notification)
    PushNotificationService.send(notification.recipient, notification.message)
  end
end

class EmailNotificationObserver
  def update(notification)
    EmailService.send(notification.recipient.email, notification.message)
  end
end

class SMSNotificationObserver
  def update(notification)
    SMSService.send(notification.recipient.phone, notification.message)
  end
end
```

### **7. Driver Matching Service (Strategy Pattern)**

#### **DriverMatchingStrategy (Interface)**
```ruby
class DriverMatchingStrategy
  def find_best_driver(order, available_drivers)
    raise NotImplementedError, 'Subclass must implement find_best_driver'
  end
end
```

#### **ProximityBasedMatching**
```ruby
class ProximityBasedMatching < DriverMatchingStrategy
  def find_best_driver(order, available_drivers)
    restaurant_location = order.restaurant.location
    
    available_drivers.min_by do |driver|
      restaurant_location.distance_to(driver.current_location)
    end
  end
end
```

#### **RatingBasedMatching**
```ruby
class RatingBasedMatching < DriverMatchingStrategy
  def find_best_driver(order, available_drivers)
    # Find drivers within 5km, then select highest rated
    nearby_drivers = available_drivers.select do |driver|
      order.restaurant.location.distance_to(driver.current_location) <= 5
    end
    
    nearby_drivers.max_by(&:rating)
  end
end
```

#### **DriverMatchingService**
```ruby
class DriverMatchingService
  attr_accessor :strategy
  
  def initialize(strategy = ProximityBasedMatching.new)
    @strategy = strategy
  end
  
  def set_strategy(strategy)
    @strategy = strategy
  end
  
  def assign_driver_to_order(order)
    available_drivers = find_available_drivers(order.restaurant.location)
    return nil if available_drivers.empty?
    
    best_driver = @strategy.find_best_driver(order, available_drivers)
    order.assign_driver(best_driver) if best_driver
    best_driver
  end
  
  private
  
  def find_available_drivers(restaurant_location)
    DriverLocationTracker.instance.find_nearby_drivers(restaurant_location, 10)
      .map { |driver_id| DriverRepository.find(driver_id) }
      .select { |driver| driver.status == :available }
  end
end
```

### **8. Search and Discovery Classes**

#### **RestaurantSearchService**
```ruby
class RestaurantSearchService
  def search(query_params)
    results = RestaurantRepository.all
    
    results = filter_by_cuisine(results, query_params[:cuisine]) if query_params[:cuisine]
    results = filter_by_location(results, query_params[:location]) if query_params[:location]
    results = filter_by_rating(results, query_params[:min_rating]) if query_params[:min_rating]
    results = filter_by_price_range(results, query_params[:price_range]) if query_params[:price_range]
    results = sort_by(results, query_params[:sort_by] || :rating)
    
    results
  end
  
  private
  
  def filter_by_cuisine(restaurants, cuisine)
    restaurants.select { |r| r.cuisine_type == cuisine }
  end
  
  def filter_by_location(restaurants, location)
    restaurants.select { |r| r.location.distance_to(location) <= 10 }  # 10km radius
  end
  
  def filter_by_rating(restaurants, min_rating)
    restaurants.select { |r| r.rating >= min_rating }
  end
  
  def filter_by_price_range(restaurants, price_range)
    restaurants.select { |r| r.menu.average_price.between?(price_range[:min], price_range[:max]) }
  end
  
  def sort_by(restaurants, sort_criteria)
    case sort_criteria
    when :rating
      restaurants.sort_by(&:rating).reverse
    when :distance
      restaurants.sort_by { |r| r.location.distance_to(current_location) }
    when :delivery_time
      restaurants.sort_by(&:average_delivery_time)
    else
      restaurants
    end
  end
end
```

### **9. Utility Classes**

#### **DistanceCalculator**
```ruby
class DistanceCalculator
  EARTH_RADIUS_KM = 6371.0
  
  def self.calculate(location1, location2)
    lat1_rad = to_radians(location1.latitude)
    lat2_rad = to_radians(location2.latitude)
    delta_lat = to_radians(location2.latitude - location1.latitude)
    delta_lon = to_radians(location2.longitude - location1.longitude)
    
    a = Math.sin(delta_lat / 2) ** 2 +
        Math.cos(lat1_rad) * Math.cos(lat2_rad) *
        Math.sin(delta_lon / 2) ** 2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    
    EARTH_RADIUS_KM * c
  end
  
  private
  
  def self.to_radians(degrees)
    degrees * Math::PI / 180
  end
end
```

#### **RouteOptimizer**
```ruby
class RouteOptimizer
  def self.calculate_eta(driver_location, restaurant_location, delivery_location)
    # Calculate route using mapping service
    route_to_restaurant = calculate_route(driver_location, restaurant_location)
    route_to_customer = calculate_route(restaurant_location, delivery_location)
    
    # Add estimated preparation time (15 minutes average)
    preparation_time = 15
    
    route_to_restaurant.time + preparation_time + route_to_customer.time
  end
  
  private
  
  def self.calculate_route(start, destination)
    # Integration with mapping API (Google Maps, Mapbox)
    MappingService.get_route(start, destination)
  end
end
```

### **10. Factory Classes**

#### **OrderFactory (Factory Pattern)**
```ruby
class OrderFactory
  def self.create_order(customer, restaurant, items)
    order_items = items.map do |item_data|
      menu_item = restaurant.menu.find_item(item_data[:item_id])
      OrderItem.new(menu_item, item_data[:quantity], item_data[:special_instructions])
    end
    
    order = Order.new(
      generate_order_id,
      customer,
      restaurant,
      order_items,
      customer.address
    )
    
    restaurant.receive_order(order)
    order
  end
  
  private
  
  def self.generate_order_id
    "ORD-#{Time.now.to_i}-#{SecureRandom.hex(4).upcase}"
  end
end
```

## Design Patterns Used

### **1. Singleton Pattern**
- **DriverLocationTracker**: Ensures only one instance tracks all driver locations globally.

### **2. Factory Pattern**
- **OrderFactory**: Creates order objects with proper initialization.
- **PaymentProcessor**: Creates different payment types based on payment method.

### **3. Strategy Pattern**
- **Payment Processing**: Different payment strategies (CreditCard, DigitalWallet).
- **Driver Matching**: Different matching algorithms (ProximityBased, RatingBased).

### **4. Observer Pattern**
- **Notification System**: Multiple observers (Push, Email, SMS) notified of order updates.

### **5. Template Method Pattern**
- **User Class**: Defines template methods that subclasses implement.

## SOLID Principles Application

### **Single Responsibility Principle (SRP)**
- Each class has a single, well-defined responsibility:
  - `Order` manages order state and calculations
  - `PaymentProcessor` handles payment creation
  - `DriverMatchingService` handles driver assignment
  - `NotificationService` handles notifications

### **Open/Closed Principle (OCP)**
- Classes are open for extension but closed for modification:
  - New payment methods can be added without modifying `PaymentProcessor`
  - New matching strategies can be added without modifying `DriverMatchingService`
  - New notification types can be added via observer pattern

### **Liskov Substitution Principle (LSP)**
- Subclasses can replace their base classes:
  - `Customer`, `Driver`, `RestaurantOwner` can be used wherever `User` is expected
  - `CreditCardPayment`, `DigitalWalletPayment` can replace `Payment`

### **Interface Segregation Principle (ISP)**
- Interfaces are specific and focused:
  - `DriverMatchingStrategy` has only matching-related methods
  - Payment classes implement only payment-related methods

### **Dependency Inversion Principle (DIP)**
- High-level modules depend on abstractions:
  - `DriverMatchingService` depends on `DriverMatchingStrategy` interface, not concrete implementations
  - `NotificationService` depends on observer interface, not concrete notification types

## Class Relationships

### **Inheritance (Is-A)**
- `Customer < User`
- `Driver < User`
- `RestaurantOwner < User`
- `CreditCardPayment < Payment`
- `DigitalWalletPayment < Payment`
- `OrderUpdateNotification < Notification`

### **Composition (Has-A)**
- `Order` has `OrderItem` objects
- `Restaurant` has a `Menu`
- `Menu` has `MenuItem` objects
- `Order` has `Location` (delivery address)

### **Aggregation (Has-A, but weaker)**
- `Customer` has `Order` history (orders can exist without customer)
- `Restaurant` has `Order` list (orders can exist without restaurant)

### **Association**
- `Order` is associated with `Customer`, `Restaurant`, and `Driver`
- `Driver` is associated with `Vehicle`
- `Restaurant` is associated with `RestaurantOwner`

## Key Design Decisions

1. **Abstract Base Classes**: Used for `User` and `Payment` to enforce common structure while allowing specialization.

2. **Factory Pattern for Order Creation**: Centralizes order creation logic and ensures proper initialization.

3. **Strategy Pattern for Driver Matching**: Allows easy swapping of matching algorithms without code changes.

4. **Observer Pattern for Notifications**: Decouples notification logic from business logic, making it easy to add new notification channels.

5. **Singleton for Location Tracking**: Ensures single source of truth for driver locations across the system.

6. **Composition over Inheritance**: Used composition for `Menu` and `MenuItem` relationship for flexibility.

7. **Separation of Concerns**: Each service class handles one specific domain (matching, search, notifications).

## Summary

This object-oriented design provides:
- **Maintainability**: Clear separation of concerns and single responsibility
- **Extensibility**: Easy to add new features (payment methods, matching strategies, notification types)
- **Testability**: Classes are loosely coupled and can be tested independently
- **Scalability**: Design patterns support horizontal scaling
- **Flexibility**: Strategy and factory patterns allow runtime behavior changes

The design follows industry best practices and can handle the complexity of a real-world delivery application while remaining maintainable and extensible.

