require File.expand_path('../../test_helper', __FILE__)

class RankCustomFieldTest < ActiveSupport::TestCase
  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules

  def test_update_issue_with_rank_case1
    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
    assert_equal 'Rank', Setting.plugin_redmine_issue_rank['rank_custom_field_name']

    project1 = projects(:projects_001)
    user2 = users(:users_002)
    tracker1 = trackers(:trackers_001)
    field = IssueCustomField.create!(
      :name => 'Rank',
      :type => 'IssueCustomField',
      :field_format => 'int',
      :projects => [project1],
      :trackers => [tracker1])

    issue1 = issues(:issues_001)
    issue1.custom_field_values = { field.id.to_s => 1.to_s }
    issue1.save!
    issue1.reload

    target_issues = [
      :issues_001, :issues_003, :issues_007, :issues_008, :issues_011,
      :issues_012
    ].map { |name| issues(name) }
    target_issues.each_with_index do |issue, i|
      assert_equal i + 1, issue.custom_value_for(field).value.to_i
    end
    project1.issues.each do |issue|
      unless target_issues.include?(issue)
        assert_equal nil, issue.custom_value_for(field)
      end
    end
  end

  def test_update_issue_with_rank_case2
    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
    assert_equal 'Rank', Setting.plugin_redmine_issue_rank['rank_custom_field_name']

    project1 = projects(:projects_001)
    user2 = users(:users_002)
    tracker1 = trackers(:trackers_001)
    field = IssueCustomField.create!(
      :name => 'Rank',
      :type => 'IssueCustomField',
      :field_format => 'int',
      :projects => [project1],
      :trackers => [tracker1])

    issue3 = issues(:issues_003)
    issue3.custom_field_values = { field.id.to_s => 1.to_s }
    issue3.save!
    issue3.reload

    target_issues = [
      :issues_003, :issues_001, :issues_007, :issues_008, :issues_011,
      :issues_012
    ].map { |name| issues(name) }
    target_issues.each_with_index do |issue, i|
      assert_equal i + 1, issue.custom_value_for(field).value.to_i
    end
    project1.issues.each do |issue|
      unless target_issues.include?(issue)
        assert_equal nil, issue.custom_value_for(field)
      end
    end
  end

  def test_change_rank_higher
    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
    assert_equal 'Rank', Setting.plugin_redmine_issue_rank['rank_custom_field_name']

    project1 = projects(:projects_001)
    user2 = users(:users_002)
    tracker1 = trackers(:trackers_001)
    field = IssueCustomField.create!(
      :name => 'Rank',
      :type => 'IssueCustomField',
      :field_format => 'int',
      :projects => [project1],
      :trackers => [tracker1])

    issue1 = issues(:issues_001)
    issue1.custom_field_values = { field.id.to_s => 1.to_s }
    issue1.save!
    issue1.reload

    issue7 = issues(:issues_007)
    issue7.custom_field_values = { field.id.to_s => 1.to_s }
    issue7.save!
    issue7.reload

    target_issues = [
      :issues_007, :issues_001, :issues_003, :issues_008, :issues_011,
      :issues_012
    ].map { |name| issues(name) }
    target_issues.each_with_index do |issue, i|
      assert_equal i + 1, issue.custom_value_for(field).value.to_i
    end
    project1.issues.each do |issue|
      unless target_issues.include?(issue)
        assert_equal nil, issue.custom_value_for(field)
      end
    end
  end

  def test_change_rank_lower
    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
    assert_equal 'Rank', Setting.plugin_redmine_issue_rank['rank_custom_field_name']

    project1 = projects(:projects_001)
    user2 = users(:users_002)
    tracker1 = trackers(:trackers_001)
    field = IssueCustomField.create!(
      :name => 'Rank',
      :type => 'IssueCustomField',
      :field_format => 'int',
      :projects => [project1],
      :trackers => [tracker1])

    issue1 = issues(:issues_001)
    issue1.custom_field_values = { field.id.to_s => 1.to_s }
    issue1.save!
    issue1.reload

    issue1.custom_field_values = { field.id.to_s => 3.to_s }
    issue1.save!
    issue1.reload

    target_issues = [
      :issues_003, :issues_001, :issues_007, :issues_008, :issues_011,
      :issues_012
    ].map { |name| issues(name) }
    target_issues.each_with_index do |issue, i|
      assert_equal i + 1, issue.custom_value_for(field).value.to_i
    end
    project1.issues.each do |issue|
      unless target_issues.include?(issue)
        assert_equal nil, issue.custom_value_for(field)
      end
    end
  end

  def test_close_issue
    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
    assert_equal 'Rank', Setting.plugin_redmine_issue_rank['rank_custom_field_name']

    project1 = projects(:projects_001)
    user2 = users(:users_002)
    tracker1 = trackers(:trackers_001)
    field = IssueCustomField.create!(
      :name => 'Rank',
      :type => 'IssueCustomField',
      :field_format => 'int',
      :projects => [project1],
      :trackers => [tracker1])

    issue1 = issues(:issues_001)
    issue1.custom_field_values = { field.id.to_s => 1.to_s }
    issue1.save!
    issue1.reload

    issue1.status = IssueStatus.named('Closed').first
    issue1.save!
    issue1.reload

    target_issues = [
      :issues_003, :issues_007, :issues_001, :issues_008, :issues_011,
      :issues_012
    ].map { |name| issues(name) }
    target_issues.each_with_index do |issue, i|
      assert_equal i + 1, issue.custom_value_for(field).value.to_i
    end
    project1.issues.each do |issue|
      unless target_issues.include?(issue)
        assert_equal nil, issue.custom_value_for(field)
      end
    end
  end
end
