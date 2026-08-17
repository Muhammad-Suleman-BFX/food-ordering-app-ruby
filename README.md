# Food Ordering App

A terminal-based food ordering application built in Ruby demonstrating clean code practices, object-oriented design, and proper separation of concerns.

## Features

- **Menu Display** — View available food items with prices
- **Cart Management** — Add, update, and remove items from cart
- **Smart Item Merging** — Automatically merges duplicate menu items instead of creating duplicates
- **Price Precision** — Uses `BigDecimal` for accurate monetary calculations (no Float precision loss)
- **Quantity Updates** — Update item quantities or remove items by setting quantity to 0
- **Order Placement** — Place orders and view order summary
- **Order Status Tracking** — Simulate order progress through status updates
- **Formatted Pricing** — Consistent price formatting across the app

## Project Structure

```
food_ordering_app.rb
├── MenuItem           # Menu item model with id, name, price (BigDecimal)
├── CartItem          # Cart item model with id, menu_item, quantity
├── Cart              # Cart service handling add/update/remove/total operations
├── Order             # Order service managing status and transitions
└── FoodOrderingApp   # Main app with UI and orchestration
```

## Requirements

- Ruby 2.7+
- `bigdecimal` gem (included in Ruby stdlib)

## How to Run

```bash
ruby food_ordering_app.rb
```

The app will start an interactive menu:

```
Choose an option:
1. Display Menu
2. Add item to cart
3. Update item quantity
4. Remove item from cart
5. Show cart
6. Place order
7. Exit
```

### Workflow

1. **Display Menu** → See available items
2. **Add item** → Enter item number and quantity
3. **Add another** → Same item will merge (quantity increases)
4. **Show cart** → View items and total
5. **Update quantity** → Change or remove items
6. **Place order** → Confirm and view status updates
