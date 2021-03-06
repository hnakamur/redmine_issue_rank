module IssueRank
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_sidebar_issues_bottom,
              :partial => 'issues/issue_rank_menus'
  end

  module IssueHook
    def self.included(base) # :nodoc:
      base.before_update :adjust_rank_when_closed_or_reopened
      base.after_save :renumber_ranks_of_issues_in_project
    end

    def adjust_rank_when_closed_or_reopened
      field = IssueRank::find_rank_custom_field
      return unless available_custom_fields.include?(field)
      return unless status_id_changed?

      closed_status_ids = IssueRank::find_closed_issue_status_ids
      is_closed = closed_status_ids.include?(status_id)
      was_closed = closed_status_ids.include?(status_id_was)
      return if (is_closed && was_closed) || (!is_closed && !was_closed)

      value = custom_value_for(field)
      if value
        rank = IssueRank::max_rank_of_open_issues(project) + 1
        self.custom_field_values = { field.id.to_s => rank.to_s }
      end
    end

    def renumber_ranks_of_issues_in_project
      field = IssueRank::find_rank_custom_field
      return unless available_custom_fields.include?(field)

      retry_count = 5
      begin
        issues = IssueRank::issues_with_available_custom_field(project, field)
        IssueRank::ensure_issue_custom_field_values(issues, field)
        issues.each { |issue| issue.reload }
        issues.sort_by! do |issue|
          v = issue.custom_value_for(field)
          has_value = v.value.present?
          [
            has_value ? 0 : 1,
            has_value ? v.value.to_i : 0,
            v.customized_id == self.id ? 0 : 1, v.customized_id
          ]
        end
        ActiveRecord::Base.transaction do
          issues.each_with_index do |issue, i|
            rank = (i + 1).to_s
            v = issue.custom_value_for(field)
            if v.value != rank
              v.value = rank
              v.save!
            end
          end
        end
      rescue ActiveRecord::StaleObjectError
        retry_count -= 1
        if retry_count > 0
          retry
        else
          # TODO: raise user friendly error
          raise
        end
      end
    end
  end

  def self.rank_custom_field_name
    Setting.plugin_redmine_issue_rank['rank_custom_field_name']
  end

  def self.find_rank_custom_field
    CustomField.where(:name => rank_custom_field_name).first
  end

  def self.max_rank_of_open_issues(project)
    field = find_rank_custom_field
    return nil unless field

    open_issues = project.issues.select { |issue| !issue.status.is_closed }
    ranks = open_issues.map do |issue|
      v = issue.custom_value_for(field)
      v ? v.value.to_i : nil
    end
    ranks.compact.max
  end

  def self.find_closed_issue_status_ids
    IssueStatus.where(:is_closed => true).pluck(:id)
  end

  def self.issues_with_available_custom_field(project, field)
    project.issues.select do |issue|
      issue.available_custom_fields.include?(field)
    end
  end

  def self.ensure_issue_custom_field_values(issues, field)
    issues.each do |issue|
      if issue.tracker.custom_fields.include?(field) &&
          !issue.custom_value_for(field)
        issue.save_custom_field_values
      end
    end
  end
end
