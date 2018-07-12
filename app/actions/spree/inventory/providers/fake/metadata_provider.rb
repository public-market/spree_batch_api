require 'ffaker'

module Spree
  module Inventory
    module Providers
      module Fake
        class MetadataProvider < Spree::BaseAction
          param :isbn

          UNKNOWN_ISBN = 'UNKNOWN_ISBN'.freeze

          # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          def call
            return if isbn == UNKNOWN_ISBN

            {
              title: book_title,
              author: author,
              description: description,
              images: images,
              price: Random.rand(100.0).round(2),
              properties: {
                isbn: isbn,
                author: FFaker::Book.author,
                format: 'Paperback',
                publisher: FFaker::Product.brand,
                published_at: 5.years.ago,
                edition: '1 Reprint',
                subject: FFaker::Book.genre,
                empty: nil
              },
              dimensions: {
                weight: Random.rand(15.0).round(1),
                height: Random.rand(10.0).round(1),
                width: Random.rand(5.0).round(1),
                depth: Random.rand(1.0).round(1)
              },
              taxons: %w[General Book]
            }
          end
          # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

          def book_title
            @book_title ||= FFaker::Book.title
          end

          def description
            @description ||= FFaker::Book.description
          end

          def author
            @author ||= FFaker::Book.author
          end

          protected

          def images
            [{ url: fake_image_url, title: book_title }]
          end

          def fake_image_url
            'https://fakeimg.pl/1/'
          end
        end
      end
    end
  end
end
