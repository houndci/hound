class AddPayloadToBuilds < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :payload, :text
  end
end
