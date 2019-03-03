# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(first_name:  "fudie",
  last_name:  "admin",
  username: "fudie-admin",
  email: ENV['ADMIN_EMAIL'],
  password: ENV['ADMIN_PASSWORD'],
  password_confirmation: ENV['ADMIN_PASSWORD'],
  role: 1,
  account_activated: true,
  account_activated_at: Time.zone.now)


categories = %w[Breakfast Lunch Dinner Snacks Appetizers Meat Fish Soups Stews
                Sauces Seafood Dairy Beef Pork Lamb Chicken Salads Sides Rice
                Pasta Noodles Pies Burgers Sausages Chicken Turkey Duck Poultry
                Veggies Stir-fry Dips Salsas Pancakes Pizza Baking Desserts
                Drinks Vegetarian Experimental Original African Italian Chinese
                Thai Japanese Indian Christmas Wedding Birthday Hack
                Informational Spices Healthy Kitchen Vegan Pantry
                Cooking-Utensils Recipe
              ]

categories.each do |category|
  Category.find_or_create_by!(name: category)
end
