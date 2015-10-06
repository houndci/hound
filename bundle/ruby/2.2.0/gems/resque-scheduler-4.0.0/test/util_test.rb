# vim:fileencoding=utf-8

context 'Util' do
  def util
    Resque::Scheduler::Util
  end

  test 'constantizing' do
    assert util.constantize('Resque::Scheduler') == Resque::Scheduler
  end
end
