require File.expand_path('../../test_helper', __FILE__)

class IssueRankTest < ActionController::IntegrationTest
  fixtures :projects, :trackers, :issue_statuses, :issues,
           :enumerations, :users, :issue_categories,
           :projects_trackers,
           :roles,
           :member_roles,
           :members,
           :enabled_modules

  def test_issue_rank_update_ranks_with_display_orders_with_id_order
    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
    project1 = projects(:projects_001)
    tracker1 = trackers(:trackers_001)
    tracker2 = trackers(:trackers_002)
    field = IssueCustomField.create!(
      :name => 'Rank',
      :type => 'IssueCustomField',
      :field_format => 'int',
      :projects => [project1],
      :trackers => [tracker1])

    log_user('jsmith', 'jsmith')

    get "/projects/#{project1.identifier}/issues",
      {
        :set_filter => '1',
        :'f[]' => ['subproject_id', ''],
        :'op[subproject_id]' => '!*',
        :sort => 'id,cf_1'
      }
    assert_response :success
    assert_template 'issues/index'

    post "/projects/#{project1.identifier}/issue_rank/update_ranks_with_display_orders",
      { :sort => 'id,cf_1' }
    assert_response 302
    assert_equal nil, flash[:error]
    assert_equal I18n.t('issue_rank.finished_renumbering_issue_ranks'), flash[:notice]
    follow_redirect!

    issues = Issue.where(:project_id => project1.id).order('id')
    issues = issues.select {|issue| issue.tracker.custom_fields.include?(field)}
    issues.each_with_index do |issue, i|
      assert_equal i + 1, issue.custom_value_for(field).value.to_i
    end
  end

  def test_issue_rank_update_ranks_with_display_orders_with_id_desc_order
    Setting.plugin_redmine_issue_rank['rank_custom_field_name'] = 'Rank'
    project1 = projects(:projects_001)
    tracker1 = trackers(:trackers_001)
    tracker2 = trackers(:trackers_002)
    field = IssueCustomField.create!(
      :name => 'Rank',
      :type => 'IssueCustomField',
      :field_format => 'int',
      :projects => [project1],
      :trackers => [tracker1, tracker2])

    log_user('jsmith', 'jsmith')

    get "/projects/#{project1.identifier}/issues",
      {
        :set_filter => '1',
        :'f[]' => ['subproject_id', ''],
        :'op[subproject_id]' => '!*',
        :sort => 'id:desc,cf_1'
      }
    assert_response :success
    assert_template 'issues/index'

    post "/projects/#{project1.identifier}/issue_rank/update_ranks_with_display_orders"

    assert_response 302
    assert_equal nil, flash[:error]
    assert_equal I18n.t('issue_rank.finished_renumbering_issue_ranks'), flash[:notice]
    follow_redirect!

    issues = Issue.where(:project_id => project1.id).order('id DESC')
    issues = issues.select {|issue| issue.tracker.custom_fields.include?(field)}
    issues.each_with_index do |issue, i|
      assert_equal i + 1, issue.custom_value_for(field).value.to_i
    end
  end
end
