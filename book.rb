require 'rubygems'
require 'amazon/aws'
require 'amazon/aws/search'

class Book
  def initialize
  end
  def self.search(url)
    begin
      uri = URI.parse(url)
      if /amazon.+?(\d{10})/ =~ uri.to_s then
        isbn = $1
        req = Amazon::AWS::Search::Request.new()
        is = Amazon::AWS::ItemLookup.new('ISBN', {'ItemId' => isbn, 'SearchIndex' => 'Books'})
        rg = Amazon::AWS::ResponseGroup.new(:Medium)
        result = req.search(is, rg) rescue "not book"
        book = Hash.new
        result.item_lookup_response.items.item.each do |i|
          book[:isbn] = i.item_attributes.isbn.to_s
          book[:title] = i.item_attributes.title.to_s
          book[:author] = i.item_attributes.author.to_s
          book[:publisher] = i.item_attributes.publisher.to_s
          book[:date] = i.item_attributes.publication_date.to_s
          book[:price] = i.item_attributes.list_price.amount.to_s
          book[:image] = i.image_sets.image_set.medium_image.url.to_s
        end
        book
      end
    rescue => e
      puts e.message
    end
  end
end
