class AddUuidToBuilds < ActiveRecord::Migration[4.2]
  def change
    add_column :builds, :uuid, :string
  end
end
