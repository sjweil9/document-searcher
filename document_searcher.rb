require 'pry'

module DocumentSearcher
  # initializes with an array of strings representing search phrases and builds a trie with them
  class SearchPhrases
    def initialize(phrases)
      @start_node = WordNode.new(start: true)
      build_trie(phrases)
    end

    attr_reader :start_node

    def dig(*keys)
      current_node = @start_node
      keys.each do |key|
        return nil unless current_node[key]
        current_node = current_node[key]
      end
      current_node
    end

    private

    def build_trie(phrases)
      phrases.each do |phrase|
        current_node = @start_node
        phrase.scan(/\w+/).each do |word|
          new_node = WordNode.new(word: word)
          current_node[word] ||= new_node
          current_node = current_node[word]
        end
      end
    end
  end

  class WordNode
    def initialize(word: nil, start: false)
      @value = word
      @start = start
      @children = {}
    end

    attr_reader :value

    def start_node?
      @start
    end

    def children
      @children.values.map(&:value)
    end

    def [](key)
      @children[key]
    end

    def []=(key, value)
      @children[key] = value
    end

    def dig(*keys)
      current_node = self
      keys.each do |key|
        return nil unless current_node[key]
        current_node = current_node[key]
      end
      current_node
    end
  end

  class Base
    def self.search(text, phrases)
      new(text, phrases).search
    end

    def initialize(text, phrases)
      @words = text.scan(/\w+/)
      @phrases = SearchPhrases.new(phrases)
      @found_phrases = []
      @current_phrase = []
    end

    def search
      phrase_pointer = phrases.start_node
      words.each do |word|
        if phrase_pointer.children.include?(word)
          @current_phrase << word
          phrase_pointer = phrase_pointer[word]
        else
          if phrase_pointer.children.empty?
            found_phrase = @current_phrase.join(' ')
            @found_phrases << found_phrase unless found_phrase.size.zero?
          end
          phrase_pointer = phrases.start_node
          @current_phrase = []
        end
      end
      found_phrases
    end

    attr_reader :words, :phrases, :found_phrases, :current_phrase
  end
end
