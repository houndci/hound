class AddTimestampsToRepo < ActiveRecord::Migration[4.2]
  def change
    add_timestamps :repos
  end
end
