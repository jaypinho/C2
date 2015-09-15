module Ncr
  module Reporter
    def self.total_last_week
      Proposal.where(client_data_type: "Ncr::WorkOrder")
              .where("created_at > ?",1.week.ago).count
    end

    def self.total_unapproved
      Proposal.pending.where(client_data_type: "Ncr::WorkOrder").count
    end

    def self.ba60_proposals
      budget_proposals("BA60", 1.week.ago)
    end

    def self.ba61_proposals
      budget_proposals("BA61", 1.week.ago)
    end

    def self.ba80_proposals
      budget_proposals("BA80", 1.week.ago)
    end

    # rubocop:disable all
    def self.as_csv(proposals)
      CSV.generate do |csv|
        csv << ['URL', 'Requester', 'Approver', 'CL', 'Function Code', 'Soc Code', 'Created']
        proposals.each do |p|
          csv << [
            Rails.application.routes.url_helpers.url_for(controller: 'proposals', action: 'show', id: p.id, host: DEFAULT_URL_HOST),
            p.requester.email_address,
            p.client_data.approving_official_email_address,
            p.client_data.cl_number,
            p.client_data.function_code,
            p.client_data.soc_code,
            p.created_at
          ]
        end
      end
    end
    # rubocop:enable all

    def self.proposals_pending_approving_official
      # TODO convert to SQL
      Proposal.pending
              .where(client_data_type: 'Ncr::WorkOrder')
              .select{ |p| p.individual_approvals.pluck(:status)[0] == 'actionable' }
    end

    def self.proposals_pending_budget
      # TODO convert to SQL
      Proposal.pending
              .where(client_data_type: 'Ncr::WorkOrder')
              .select{ |p| p.individual_approvals.pluck(:status).last == 'actionable' }
              .sort_by { |pr| pr.client_data.expense_type }
    end

    def self.budget_proposals(type, timespan)
      # TODO convert to SQL
      Proposal.approved
              .where(client_data_type: 'Ncr::WorkOrder')
              .where('created_at > ?', timespan)
              .select { |pr| pr.client_data.expense_type == type }
    end

    # rubocop:disable all
    def self.proposals_tier_one_pending_sql
      tier_one_sql = User.sql_for_role_slug('BA61_tier1_budget_approver', 'ncr')

      approver_sql = <<-SQL.gsub(/^ {8}/, '')
        SELECT a.proposal_id FROM approvals AS a
        WHERE a.status='actionable' AND a.user_id IN (#{tier_one_sql})
      SQL

      work_order_sql = <<-SQL.gsub(/^ {8}/, '')
        SELECT id FROM ncr_work_orders AS nwo
        WHERE nwo.org_code!='#{Ncr::Organization::WHSC_CODE}'
        AND nwo.expense_type IN ('BA60','BA61')
      SQL

      <<-SQL.gsub(/^ {8}/, '')
        SELECT * FROM proposals AS p
        WHERE p.status='pending'
        AND p.client_data_type='Ncr::WorkOrder'
        AND p.client_data_id IN (#{work_order_sql})
        AND p.id IN (#{approver_sql})
      SQL
    end
    # rubocop:enable all

    def self.proposals_tier_one_pending
      Proposal.find_by_sql(self.proposals_tier_one_pending_sql)
    end
  end
end
