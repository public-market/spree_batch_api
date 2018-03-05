module Spree
  class Upload < Spree::Base
    has_many :upload_errors, dependent: :destroy

    self.whitelisted_ransackable_attributes = %w[job_id]

    def status
      total.present? && total == processed ? 'completed' : 'processing'
    end
  end
end
