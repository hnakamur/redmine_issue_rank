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
puts "update_ranks_with_display_orders. project_id=#{params[:project_id]}."
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
      puts "query.project=#{@query.project}"
      puts "query.filters=#{@query.filters}"
      ActiveRecord::Base.transaction do
        issues = IssueRank::issues_with_available_custom_field(@project, field)
        IssueRank::ensure_issue_custom_field_values(issues, field)
        #ensure_issue_custom_field_values(@project, field)

        @visible_issues = @query.issues(
          :include => [:assigned_to, :tracker, :priority, :category, :fixed_version],
          :order => sort_clause)
        visible_issues_map = {}
        @visible_issues.each_with_index do |issue, index|
puts "visible_issue: i=#{index}, id=#{issue.id}, subject=#{issue.subject}, status=#{issue.status}, project_id=#{issue.project_id}"
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
puts "sort issue.id=#{issue.id}, subject=#{issue.subject}, status=#{issue.status}, index=#{index}, visible_issue=#{visible_issue}"
          closed = visible_issue ? closed_status_ids.include?(issue.status_id) : 1
          new_index = index || (last_issue.id + 1)
          v = issue.custom_value_for(field)
          [closed ? 1 : 0, new_index, v.value.to_i, v.customized_id]
        end

        issues.each_with_index do |issue, i|
          rank = (i + 1).to_s
          v = issue.custom_value_for(field)
          if v.value != rank
puts "change issue.id=#{issue.id}, subject=#{issue.subject}, status=#{issue.status}, rank=#{v.value} -> #{rank}"
            v.value = rank
            v.save!
          end
        end
      end

      redirect_to project_issues_path(@project),
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

  # Retrieve query from session or build a new query
  def retrieve_query
puts "retrieve_query"
    if !params[:query_id].blank?
puts "retrieve_query case#1"
      cond = "project_id IS NULL"
      cond << " OR project_id = #{@project.id}" if @project
      @query = IssueQuery.where(cond).find(params[:query_id])
      raise ::Unauthorized unless @query.visible?
      @query.project = @project
      session[:query] = {:id => @query.id, :project_id => @query.project_id}
      sort_clear
    elsif api_request? || params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
puts "retrieve_query case#2"
      # Give it a name, required to be valid
      @query = IssueQuery.new(:name => "_")
      @query.project = @project
      @query.build_from_params(params)
      session[:query] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
    else
puts "retrieve_query case#3"
      # retrieve from session
      @query = nil
      @query = IssueQuery.find_by_id(session[:query][:id]) if session[:query][:id]
      @query ||= IssueQuery.new(:name => "_", :filters => session[:query][:filters], :group_by => session[:query][:group_by], :column_names => session[:query][:column_names])
      @query.project = @project
    end
puts "retrieve_query query=#{@query.inspect}"
  end

#  def ensure_issue_custom_field_values(project, field)
#    project.issues.each do |issue|
#      unless issue.custom_value_for(field)
#        issue.save_custom_field_values
#      end
#    end
#  end
end
