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
      return unless field
      return unless status_id_changed?

      closed_status_ids = IssueRank::find_closed_issue_status_ids
      is_closed = closed_status_ids.include?(status_id)
      was_closed = closed_status_ids.include?(status_id_was)
      return if (is_closed && was_closed) || (!is_closed && !was_closed)

      value = CustomValue
        .joins('JOIN issues ON custom_values.customized_id = issues.id')
        .where(:issues => {:project_id => self.project_id})
        .where(:customized_type => 'Issue')
        .where(:custom_field_id => field.id)
        .where(:customized_id => self.id)
        .readonly(false)
        .first
      if value
        rank = IssueRank::max_rank_of_open_issues(self.project_id) + 1
        value.value = rank.to_s
        value.save!
      end
    end

    def renumber_ranks_of_issues_in_project
      field = IssueRank::find_rank_custom_field
      return unless field

      retry_count = 5
      begin
        values = CustomValue
          .joins('JOIN issues ON custom_values.customized_id = issues.id')
          .where(:issues => {:project_id => self.project_id})
          .where(:customized_type => 'Issue')
          .where(:custom_field_id => field.id)
          .readonly(false)
          .to_a
        values.sort_by! do |v|
          [v.value.to_i, v.customized_id == self.id ? 0 : 1, v.customized_id]
        end

        ActiveRecord::Base.transaction do
          values.each_with_index do |v, i|
            rank = (i + 1).to_s
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
    'Rank' # TODO: Use settings instead of hardcoding
  end

  def self.find_rank_custom_field
    CustomField.where(:name => rank_custom_field_name).first
  end

  def self.max_rank_of_open_issues(project_id)
    field = find_rank_custom_field
    return nil unless field

    values = CustomValue
      .joins('JOIN issues ON custom_values.customized_id = issues.id')
      .joins('JOIN issue_statuses ON issues.status_id = issue_statuses.id')
      .where(:issues => {:project_id => project_id})
      .where(:issue_statuses => {:is_closed => 0})
      .where(:customized_type => 'Issue')
      .where(:custom_field_id => field.id)
      .pluck(:value)
    values.map { |v| v.to_i }.max
  end

  def self.find_closed_issue_status_ids
    IssueStatus.where(:is_closed => true).pluck(:id)
  end
end
