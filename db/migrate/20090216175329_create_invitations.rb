class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :sender_id
      t.string :recipient_name
      t.string :recipient_email, :null => false
      t.string :token, :null => false
      t.datetime :sent_at
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
