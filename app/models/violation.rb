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
    encrypted_source = crypt.encrypt_and_sign(value)
    write_attribute(:source, encrypted_source)
  end

  def source
    encrypted_source = read_attribute(:source)
    unless encrypted_source.nil?
      crypt.decrypt_and_verify(encrypted_source)
    end
  end

  private

  def crypt
    secret_key_base = Rails.application.secrets.secret_key_base
    ActiveSupport::MessageEncryptor.new(secret_key_base[0, 32], secret_key_base)
  end
end
