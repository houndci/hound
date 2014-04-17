class AddTimestampsToMemberships < ActiveRecord::Migration
  def change
    add_timestamps :memberships
  end
end
