# frozen_string_literal: true

class Membership < ApplicationRecord
  belongs_to :repo
  belongs_to :user
end
