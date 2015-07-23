require 'issue_rank/hooks'

# Guards against including the module multiple time (like in tests)
# and registering multiple callbacks
unless Issue.included_modules.include? IssueRank::IssueHook
  Issue.send(:include, IssueRank::IssueHook)
end

Redmine::Plugin.register :redmine_issue_rank do
  name 'Redmine Issue Rank plugin'
  author 'Hiroaki Nakamura'
  description 'Automatically renumber ranks of issues in a project which are saved in the specific custom fields'
  version '0.2.0'
  url 'https://github.com/hnakamur/redmine_issue_rank'
  author_url 'https://github.com/hnakamur'

  project_module :issue_rank do
    permission :renumber_ranks_with_display_orders, {:issue_rank => :update_ranks_with_display_orders}, :require => :member
  end
  settings :default => { 'rank_custom_field_name' => 'Rank' }, :partial => 'settings/issue_rank'
end

