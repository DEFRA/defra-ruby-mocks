Rails.application.routes.draw do

  mount DefraRuby::Mocks::Engine => "/defra_ruby/mocks"
end
