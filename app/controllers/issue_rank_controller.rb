class IssueRankController < ApplicationController
  unloadable
  before_filter :find_project

  helper :issues
  helper :projects
  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper

  def update_ranks_with_display_orders
    field = IssueRank::find_rank_custom_field
    unless field
      redirect_to project_issues_path(@project),
        { :flash =>
          { :error =>
            l('issue_rank.create_custome_field_in_advance',
              :field_name => IssueRank::rank_custom_field_name)
          }
        }
      return
    end

    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      ActiveRecord::Base.transaction do
        ensure_issue_custom_field_values(@project, field)

        @visible_issues = @query.issues(:include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
                                :order => sort_clause)
        visible_issues_map = {}
        @visible_issues.each_with_index do |issue, index|
          visible_issues_map[issue.id] = [index, issue]
        end
        last_issue = @visible_issues.max { |issue| issue.id }

        closed_status_ids = IssueRank::find_closed_issue_status_ids

        # NOTE: Rankを一括設定するためにソートする。ソート順は以下の通り。
        # 1. チケット一覧に表示されているチケットの後に非表示のチケット
        # 2. チケット一覧に表示されているチケットはその順
        # 3. 表示されていない場合はRankの値順
        # 4. 表示されていなくてRankが同じ場合はチケットID順
        issues = @project.issues
        issues.sort_by! do |issue|
          index, visible_issue = visible_issues_map[issue.id]
          closed = visible_issue ? closed_status_ids.include?(issue.status_id) : 1
          new_index = index || (last_issue.id + 1)
          v = issue.custom_value_for(field)
          [closed ? 1 : 0, new_index, v.value.to_i, v.customized_id]
        end

        issues.each_with_index do |issue, i|
          rank = (i + 1).to_s
          v = issue.custom_value_for(field)
          if v.value != rank
            v.value = rank
            issue.save!
          end
        end
      end

      redirect_to issues_url,
        { :flash =>
          { :notice => l('issue_rank.finished_renumbering_issue_ranks') }
        }
    else
      redirect_to project_issues_path(@project)
    end
  end

  private
  def find_project
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def issues_url
    request.referer
  end

  def ensure_issue_custom_field_values(project, field)
    project.issues.each do |issue|
      unless issue.custom_value_for(field)
        issue.save_custom_field_values
      end
    end
  end
end
