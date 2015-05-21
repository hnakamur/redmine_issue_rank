# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

post '/project/:project_id/issue_rank/update_ranks_with_display_orders', :to => 'issue_rank#update_ranks_with_display_orders', :as => 'issue_rank_update_ranks_with_display_orders'
