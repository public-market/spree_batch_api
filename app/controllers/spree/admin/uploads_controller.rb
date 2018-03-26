module Spree
  module Admin
    class UploadsController < ResourceController
      private

      def collection # rubocop:disable Metrics/AbcSize
        params[:q] = {} if params[:q].blank?
        uploads = super.order(created_at: :desc)
        @search = uploads.ransack(params[:q])

        @collection = @search.result.page(params[:page]).per(params[:per_page])
      end
    end
  end
end
