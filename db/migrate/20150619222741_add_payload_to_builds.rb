class AddPayloadToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :payload, :text
  end
end
