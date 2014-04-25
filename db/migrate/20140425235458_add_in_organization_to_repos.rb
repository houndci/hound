class AddInOrganizationToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :in_organization, :boolean
  end
end
