module Spree
  class Upload < Spree::Base
    has_many :upload_errors, dependent: :destroy

    self.whitelisted_ransackable_attributes = %w[job_id status]

    state_machine :status, initial: :processing do
      event :complete do
        transition to: :completed
      end

      event :fail do
        transition to: :failed
      end
    end
  end
end
