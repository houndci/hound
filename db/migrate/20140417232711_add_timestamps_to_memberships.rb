class AddTimestampsToMemberships < ActiveRecord::Migration[4.2]
  def change
    add_timestamps :memberships
  end
end
