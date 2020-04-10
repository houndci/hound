# Hold file, line number, and violation message values.
# Built by style guides.
# Printed by Commenter.
class Violation < ApplicationRecord
  belongs_to :file_review

  delegate :count, to: :messages, prefix: true
  delegate :filename, to: :file_review

  def add_message(message)
    self[:messages] << message
  end

  def messages
    self[:messages].uniq
  end

  def source=(value)
    self[:source] = crypt.encrypt_and_sign(value)
  end

  def source
    crypt.decrypt_and_verify(self[:source]) if self[:source]
  end

  private

  def crypt
    secret_key_base = Rails.application.secrets.secret_key_base
    ActiveSupport::MessageEncryptor.new(secret_key_base[0, 32], secret_key_base)
  end
end
