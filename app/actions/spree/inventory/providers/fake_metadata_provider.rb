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
            title: book_title,
            author: author,
            description: description,
            images: images,
            price: Random.rand(100.0).floor(2),
            properties: {
              isbn: isbn,
              author: FFaker::Book.author,
              format: 'Paperback',
              publisher: FFaker::Product.brand,
              published_at: 5.years.ago,
              edition: '1 Reprint',
              subject: FFaker::Book.genre
            },
            dimensions: {
              weight: Random.rand(15.0).floor(1),
              height: Random.rand(10.0).floor(1),
              width: Random.rand(5.0).floor(1),
              depth: Random.rand(1.0).floor(1)
            }
          }
        end

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
          [{ url: orly_cover, title: book_title }]
        end

        require 'cgi'
        def orly_cover
          'https://orly-appstore.herokuapp.com/generate?'\
            "title=#{CGI.escape(book_title)}&"\
            'top_text=Thanks%20to%20dev.to&'\
            "author=#{CGI.escape(author)}&"\
            "image_code=#{Random.rand(1..40)}&"\
            "guide_text=#{CGI.escape(description)}&"\
            "theme=#{Random.rand(1..16)}"
        end
      end
    end
  end
end
