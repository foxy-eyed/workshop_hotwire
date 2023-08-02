module StationTracker
  class Store
    attr_reader :expiry, :key_prefix

    def initialize(key_prefix:, expiry: 60 * 60 * 24)
      @key_prefix = key_prefix
      @expiry = expiry
    end

    def increment(key)
      cache.increment(cache_key(key), 1)
    end

    def decrement(key)
      cache.decrement(cache_key(key), 1)
    end

    def get(key)
      cache.get(cache_key(key)).to_i
    end

    def reset(key)
      cache.delete(cache_key(key))
    end

    private

    def cache
      @cache ||= Litecache.new(expiry: expiry)
    end

    def cache_key(key)
      [key_prefix, key].join("_")
    end
  end
end
