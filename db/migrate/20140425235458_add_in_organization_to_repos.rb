class AddInOrganizationToRepos < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :in_organization, :boolean
  end
end
