# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'main#index', defaults: { format: 'json' }
  get '/search/artmuseum/', to: 'art_museum#show', defaults: { format: 'json' }
  get '/search/catalog/', to: 'catalog#show', defaults: { format: 'json' }
  get '/search/dpul/', to: 'dpul#show', defaults: { format: 'json' }
  get '/search/findingaids/', to: 'findingaids#show', defaults: { format: 'json' }
  get '/search/libanswers/', to: 'libanswers#show', defaults: { format: 'json' }
  get '/search/pulmap', to: 'pulmap#show', defaults: { format: 'json' }
end
