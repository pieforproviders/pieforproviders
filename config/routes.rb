# frozen_string_literal: true

is_html_request = ->(request) { !request.xhr? && request.format.html? }

Rails.application.routes.draw do
  # This is required because the `devise_for` call generates a `GET /login`
  # route which we don't want to expose
  get '/login', to: 'static#fallback_index_html', constraints: is_html_request

  devise_for :users,
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations',
               confirmations: 'confirmations'
             }
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  scope module: :api, defaults: { format: :json }, path: 'api' do
    scope module: :v1, constraints: ApiConstraint.new(version: 1, default: true), path: 'v1' do
      resources :users, param: :slug, except: [:show]
      get 'profile', to: 'users#show'
      resources :businesses, param: :slug
      resources :sites, param: :slug
      resources :children, param: :slug
      resources :payments, param: :slug
      resources :case_cycles, param: :slug
      resources :attendances, param: :slug
    end
  end

  get '*path', to: 'static#fallback_index_html', constraints: is_html_request
end

# rubocop:disable Layout/LineLength

# == Route Map
#
#                                Prefix Verb   URI Pattern                                                                              Controller#Action
#                           oauth_token POST   /oauth/token(.:format)                                                                   doorkeeper/tokens#create
#                          oauth_revoke POST   /oauth/revoke(.:format)                                                                  doorkeeper/tokens#revoke
#                      oauth_introspect POST   /oauth/introspect(.:format)                                                              doorkeeper/tokens#introspect
#                      oauth_token_info GET    /oauth/token/info(.:format)                                                              doorkeeper/token_info#show
#                              children GET    /api/v1/children(.:format)                                                               api/v1/children#index {:format=>:json}
#                                       POST   /api/v1/children(.:format)                                                               api/v1/children#create {:format=>:json}
#                                 child GET    /api/v1/children/:id(.:format)                                                           api/v1/children#show {:format=>:json}
#                                       PATCH  /api/v1/children/:id(.:format)                                                           api/v1/children#update {:format=>:json}
#                                       PUT    /api/v1/children/:id(.:format)                                                           api/v1/children#update {:format=>:json}
#                                       DELETE /api/v1/children/:id(.:format)                                                           api/v1/children#destroy {:format=>:json}
#                                 users GET    /api/v1/users(.:format)                                                                  api/v1/users#index {:format=>:json}
#              cancel_user_registration GET    /api/v1/users/cancel(.:format)                                                           api/v1/users/registrations#cancel {:format=>:json}
#                 new_user_registration GET    /api/v1/users/sign_up(.:format)                                                          api/v1/users/registrations#new {:format=>:json}
#                edit_user_registration GET    /api/v1/users/edit(.:format)                                                             api/v1/users/registrations#edit {:format=>:json}
#                     user_registration PATCH  /api/v1/users(.:format)                                                                  api/v1/users/registrations#update {:format=>:json}
#                                       PUT    /api/v1/users(.:format)                                                                  api/v1/users/registrations#update {:format=>:json}
#                                       DELETE /api/v1/users(.:format)                                                                  api/v1/users/registrations#destroy {:format=>:json}
#                                       POST   /api/v1/users(.:format)                                                                  api/v1/users/registrations#create {:format=>:json}
#                 new_user_confirmation GET    /api/v1/users/confirmation/new(.:format)                                                 api/v1/confirmations#new {:format=>:json}
#                     user_confirmation GET    /api/v1/users/confirmation(.:format)                                                     api/v1/confirmations#show {:format=>:json}
#                                       POST   /api/v1/users/confirmation(.:format)                                                     api/v1/confirmations#create {:format=>:json}
#         rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                  action_mailbox/ingresses/mandrill/inbound_emails#create
#         rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                  action_mailbox/ingresses/postmark/inbound_emails#create
#            rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                     action_mailbox/ingresses/relay/inbound_emails#create
#         rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                  action_mailbox/ingresses/sendgrid/inbound_emails#create
#          rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                              action_mailbox/ingresses/mailgun/inbound_emails#create
#        rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#index
#                                       POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#create
#         rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#show
#                                       PATCH  /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
#                                       PUT    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
#                                       DELETE /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#destroy
# rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                      rails/conductor/action_mailbox/reroutes#create
#                    rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#             rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#                    rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#             update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#                  rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

# rubocop:enable Layout/LineLength
