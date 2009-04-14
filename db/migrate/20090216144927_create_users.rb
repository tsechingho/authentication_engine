class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email, :null => false
      t.string :login, :default => nil, :null => true
      t.string :crypted_password, :default => nil, :null => true
      t.string :password_salt, :default => nil, :null => true
      t.string :persistence_token, :null => false
      t.string :perishable_token, :null => false
      t.string :single_access_token, :null => false
      t.integer :login_count, :default => 0, :null => false
      t.integer :failed_login_count, :default => 0, :null => false
      t.datetime :last_request_at
      t.datetime :last_login_at
      t.datetime :current_login_at
      t.string :last_login_ip
      t.string :current_login_ip
      t.string :openid_identifier
      t.integer :invitation_id
      t.integer :invitation_limit, :default => 0, :null => false
      t.boolean :admin
      t.timestamps
    end
    add_index :users, :login
    add_index :users, :persistence_token
    add_index :users, :last_request_at
    add_index :users, :openid_identifier

    unless User.find_by_login('root')
      puts 'Creating root user ...'
      root_user = User.create(
        :name => "Root User",
        :login => 'root',
        :password => 'root',
        :password_confirmation => 'root',
        :email => "root@example.com",
        :admin => true
      )
      root_user.save(false)
      puts "Root user created. login/password is root/root. Please change immediately!"
    else
      puts 'Root user already exists.'
    end
  end

  def self.down
    drop_table :users
  end
end
