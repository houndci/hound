require "rails_helper"

RSpec.describe Identity, type: :model do
  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_presence_of(:provider) }
  it { is_expected.to allow_value("github", "bitbucket").for(:provider) }
  it { is_expected.to_not allow_value("gitlab").for(:provider) }
end
