#!/user/bin/ruby

# Design a system for a simple banking application. The system should handle multiple accounts, allow users to deposit
# and withdraw money, and check their balance. There should be different types of accounts (e.g., checking, savings),
# and each account should have the ability to calculate interest (for savings). The system should ensure that users
#   can't withdraw more money than they have in their account. Please design the classes, attributes, methods, and
#     relationships for this system.

class Account
  attr_accessor :balance, :account_type

  def initialize(balance, account_type)
    @balance = balance
    @account_type = account_type
  end

  def deposit(amount)
    @balance += amount
  end

  def withdraw(amount)
    if amount > @balance
      raise 'Insufficient balance'
    else
      @balance -= amount
    end
  end
end

class SavingsAccount < Account
  attr_accessor :interest_rate

  def initialize(balance, account_type, interest_rate)
    super(balance, account_type)
    @interest_rate = interest_rate
  end

  def calculate_interest
    @balance += @balance * @interest_rate
  end
end

class CheckingAccount < Account
  def initialize(balance, account_type)
    super(balance, account_type)
  end
end

class Bank
  attr_accessor :accounts

  def initialize
    @accounts = []
  end

  def add_account(account)
    @accounts << account
  end

  def remove_account(account)
    @accounts.delete(account)
  end
end

# Test
# savings_account = SavingsAccount.new(1000, 'savings', 0.05)
# checking_account = CheckingAccount.new(500, 'checking')
#
# bank = Bank.new
# bank.add_account(savings_account)
# bank.add_account(checking_account)
#
# puts savings_account.balance # 1000
# savings_account.deposit(100)
# puts savings_account.balance # 1100
# savings_account.withdraw(200)
# puts savings_account.balance # 900
# savings_account.calculate_interest
# puts savings_account.balance # 945
#
# puts checking_account.balance # 500
# checking_account.deposit(100)
# puts checking_account.balance # 600
# checking_account.withdraw(200)
# puts checking_account.balance # 400
# checking_account.withdraw(500) # raise 'Insufficient balance'
# puts checking_account.balance # 400
#
# bank.remove_account(savings_account)
# puts bank.accounts.size # 1
# bank.remove_account(checking_account)
# puts bank.accounts.size # 0

class Product
  attr_accessor :name, :price

  def initialize(name, price = 0.0)
    raise 'Price must be a positive number' if price <= 0
    @name = name
    @price = price
  end
end

class ShoppingCart
  attr_accessor :cart_items, :customer

  def initialize(cart_items, customer)
    @cart_items = cart_items
    @customer = customer
    @discount_price = 0
  end

  def add_product(product, quantity = 1)
    cart_item = CartItem.new(product, quantity)
    cart_items << cart_item
  end

  def delete_product(product)
    cart_item = @cart_items.find { |cart_item| cart_item.product == product }
    @cart_items.delete(cart_item)
  end

  def total_price
    @cart_items.map { |cart_item| cart_item.product.price * cart_item.qty }.sum
  end

  def apply_discount(discount_percentage)
    @discount_price = discount_percentage
  end

  def total_amount_paid
    total_price * (1 - @discount_price / 100.0) if @discount_price
    total_price
  end

  def checkout
    return 'Cart is empty' if @cart_items.empty?
    {
      order_id: SecureRandom.uuid,
      total_price: total_price,
      discount: @discount_price,
      total_amount_paid: total_amount_paid
    }
  end
end

class Customer
  def initialize(name)
    @name = name
  end

end

class CartItem
  attr_accessor :product, :qty

  def initialize(product, qty)

    @product = product
    @qty = qty
  end

end


class NotificationStrategy

  def send(body)
    raise NotImplementedError, 'This method should be overridden by subclasses'
  end
end

class Email <NotificationStrategy

  def send(body)
    puts "sending  #{body} through Email."
  end
end

class SMS <NotificationStrategy

  def send(body)
    puts "sending  #{body} through SMS."
  end
end

class PushNotification <NotificationStrategy

  def send(body)
    puts "sending  #{body} through PushNotification."
  end
end
