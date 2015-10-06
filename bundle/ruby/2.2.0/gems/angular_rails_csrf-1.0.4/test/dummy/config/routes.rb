Dummy::Application.routes.draw do
  get  'test' => 'application#index'
  post 'test' => 'application#create'
end
