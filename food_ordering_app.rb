require 'debug'
require 'bigdecimal'
require 'bigdecimal/util'

class MenuItem
    attr_reader :id, :name, :price

    def initialize(id, name, price)
        @id = id
        @name = name
        @price = BigDecimal(price.to_s)
    end
end

class CartItem
    attr_accessor :id, :quantity, :menu_item

    def initialize(id, menu_item, quantity)
        @id = id
        @menu_item = menu_item
        @quantity = quantity
    end

    def total_price
        @menu_item.price * @quantity
    end
end

class Cart
    attr_reader :items

    def initialize
        @items = {}
    end

    def add(menu_item, quantity)
        existing_item = find_by_menu_item_in_cart(menu_item.id)

        if existing_item
            existing_item.quantity += quantity
            existing_item
        else
            cart_item_id = next_cart_item_id
            new_item = CartItem.new(cart_item_id, menu_item, quantity)
            @items[cart_item_id] = new_item
            new_item
        end
    end

    def update(cart_item_id, quantity)
        cart_item = @items[cart_item_id]
        return nil unless cart_item

        return :invalid if quantity < 0
        return remove(cart_item_id) if quantity == 0

        cart_item.quantity = quantity
        cart_item
    end

    def remove(cart_item_id)
        removed = @items.delete(cart_item_id)
        reassign_ids
        removed
    end

    def total
        @items.values.reduce(BigDecimal('0')) { |sum, item| sum + item.total_price }
    end

    def empty?
        @items.empty?
    end

    def find_by_menu_item_in_cart(menu_item_id)
        @items.values.find { |item| item.menu_item.id == menu_item_id }
    end

    private

    def next_cart_item_id
        @items.length + 1
    end

    def reassign_ids
        new_items = {}
        @items.each_with_index do |(_, item), index|
            item.id = index + 1
            new_items[index + 1] = item
        end
        @items = new_items
    end
end

class Order
    attr_reader :status

    STATUS_SEQUENCE = ['Payment Processing', 'Preparing', 'Out for Delivery', 'Delivered'].freeze

    def initialize
        @status = 'Not Placed'
    end

    def place
        @status = 'Placed'
    end

    def advance_statuses
        STATUS_SEQUENCE.map do |status|
            @status = status
            status
        end
    end

end

class FoodOrderingApp
    # Initialize the app state: cart, order status, and menu data.
    def initialize
        @cart = Cart.new
        @order = Order.new
        @menu = {
            1 => MenuItem.new(1, "Big Baik", 12.30),
            2 => MenuItem.new(2, "Chicken Shawarma", 10.27),
            3 => MenuItem.new(3, "4 Pieces Chicken", 15.50),
            4 => MenuItem.new(4, "12 Pieces Nuggets", 18.00),
        }
    end

    # Show the available menu items and prices.
    def display_menu
        puts "\n***** Menu *****"
        @menu.each do |id, item|
            puts "#{id}. #{item.name} - #{format_price(item.price)}"
        end
    end

    # Add a menu item and quantity to the cart.
    def add_to_cart(item_id, quantity)
        unless @menu.key?(item_id)
            puts "\n***** Item not found in menu *****"
            return
        end
        unless quantity > 0
            puts "\n***** Invalid quantity. Quantity must be greater than 0. *****"
            return
        end

        existing_item = @cart.find_by_menu_item_in_cart(item_id)
        add_to_cart_item = @cart.add(@menu[item_id], quantity)

        if existing_item
            puts "\n***** #{quantity} x #{add_to_cart_item.menu_item.name} added to existing cart item - new quantity #{add_to_cart_item.quantity} -- #{format_price(add_to_cart_item.total_price)} *****"
        else
            puts "\n***** #{quantity} x #{add_to_cart_item.menu_item.name} added to cart - #{format_price(add_to_cart_item.total_price)} *****"
        end
    end

    # Update the quantity of an existing cart item, or remove it if quantity is zero.
    def update_cart(cart_item_id, quantity)
        result = @cart.update(cart_item_id, quantity)

        case result
        when nil
            puts "\n***** Item not found in cart. *****"
        when :invalid
            puts "\n***** Invalid quantity. Quantity must be 0 or greater. *****"
        when CartItem
            puts "\n***** #{result.menu_item.name} quantity updated to #{result.quantity} -- #{format_price(result.total_price)} *****"
        else
            puts "\n***** #{result.menu_item.name} removed from cart. *****"
        end
    end

    # Remove an item from the cart by cart item ID.
    def remove_from_cart(cart_item_id)
        removed_item = @cart.remove(cart_item_id)

        if removed_item
            puts "\n***** #{removed_item.menu_item.name} removed from cart. *****"
        else
            puts "\n***** Item not found in cart. *****"
        end
    end

    # Display the current cart contents and the total price.
    def display_cart(title = 'Your cart:')
        if @cart.empty?
            puts "\n***** #{title} is empty. *****"
        else
            puts "\n***** #{title} *****\n\n"

            @cart.items.each do |cart_id, item|
                puts "#{cart_id}. ***** #{item.menu_item.name} - Quantity: #{item.quantity} -- Total: #{format_price(item.total_price)} *****"
            end
            puts "\n***** Total: #{format_price(@cart.total)} *****"
        end
    end

    # Place the order, show the summary, then start the status updates.
    def place_order
        if @cart.empty?
            puts "\n***** Your cart is empty. Please add items to your cart before placing an order. *****"
            return
        end

        @order.place
        puts "\n***** Order placed successfully *****"

        display_cart('Order Summary')
        advance_order_statuses
        reset_order
    end

    # Simulate order progress with timed status updates.
    def advance_order_statuses
        puts "\n***** Order Status: #{@order.status} *****"
        @order.advance_statuses.each do |status|
            sleep 1
            puts "\n***** Order Status: #{status} *****"
        end
    end

    # Reset the cart and order status after the order completes.
    def reset_order
        @cart = Cart.new
        @order = Order.new
    end

    def format_price(amount)
        return "$0.00" if amount.nil?
        num = amount.to_f
        if num < 0
            "-#$#{'%.2f' % num.abs}".gsub('#$', '$')
        else
            "$#{'%.2f' % num}"
        end
    end

    def cart_total
        @cart.total
    end

    # Main interactive loop for terminal user input.
    def run
        loop do
            puts "\nChoose an option:"
            puts "1. Display Menu"
            puts "2. Add item to cart"
            puts "3. Update item quantity"
            puts "4. Remove item from cart"
            puts "5. Show cart"
            puts "6. Place order"
            puts "7. Exit"
            print "> "
            choice = gets.chomp

            case choice
            when '1'
                display_menu
            when '2'
                display_menu
                print 'Item number: '
                item_id = gets.chomp.to_i
                print 'Quantity: '
                quantity = gets.chomp.to_i
                add_to_cart(item_id, quantity)
            when '3'
                display_cart
                print 'Item number: '
                cart_item_id = gets.chomp.to_i
                print 'New quantity: '
                quantity = gets.chomp.to_i
                update_cart(cart_item_id, quantity)
            when '4'
                print 'Cart item number: '
                cart_item_id = gets.chomp.to_i
                remove_from_cart(cart_item_id)
            when '5'
                display_cart
            when '6'
                place_order
            when '7'
                puts 'Goodbye!'
                break
            else
                puts 'Invalid choice. Please enter a number from 1 to 7.'
            end
        end
    end
end

food_ordering_app = FoodOrderingApp.new
food_ordering_app.run
