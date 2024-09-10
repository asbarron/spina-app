class AddPasswordResetTokenToSpinaUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :spina_users, :password_reset_token, :string
  end
end
