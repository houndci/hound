class AddUuidToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :uuid, :string
  end
end
