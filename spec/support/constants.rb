require "dotenv"
Dotenv.load

begin
  if Hound.constants.none?
    require "config/initializers/constants"
  end
rescue
  # noop
end
