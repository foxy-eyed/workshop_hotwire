module StationTracker
  module_function

  def track_listener(station)
    store.increment(station.id)
  end

  def untrack_listener(station)
    store.decrement(station.id)
  end

  def current_listeners(station)
    store.get(station.id)
  end

  def store
    @store ||= Store.new(key_prefix: "station_")
  end
end
