# Generated via
#  `rails generate hyrax:work Image`
module Hyrax
  class ImagePresenter < Hyrax::WorkShowPresenter
    def genre
      solr_document[:genre_tesim]
    end
  end
end
