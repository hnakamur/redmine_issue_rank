require 'issue_rank/hooks'

# Guards against including the module multiple time (like in tests)
# and registering multiple callbacks
unless Issue.included_modules.include? IssueRank::IssueHook
Issue.send(:include, IssueRank::IssueHook)
end

Redmine::Plugin.register :redmine_issue_rank_plugin do
  name 'Redmine Issue Rank Plugin plugin'
  author 'Author name'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end

