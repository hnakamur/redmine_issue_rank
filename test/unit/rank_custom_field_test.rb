require File.expand_path('../../test_helper', __FILE__)

class RankCustomFieldTest < ActiveSupport::TestCase
  fixtures :projects, :users, :trackers, :projects_trackers, :issue_statuses

  def test_create_issues_with_rank
    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
    assert_equal 'Rank', Setting.plugin_redmine_issue_rank['rank_custom_field_name']

    project = projects(:projects_001)
    user = users(:users_002)
    tracker = trackers(:trackers_001)
    field = IssueCustomField.create!(
      :name => 'Rank',
      :type => 'IssueCustomField',
      :field_format => 'int',
      :projects => [project],
      :trackers => [tracker])

    issue1 = Issue.new(
      :subject => "issue11",
      :project => project,
      :author => user,
      :tracker => tracker)
    issue1.custom_field_values = { field.id.to_s => 1.to_s }
    issue1.save!
    assert_equal 1, issue1.custom_value_for(field).value.to_i
    issue1.reload
    assert_equal 1, issue1.custom_value_for(field).value.to_i

#    issue2 = Issue.new(
#      :subject => "issue22",
#      :project => project,
#      :author => user,
#      :tracker => tracker)
#    issue2.custom_field_values = { field.id.to_s => 2.to_s }
#    issue2.save!
#    assert_equal 2, issue2.custom_value_for(field).value.to_i
#    assert_equal 1, issue1.custom_value_for(field).value.to_i

#    issue1 = issues(:issues_001)
#    issue1.save!
#    assert_equal 1, issue1.custom_value_for(field).value.to_i

#    issue_count = 3
#    issues = []
#    1.upto(issue_count) do |i|
#      issue = Issue.new(
#        :subject => "issue#{i}",
#        :project => project,
#        :author => user,
#        :tracker => tracker)
#      issue.custom_field_values = { field.id.to_s => i.to_s }
#      issue.save!
#      issues << issue
#    end
#    issues.each_with_index do |issue, i|
#      issue.reload
#      assert_equal i + 1, issue.custom_value_for(field).value.to_i
#    end
  end

