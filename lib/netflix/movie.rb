module Netflix
  # This class represents a title in the Netflix catalog
  class Movie < Base
    attr_accessor :netflix_id, :url, :title, :short_title, :box_art_small, :box_art_medium, :box_art_large, 
      :release_year, :mpaa_rating, :genres, :average_rating,
      # urls
      :cast_url, :directors_url, :formats_url, :screen_formats_url, :awards_url, :webpage_url,
      :languages_and_audio_url, :similars_url, :official_webpage_url, :synopsis_url

    #-----------------
    # Class Methods
    #-----------------

    class << self
      # Returns movie and television titles that match a partial search text. The title names can be 
      # passed to the title search API to conduct the actual search.
      #
      # ==== Attributes
      #
      # * +term+ - The partial or complete search term to use to search for title matches in the catalog.
      #
      # ==== Examples
      #
      #   Netflix::Movie.autocomplete_search('terminator')
      #   > [[#<Netflix::Movie:0x1882358>, ... ]
      def autocomplete_search(term, options={})
        options.symbolize_keys!

        params        = {}
        params[:term] = URI.escape(term)

        response = request "GET", "catalog/titles/autocomplete", params
        titles = Hash.from_xml(response)["autocomplete"]["autocomplete_item"].map { |i| i["title"]["short"] }
      end
      
      # Find a movie by its Netflix ID.
      def find(netflix_id)
        response = signed_request "GET", "catalog/titles/movies/#{netflix_id}"
        raise Error, "Movie not found!" if response.nil? || response.empty?
        parse_one response
      end
      
      # Search for all movies with a query.
      #
      # ==== Attributes
      #
      # * +term+ - The word or term for which to search in the catalog. The method searches the title and 
      #            synopses of catalog titles fields for a match.
      # * +options+ - 
      #    * <tt>:page/tt> - the page number of results; 20 shown at a time (default is 1, per_page is required) 
      #    * <tt>:per_page</tt> - the maximum number of results to return. This number cannot be greater than 100. 
      #                           If max_results is not specified, the default value is 25.
      #
      # ==== Examples
      #
      #   Netflix::Movie.search('neon')
      #   > [[#<Netflix::Movie:0x1882358>, ... ]
      def search(term, options={})
        options.symbolize_keys!

        params                   = {}
        params[:term]            = URI.escape(term)
        params[:start_index]     = ((options[:page] - 1) * 20) if options[:page]
        params[:max_results]     = options[:per_page] if options[:per_page]

        response = signed_request "GET", "catalog/titles", params
        
        raise Error, "No movies found!" if response.nil? || response.empty?
        parse_many response
      end
      
      def index
        # TODO
      end
      
      protected
      # Parses a response xml string for movie.
      def parse_many(body) # :nodoc:
        xml = Hash.from_xml(body)
        results = xml["catalog_titles"]["catalog_title"]
        if results.is_a?(Hash) # one results
          instantiate results
        else # many results
          results.map { |result| instantiate result }
        end
      end

      # Parses a response xml string for a movie.
      def parse_one(body) # :nodoc:
        xml = Hash.from_xml(body)
        result = xml["catalog_title"]
        # raise Error, "That movie not found!" if result.nil?
        instantiate result
      end
      
      def instantiate(entry={})
        Movie.new(:url => entry['id'],
          :netflix_id => entry['id'].split('/').last,
          :title => entry['title']['regular'],
          :short_title => entry['title']['short'],
          :box_art_small => entry['box_art']['small'],
          :box_art_medium => entry['box_art']['medium'],
          :box_art_large => entry['box_art']['large'],
          :release_year => entry['release_year'],
          :mpaa_rating => (entry['category'].find { |c| c['scheme'] =~ /mpaa_ratings/ }['label'] rescue nil),
          :genres => (entry['category'].select { |c| c['scheme'] =~ /genres/ }.map { |c| c['label'] } rescue nil),
          :average_rating => entry['average_rating'],
          :formats_url => (entry['link'].find { |l| l['title'] == 'formats' }['href'] rescue nil),
          :awards_url => (entry['link'].find { |l| l['title'] == 'awards' }['href'] rescue nil),
          :languages_and_audio_url => (entry['link'].find { |l| l['title'] == 'languages and audio' }['href'] rescue nil),
          :webpage_url => (entry['link'].find { |l| l['title'] == 'web page' }['href'] rescue nil),
          :official_webpage_url => (entry['link'].find { |l| l['title'] == 'official webpage' }['href'] rescue nil),
          :synopsis_url => (entry['link'].find { |l| l['title'] == 'synopsis' }['href'] rescue nil),
          :cast_url => (entry['link'].find { |l| l['title'] == 'cast' }['href'] rescue nil),
          :directors_url => (entry['link'].find { |l| l['title'] == 'directors' }['href'] rescue nil),
          :screen_formats_url => (entry['link'].find { |l| l['title'] == 'screen formats' }['href'] rescue nil),
          :similars_url => (entry['link'].find { |l| l['title'] == 'similars' }['href'] rescue nil))
      end
    end
    
    def awards
      return @awards if @awards
      response = self.class.signed_request "GET", "catalog/titles/movies/#{@netflix_id}/awards"
      @awards = Hash.from_xml(response)["awards"]["award_winner"].map { |a| Award.new(a) } rescue []
    end
    
    def synopsis
      return @synopsis if @synopsis
      response = self.class.signed_request "GET", "catalog/titles/movies/#{@netflix_id}/synopsis"
      @synopsis = Hash.from_xml(response)["synopsis"] rescue nil
    end

    
    def languages_and_audio
      return @languages_and_audio if @languages_and_audio
      response = self.class.signed_request "GET", "catalog/titles/movies/#{@netflix_id}/languages_and_audio"
      by_format = Hash.from_xml(response)["languages_and_audio"]["language_audio_format"]
      # TODO
    end
    
    def formats
      return @formats if @formats
      response = self.class.signed_request "GET", "catalog/titles/movies/#{@netflix_id}/format_availability"
      @formats = Hash.from_xml(response)["delivery_formats"]["availability"].map { |f| f["category"]["label"] } rescue nil
    end
    
    def cast
      return @cast if @cast
      response = self.class.signed_request "GET", "catalog/titles/movies/#{@netflix_id}/cast"
      @cast = Person.send(:parse_many, response) rescue nil
    end
    
    def directors
      return @directors if @directors
      response = self.class.signed_request "GET", "catalog/titles/movies/#{@netflix_id}/directors"
      @directors = Person.send(:parse_many, response) rescue nil
    end
    
    def screen_formats
      return @formats if @formats
      response = self.class.signed_request "GET", "catalog/titles/movies/#{@netflix_id}/screen_formats"
      @formats = Hash.from_xml(response)["screen_formats"]["screen_format"].map { |f| f["category"].map { |g| g["label"] } } rescue nil
    end

    # start_index
    #
    # ==== Attributes
    #
    # * +term+ - The word or term for which to search in the catalog. The method searches the title and 
    #            synopses of catalog titles fields for a match.
    # * +options+ - 
    #    * <tt>:page/tt> - the page number of results; 20 shown at a time (default is 1, per_page is required) 
    #    * <tt>:per_page</tt> - the maximum number of results to return. This number cannot be greater than 100. 
    #                           If max_results is not specified, the default value is 25.
    #
    def similars(options={})
      options.symbolize_keys!

      params                   = {}
      params[:start_index]     = ((options[:page] - 1) * 20) if options[:page]
      params[:max_results]     = options[:per_page] if options[:per_page]

      response = self.class.signed_request "GET", "catalog/titles/movies/#{@netflix_id}/similars", params
      items = Hash.from_xml(response)["similars"]["similars_item"]
      if items.is_a?(Hash) # one
        Movie.send(:instantiate, s)
      else # many
        items.map { |m| Movie.send(:instantiate, m) }
      end
    end
  end
end