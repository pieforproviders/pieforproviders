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
               confirmations: 'confirmations',
               passwords: 'passwords'
             }
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  scope module: :api, defaults: { format: :json }, path: 'api' do
    scope module: :v1, constraints: ApiConstraint.new(version: 1, default: true), path: 'v1' do
      resources :users, only: %i[index show]
      get 'profile', to: 'users#show'
      resources :businesses
      resources :children
      resources :payments
      resources :case_cycles
      resources :child_case_cycles
      resources :child_case_cycle_payments
      resources :attendances
    end
  end

  get '*path', to: 'static#fallback_index_html', constraints: is_html_request
end

# == Route Map
#
#                                Prefix Verb   URI Pattern                                                                              Controller#Action
#                                 login GET    /login(.:format)                                                                         static#fallback_index_html
#                      new_user_session GET    /login(.:format)                                                                         sessions#new
#                          user_session POST   /login(.:format)                                                                         sessions#create
#                  destroy_user_session DELETE /logout(.:format)                                                                        sessions#destroy
#                     new_user_password GET    /password/new(.:format)                                                                  passwords#new
#                    edit_user_password GET    /password/edit(.:format)                                                                 passwords#edit
#                         user_password PATCH  /password(.:format)                                                                      passwords#update
#                                       PUT    /password(.:format)                                                                      passwords#update
#                                       POST   /password(.:format)                                                                      passwords#create
#              cancel_user_registration GET    /signup/cancel(.:format)                                                                 registrations#cancel
#                 new_user_registration GET    /signup/sign_up(.:format)                                                                registrations#new
#                edit_user_registration GET    /signup/edit(.:format)                                                                   registrations#edit
#                     user_registration PATCH  /signup(.:format)                                                                        registrations#update
#                                       PUT    /signup(.:format)                                                                        registrations#update
#                                       DELETE /signup(.:format)                                                                        registrations#destroy
#                                       POST   /signup(.:format)                                                                        registrations#create
#                 new_user_confirmation GET    /confirmation/new(.:format)                                                              confirmations#new
#                     user_confirmation GET    /confirmation(.:format)                                                                  confirmations#show
#                                       POST   /confirmation(.:format)                                                                  confirmations#create
#                              rswag_ui        /api-docs                                                                                Rswag::Ui::Engine
#                             rswag_api        /api-docs                                                                                Rswag::Api::Engine
#                     letter_opener_web        /letter_opener                                                                           LetterOpenerWeb::Engine
#                                 users GET    /api/v1/users(.:format)                                                                  api/v1/users#index {:format=>:json}
#                                  user GET    /api/v1/users/:id(.:format)                                                              api/v1/users#show {:format=>:json}
#                               profile GET    /api/v1/profile(.:format)                                                                api/v1/users#show {:format=>:json}
#                            businesses GET    /api/v1/businesses(.:format)                                                             api/v1/businesses#index {:format=>:json}
#                                       POST   /api/v1/businesses(.:format)                                                             api/v1/businesses#create {:format=>:json}
#                              business GET    /api/v1/businesses/:id(.:format)                                                         api/v1/businesses#show {:format=>:json}
#                                       PATCH  /api/v1/businesses/:id(.:format)                                                         api/v1/businesses#update {:format=>:json}
#                                       PUT    /api/v1/businesses/:id(.:format)                                                         api/v1/businesses#update {:format=>:json}
#                                       DELETE /api/v1/businesses/:id(.:format)                                                         api/v1/businesses#destroy {:format=>:json}
#                              children GET    /api/v1/children(.:format)                                                               api/v1/children#index {:format=>:json}
#                                       POST   /api/v1/children(.:format)                                                               api/v1/children#create {:format=>:json}
#                                 child GET    /api/v1/children/:id(.:format)                                                           api/v1/children#show {:format=>:json}
#                                       PATCH  /api/v1/children/:id(.:format)                                                           api/v1/children#update {:format=>:json}
#                                       PUT    /api/v1/children/:id(.:format)                                                           api/v1/children#update {:format=>:json}
#                                       DELETE /api/v1/children/:id(.:format)                                                           api/v1/children#destroy {:format=>:json}
#                              payments GET    /api/v1/payments(.:format)                                                               api/v1/payments#index {:format=>:json}
#                                       POST   /api/v1/payments(.:format)                                                               api/v1/payments#create {:format=>:json}
#                               payment GET    /api/v1/payments/:id(.:format)                                                           api/v1/payments#show {:format=>:json}
#                                       PATCH  /api/v1/payments/:id(.:format)                                                           api/v1/payments#update {:format=>:json}
#                                       PUT    /api/v1/payments/:id(.:format)                                                           api/v1/payments#update {:format=>:json}
#                                       DELETE /api/v1/payments/:id(.:format)                                                           api/v1/payments#destroy {:format=>:json}
#                           case_cycles GET    /api/v1/case_cycles(.:format)                                                            api/v1/case_cycles#index {:format=>:json}
#                                       POST   /api/v1/case_cycles(.:format)                                                            api/v1/case_cycles#create {:format=>:json}
#                            case_cycle GET    /api/v1/case_cycles/:id(.:format)                                                        api/v1/case_cycles#show {:format=>:json}
#                                       PATCH  /api/v1/case_cycles/:id(.:format)                                                        api/v1/case_cycles#update {:format=>:json}
#                                       PUT    /api/v1/case_cycles/:id(.:format)                                                        api/v1/case_cycles#update {:format=>:json}
#                                       DELETE /api/v1/case_cycles/:id(.:format)                                                        api/v1/case_cycles#destroy {:format=>:json}
#                     child_case_cycles GET    /api/v1/child_case_cycles(.:format)                                                      api/v1/child_case_cycles#index {:format=>:json}
#                                       POST   /api/v1/child_case_cycles(.:format)                                                      api/v1/child_case_cycles#create {:format=>:json}
#                      child_case_cycle GET    /api/v1/child_case_cycles/:id(.:format)                                                  api/v1/child_case_cycles#show {:format=>:json}
#                                       PATCH  /api/v1/child_case_cycles/:id(.:format)                                                  api/v1/child_case_cycles#update {:format=>:json}
#                                       PUT    /api/v1/child_case_cycles/:id(.:format)                                                  api/v1/child_case_cycles#update {:format=>:json}
#                                       DELETE /api/v1/child_case_cycles/:id(.:format)                                                  api/v1/child_case_cycles#destroy {:format=>:json}
#             child_case_cycle_payments GET    /api/v1/child_case_cycle_payments(.:format)                                              api/v1/child_case_cycle_payments#index {:format=>:json}
#                                       POST   /api/v1/child_case_cycle_payments(.:format)                                              api/v1/child_case_cycle_payments#create {:format=>:json}
#              child_case_cycle_payment GET    /api/v1/child_case_cycle_payments/:id(.:format)                                          api/v1/child_case_cycle_payments#show {:format=>:json}
#                                       PATCH  /api/v1/child_case_cycle_payments/:id(.:format)                                          api/v1/child_case_cycle_payments#update {:format=>:json}
#                                       PUT    /api/v1/child_case_cycle_payments/:id(.:format)                                          api/v1/child_case_cycle_payments#update {:format=>:json}
#                                       DELETE /api/v1/child_case_cycle_payments/:id(.:format)                                          api/v1/child_case_cycle_payments#destroy {:format=>:json}
#                           attendances GET    /api/v1/attendances(.:format)                                                            api/v1/attendances#index {:format=>:json}
#                                       POST   /api/v1/attendances(.:format)                                                            api/v1/attendances#create {:format=>:json}
#                            attendance GET    /api/v1/attendances/:id(.:format)                                                        api/v1/attendances#show {:format=>:json}
#                                       PATCH  /api/v1/attendances/:id(.:format)                                                        api/v1/attendances#update {:format=>:json}
#                                       PUT    /api/v1/attendances/:id(.:format)                                                        api/v1/attendances#update {:format=>:json}
#                                       DELETE /api/v1/attendances/:id(.:format)                                                        api/v1/attendances#destroy {:format=>:json}
#                                       GET    /*path(.:format)                                                                         static#fallback_index_html
#         rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                  action_mailbox/ingresses/postmark/inbound_emails#create
#            rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                     action_mailbox/ingresses/relay/inbound_emails#create
#         rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                  action_mailbox/ingresses/sendgrid/inbound_emails#create
#   rails_mandrill_inbound_health_check GET    /rails/action_mailbox/mandrill/inbound_emails(.:format)                                  action_mailbox/ingresses/mandrill/inbound_emails#health_check
#         rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                  action_mailbox/ingresses/mandrill/inbound_emails#create
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
#
# Routes for Rswag::Ui::Engine:
#
#
# Routes for Rswag::Api::Engine:
#
#
# Routes for LetterOpenerWeb::Engine:
# clear_letters DELETE /clear(.:format)                 letter_opener_web/letters#clear
# delete_letter DELETE /:id(.:format)                   letter_opener_web/letters#destroy
#       letters GET    /                                letter_opener_web/letters#index
#        letter GET    /:id(/:style)(.:format)          letter_opener_web/letters#show
#               GET    /:id/attachments/:file(.:format) letter_opener_web/letters#attachment
