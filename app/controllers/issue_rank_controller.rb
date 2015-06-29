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
            t('issue_rank.create_custome_field_in_advance',
              :field_name => IssueRank::rank_custom_field_name)
          }
        }
      return
    end

    retrieve_query

    if @query.project && !@query.project.descendants.active.empty? &&
       !(@query.has_filter?("subproject_id") && @query.operator_for("subproject_id") == '!*')
      redirect_to project_issues_path(@project),
        { :flash => { :error => t('issue_rank.please_use_no_subject_filter') } }
      return
    end

    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      ActiveRecord::Base.transaction do
        filtered_issues = @query.issues(:order => sort_clause)
        filtered_issue_map = {}
        filtered_issues.each_with_index do |issue, index|
          filtered_issue_map[issue.id] = index
        end
        
        issues = IssueRank::issues_with_available_custom_field(@project, field)
        IssueRank::ensure_issue_custom_field_values(issues, field)
        issues.sort_by! do |issue|
          index = filtered_issue_map[issue.id]
          if index
            [0, index]
          else
            v = issue.custom_value_for(field)
            if v
              [1, v.value]
            else
              [2, -issue.id]
            end
          end
        end

        rank = 0
        issues.each do |issue|
          v = issue.custom_value_for(field)
          if v
            rank += 1
            if v.value != rank
              v.value = rank
              v.save!
            end
          end
        end
      end

      redirect_to project_issues_path(@project),
        { :flash =>
          { :notice => t('issue_rank.finished_renumbering_issue_ranks') }
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
end
