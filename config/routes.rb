Rails.application.routes.draw do
  get 'map/show'
  get 'map/test'
  get 'map/test2f'
  get 'map/landform'
  get 'map/landform2f'
  get 'map/xy'

  get 'paraphrase/:sentence', to: 'analysis#paraphrase'
  get 'complement/:sentence', to: 'analysis#complement'
  get 'analysis/:sentence', to: 'analysis#result'
  get 'enju_xml/:sentence', to: 'analysis#enju_xml'
  get 'en2enju_xml/:sentence', to: 'analysis#en2enju_xml', constraints: {sentence: /.*/}
  get 'ja2en/:sentence', to: 'analysis#ja2en'
  get 'en2ja/:sentence', to: 'analysis#en2ja'
  get 'translation/:data', to: 'translation#perform'

  get 'data/south_locations_download'
  get 'data/north_locations_download'
  get 'data/south_stairs_download'
  get 'data/north_stairs_download'
  get 'data/maps_download'
  get 'data/maps_closed_download'

  resources :locations, :only => [:create, :new]
  resources :stairs, :only => [:create, :new]
  resources :maps, :only => [:create, :new] do
    collection do
      post :closed
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
