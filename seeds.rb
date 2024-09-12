# db/seeds.rb

# Create a test admin user for SpinaCMS
Spina::User.create!(
  email: 'testuser@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Test User'
)
puts "Test user created!"
