class abc

  def sayhello
    return "WORKING"
  end
  def something
    for i in (1..10)
      puts i
      puts something
    end
  end
end
a = abc.new()
a.sayhello


