class Website
  # Website class consists of webpages, keywords and search queries.
  
  attr_accessor :webpages, :queries, :keywords, :max_weight
  
  def initialize(webpages=[], keywords=[], queries=[])
    @webpages = webpages
    @keywords = keywords
    @queries = queries
  end
  
  def create_web_page(value, page_number)
    words_arr = value.split()
    page_name = "P#{page_number+1}"
    webpage = WebPage.new(page_name, words_arr)
    self.webpages << webpage
    self.keywords += words_arr
    self.max_weight = self.keywords.length
  end

  def create_query(value, page_number)
    words_arr = value.split()
    query_name = "Q#{page_number+1}"
    search_query = Query.new(query_name, words_arr, self.max_weight)
    self.queries << search_query
  end

  # Web-page serach logic
  def search_webpage()
    result_hash = Hash[self.queries.collect { |query| [query.name, {}] } ]
    
    self.queries.each do |query|
      page_score_hash = Hash[self.webpages.collect { |kw| [kw.name, 0] } ]
      
      query.keywords_hash.each do |keyword, word_score|
        self.webpages.each do |page|
          word_occurance = page.keywords.count{ |kw| kw == keyword.to_s }
          page_score_hash[page.name] += word_occurance * word_score       
        end
      end
      result_hash[query.name] = page_score_hash
    end
    print_data(result_hash)
  end

  # Data manipulations, sorting and reformating.
  # Pretty Prints output to console
  def print_data(result_hash)
    result_hash.each do |key, value|
      updated_value = value.delete_if{|k,v| v==0}
      sorted_value = updated_value.sort_by {|k, v| v}.reverse[0...5]
      result_hash[key] = sorted_value.flatten.select{|elem| elem.is_a? String}
    end
    pp result_hash
  end
end  


class WebPage
  # Webpage class storing name and keywords.
  attr_accessor :name, :keywords
  def initialize(name, keywords)
    @name = name
    @keywords = keywords
  end
end


class Query
  # Query class storing name and keywords with their relavent weights.
  attr_accessor :name, :keywords, :keywords_hash
  
  def initialize(name, keywords, max_weight)
    @name = name
    @keywords_hash = create_keywords_hash(keywords, max_weight)
  end

  # This Method generates keyword-weight hash.
  def create_keywords_hash(keywords, max_weight)
    keywords_hash = Hash[keywords.collect { |kw| [kw, ""] } ]
    keywords_hash.each do |key, value|
      keywords_hash[key] = max_weight
      max_weight -= 1
    end
    keywords_hash
  end
end

class Guide
  # Flow Driver guide.
  # It Accepts inputs and perform search queries on webpages.
  
  def read_from_file()
    input_text = File.open('input.txt').read
    input_text.gsub!(/\r\n?/, "\n")
    
    page_index = 0
    query_index = 0
    
    website = Website.new()
    input_text.each_line do |line|
      if line[0]=='P'
        website.create_web_page(line[2..-1], page_index)
        page_index += 1
      end  
      if line[0]=='Q'
        website.create_query(line[2..-1], query_index)
        query_index += 1
      end
    end
    puts("\n")
    website.search_webpage()
  end
end

guide = Guide.new
guide.read_from_file()