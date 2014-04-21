class AddTimestampsToRepo < ActiveRecord::Migration
  def change
    add_timestamps :repos
  end
end
