class AddOwnerToRepos < ActiveRecord::Migration[4.2]
  def change
    add_reference :repos, :owner, index: true
    add_foreign_key :repos, :owners
  end
end
