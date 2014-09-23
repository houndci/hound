module FlashesHelper
  def user_facing_flashes
    flash.to_hash.slice("notice", "error")
  end
end
