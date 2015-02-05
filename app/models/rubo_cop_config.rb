# Config class that disables all rules by default, unlike RuboCop's
class RuboCopConfig < RuboCop::Config
  def cop_enabled?(cop)
    if for_cop(cop)
      for_cop(cop)["Enabled"]
    else
      false
    end
  end
end
