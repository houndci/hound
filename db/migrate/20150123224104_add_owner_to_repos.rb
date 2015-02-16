class AddOwnerToRepos < ActiveRecord::Migration
  def change
    add_reference :repos, :owner, index: true
    add_foreign_key :repos, :owners
  end
end
