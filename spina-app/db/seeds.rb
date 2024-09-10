# db/seeds.rb

# Ensure that the 'spina_lines' table exists
unless ActiveRecord::Base.connection.table_exists?(:spina_lines)
  ActiveRecord::Base.connection.execute <<-SQL
    CREATE TABLE spina_lines (
      id SERIAL PRIMARY KEY,
      content TEXT,
      created_at TIMESTAMP,
      updated_at TIMESTAMP
    );
  SQL
end

# Create a test user for SpinaCMS
Spina::User.create!(
  email: 'testuser@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  name: 'Test User'  # Add this line if 'name' is required
)

puts "Test user created!"

# Optionally, add more seed data here if needed
