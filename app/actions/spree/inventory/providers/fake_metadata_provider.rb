require 'ffaker'

module Spree
  module Inventory
    module Providers
      class FakeMetadataProvider < Spree::BaseAction
        param :isbn

        UNKNOWN_ISBN = 'UNKNOWN_ISBN'.freeze

        def call
          return if isbn == UNKNOWN_ISBN

          {
            isbn: isbn,
            title: FFaker::Book.title,
            author: FFaker::Book.author,
            published_at: 5.years.ago,
            description: FFaker::Book.description,
            images: images,
            subject: FFaker::Book.genre,
            weight: Random.rand(15.0).floor(1),
            height: Random.rand(10.0).floor(1),
            width: Random.rand(5.0).floor(1),
            depth: Random.rand(1.0).floor(1),
            price: Random.rand(100.0).floor(2)
          }
        end

        protected

        def images
          [
            { url: FFaker::Book.cover, title: FFaker::Book.title }
          ]
        end
      end
    end
  end
end
