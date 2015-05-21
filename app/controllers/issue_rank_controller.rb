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
    Rails.logger.error "###update_ranks_with_display_orders."
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      Rails.logger.error "###query=#{@query}"
      Rails.logger.error "###sort_clause=#{@sort_clause}"
      @issues = @query.issues(:order => sort_clause)
      issues_map = {}
      @issues.each_with_index do |issue, index|
        issues_map[issue.id] = [index, issue]
      end
      last_issue = @issues.max { |issue| issue.id }
      Rails.logger.error "###issues=#{@issues}"

      custom_field_name = 'Rank' # TODO use settings instead of hardcoding
      values = CustomValue
        .joins('JOIN custom_fields ON custom_values.custom_field_id = custom_fields.id')
        .joins('JOIN issues ON custom_values.customized_id = issues.id')
        .where(:customized_type => 'Issue')
        .where(:custom_fields => {:name => custom_field_name})
        .where(:issues => {:project_id => @project.id})
        .readonly(false)
        .to_a
      values.sort_by! do |v|
        issue_id = v.customized_id
        index_and_issue = issues_map[v.customized_id]
        index = index_and_issue ? index_and_issue[0] : (last_issue.id + 1)
        [index, v.value.to_i, v.customized_id]
      end

      ActiveRecord::Base.transaction do
        values.each_with_index do |v, i|
          issue = issues_map[v.customized_id].try(:'[]', 1)
          if issue && issue.closed_on.nil?
            rank = (i + 1).to_s
            if v.value != rank
              v.value = rank
              v.save!
            end
          end
        end
      end

      redirect_to issues_url
    else
      redirect_to project_issues_path(@project)
    end
  end

  def clear_closed_issues_ranks
    Rails.logger.error "###clear_closed_issues_ranks"
    custom_field_name = 'Rank' # TODO use settings instead of hardcoding
    ActiveRecord::Base.transaction do
      CustomValue
        .joins('JOIN custom_fields ON custom_values.custom_field_id = custom_fields.id')
        .joins('JOIN issues ON custom_values.customized_id = issues.id')
        .where(:customized_type => 'Issue')
        .where(:custom_fields => {:name => custom_field_name})
        .where(:issues => {:project_id => @project.id})
        .where('issues.closed_on IS NOT NULL')
        .update_all(:value => '')

      values = CustomValue
        .joins('JOIN custom_fields ON custom_values.custom_field_id = custom_fields.id')
        .joins('JOIN issues ON custom_values.customized_id = issues.id')
        .where(:customized_type => 'Issue')
        .where(:custom_fields => {:name => custom_field_name})
        .where(:issues => {:project_id => @project.id})
        .where('value <> ?', '')
        .readonly(false)
        .to_a
      values.sort_by! { |v| [v.value.to_i, v.customized_id] }

      values.each_with_index do |v, i|
        rank = (i + 1).to_s
        if v.value != rank
          v.value = rank
          v.save!
        end
      end
    end

    redirect_to issues_url
  end

  private
  def find_project
    project_id = params[:project_id] || (params[:issue] && params[:issue][:project_id])
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def issues_url
    Rails.logger.error "###issues_url. referer=#{request.referer}, url=#{request.url}"
    request.referer
  end
end
