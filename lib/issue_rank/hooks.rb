module IssueRank
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_sidebar_issues_bottom,
              :partial => 'issues/issue_rank_menus'
  end

  module IssueHook
    def self.included(base) # :nodoc:
      base.after_save :adjust_rank_of_other_issues
    end

    # Adds a rates tab to the user administration page
    def adjust_rank_of_other_issues
      field = self.available_custom_fields.find do |field|
        field.name == 'Rank' # TODO: Use settings instead of hardcoding
      end
      return if field.nil?

      retry_count = 5
      begin
        values = CustomValue
          .joins('JOIN issues ON custom_values.customized_id = issues.id')
          .where(:issues => {:project_id => self.project_id})
          .where(:customized_type => 'Issue')
          .where(:custom_field_id => field.id)
          .where('value <> ?', '')
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
end