#  def test_create_issues_with_default_rank
#    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
#
#    project = projects(:projects_001)
#    user = users(:users_002)
#    tracker = trackers(:trackers_001)
#    field = IssueCustomField.create!(
#      :name => 'Rank',
#      :type => 'IssueCustomField',
#      :field_format => 'int',
#      :projects => [project],
#      :trackers => [tracker])
#
#    issue_count = 3
#    issues = []
#    1.upto(issue_count) do |i|
#      issue = Issue.new(
#        :subject => "issue#{i}",
#        :project => project,
#        :author => user,
#        :tracker => tracker)
#      issue.save!
#      issues << issue
#    end
#    issues.each_with_index do |issue, i|
#      issue.reload
#      assert_equal issue_count - i, issue.custom_value_for(field).value.to_i
#    end
#  end
#
#  def test_change_rank_higher
#    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
#
#    project = projects(:projects_001)
#    user = users(:users_002)
#    tracker = trackers(:trackers_001)
#    field = IssueCustomField.create!(
#      :name => 'Rank',
#      :type => 'IssueCustomField',
#      :field_format => 'int',
#      :projects => [project],
#      :trackers => [tracker])
#
#    issue_count = 3
#    issues = []
#    1.upto(issue_count) do |i|
#      issue = Issue.new(
#        :subject => "issue#{i}",
#        :project => project,
#        :author => user,
#        :tracker => tracker)
#      issue.save!
#      issues << issue
#    end
#
#    issues[2].custom_field_values = { field.id.to_s => 1.to_s }
#    issues[2].save!
#
#    issues[0].reload
#    assert_equal 3, issues[0].custom_value_for(field).value.to_i
#    issues[1].reload
#    assert_equal 2, issues[1].custom_value_for(field).value.to_i
#    issues[2].reload
#    assert_equal 1, issues[2].custom_value_for(field).value.to_i
#  end
#
#  def test_change_rank_lower
#    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
#
#    project = projects(:projects_001)
#    user = users(:users_002)
#    tracker = trackers(:trackers_001)
#    field = IssueCustomField.create!(
#      :name => 'Rank',
#      :type => 'IssueCustomField',
#      :field_format => 'int',
#      :projects => [project],
#      :trackers => [tracker])
#
#    issue_count = 3
#    issues = []
#    1.upto(issue_count) do |i|
#      issue = Issue.new(
#        :subject => "issue#{i}",
#        :project => project,
#        :author => user,
#        :tracker => tracker)
#      issue.custom_field_values = { field.id.to_s => i.to_s }
#      issue.save!
#      issues << issue
#    end
#
#    issues[0].reload
#    issues[0].custom_field_values = { field.id.to_s => 4.to_s }
#    issues[0].save!
#
#    issues[0].reload
#    assert_equal 3, issues[0].custom_value_for(field).value.to_i
#    issues[1].reload
#    assert_equal 1, issues[1].custom_value_for(field).value.to_i
#    issues[2].reload
#    assert_equal 2, issues[2].custom_value_for(field).value.to_i
#  end
#
#  def test_close_issue
#    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
#
#    project = projects(:projects_001)
#    user = users(:users_002)
#    tracker = trackers(:trackers_001)
#    field = IssueCustomField.create!(
#      :name => 'Rank',
#      :type => 'IssueCustomField',
#      :field_format => 'int',
#      :projects => [project],
#      :trackers => [tracker])
#
#    issue_count = 3
#    issues = []
#    1.upto(issue_count) do |i|
#      issue = Issue.new(
#        :subject => "issue#{i}",
#        :project => project,
#        :author => user,
#        :tracker => tracker)
#      issue.custom_field_values = { field.id.to_s => i.to_s }
#      issue.save!
#      issues << issue
#    end
#
#    issues[0].reload
#    issues[0].status = IssueStatus::named('Closed').first
#    issues[0].save!
#
#    issues[0].reload
#    assert_equal 3, issues[0].custom_value_for(field).reload.value.to_i
#    issues[1].reload
#    assert_equal 1, issues[1].custom_value_for(field).reload.value.to_i
#    issues[2].reload
#    assert_equal 2, issues[2].custom_value_for(field).reload.value.to_i
#  end
#
#  def test_close_two_issues
#    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
#
#    project = projects(:projects_001)
#    user = users(:users_002)
#    tracker = trackers(:trackers_001)
#    field = IssueCustomField.create!(
#      :name => 'Rank',
#      :type => 'IssueCustomField',
#      :field_format => 'int',
#      :projects => [project],
#      :trackers => [tracker])
#
#    issue_count = 3
#    issues = []
#    1.upto(issue_count) do |i|
#      issue = Issue.new(
#        :subject => "issue#{i}",
#        :project => project,
#        :author => user,
#        :tracker => tracker)
#      issue.custom_field_values = { field.id.to_s => i.to_s }
#      issue.save!
#      issues << issue
#    end
#
#    issues[0].reload
#    issues[0].status = IssueStatus::named('Closed').first
#    issues[0].save!
#
#    issues[1].reload
#    issues[1].status = IssueStatus::named('Closed').first
#    issues[1].save!
#
#    issues[0].reload
#    assert_equal 3, issues[0].custom_value_for(field).reload.value.to_i
#    issues[1].reload
#    assert_equal 2, issues[1].custom_value_for(field).reload.value.to_i
#    issues[2].reload
#    assert_equal 1, issues[2].custom_value_for(field).reload.value.to_i
#  end
#
#  def test_reopen_issue
#    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
#
#    project = projects(:projects_001)
#    user = users(:users_002)
#    tracker = trackers(:trackers_001)
#    field = IssueCustomField.create!(
#      :name => 'Rank',
#      :type => 'IssueCustomField',
#      :field_format => 'int',
#      :projects => [project],
#      :trackers => [tracker])
#
#    issue_count = 3
#    issues = []
#    1.upto(issue_count) do |i|
#      issue = Issue.new(
#        :subject => "issue#{i}",
#        :project => project,
#        :author => user,
#        :tracker => tracker)
#      issue.custom_field_values = { field.id.to_s => i.to_s }
#      issue.save!
#      issues << issue
#    end
#
#    issues[0].reload
#    issues[0].status = IssueStatus::named('Closed').first
#    issues[0].save!
#
#    issues[1].reload
#    issues[1].status = IssueStatus::named('Closed').first
#    issues[1].save!
#
#    issues[0].reload
#    issues[0].status = IssueStatus::named('Assigned').first
#    issues[0].save!
#
#    issues[0].reload
#    assert_equal 2, issues[0].custom_value_for(field).reload.value.to_i
#    issues[1].reload
#    assert_equal 3, issues[1].custom_value_for(field).reload.value.to_i
#    issues[2].reload
#    assert_equal 1, issues[2].custom_value_for(field).reload.value.to_i
#  end
end
