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
savings_account = SavingsAccount.new(1000, 'savings', 0.05)
checking_account = CheckingAccount.new(500, 'checking')

bank = Bank.new
bank.add_account(savings_account)
bank.add_account(checking_account)

puts savings_account.balance # 1000
savings_account.deposit(100)
puts savings_account.balance # 1100
savings_account.withdraw(200)
puts savings_account.balance # 900
savings_account.calculate_interest
puts savings_account.balance # 945

puts checking_account.balance # 500
checking_account.deposit(100)
puts checking_account.balance # 600
checking_account.withdraw(200)
puts checking_account.balance # 400
checking_account.withdraw(500) # raise 'Insufficient balance'
puts checking_account.balance # 400

bank.remove_account(savings_account)
puts bank.accounts.size # 1
bank.remove_account(checking_account)
puts bank.accounts.size # 0
