Rails.application.routes.draw do
  get 'map/show'

  get 'paraphrase/:sentence', to: 'analysis#paraphrase'
  get 'complement/:sentence', to: 'analysis#complement'
  get 'analysis/:sentence', to: 'analysis#result'
  get 'enju_xml/:sentence', to: 'analysis#enju_xml'
  get 'en2enju_xml/:sentence', to: 'analysis#en2enju_xml', constraints: {sentence: /.*/}
  get 'ja2en/:sentence', to: 'analysis#ja2en'
  get 'en2ja/:sentence', to: 'analysis#en2ja'
  get 'translation/:data', to: 'translation#perform'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
