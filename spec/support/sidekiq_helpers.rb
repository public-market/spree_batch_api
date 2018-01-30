module Sidekiq
  module Status
    class << self
      def status(_jid)
        :complete
      end
    end

    module Storage
      # rubocop:disable Style/ClassVars
      def storage(id)
        @@storage ||= {}
        @@storage[id] ||= {}
      end
      # rubocop:enable Style/ClassVars

      def store_for_id(id, status_updates, _expiration = nil, _redis_pool = nil)
        storage(id).merge!(status_updates)
      end

      def read_field_for_id(id, field)
        storage(id)[field]
      end
    end
  end
end

RSpec.configure do |config|
  config.around(:each, run_jobs: true) do |example|
    Sidekiq::Testing.inline!
    example.run
    Sidekiq::Testing.fake!
  end

  # SidekiqUniqueJobs.configure do |cfg|
  #   cfg.redis_test_mode = :redis
  # end

  config.before do
    Sidekiq::Queues.clear_all
    Sidekiq.redis(&:flushdb)
  end
end

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end
