class StationListenersChannel < Turbo::StreamsChannel
  include ActionView::RecordIdentifier

  after_subscribe :track_listener
  after_unsubscribe :untrack_listener

  def track_listener
    StationTracker.track_listener(station)
    broadcast_counter_update
  end

  def untrack_listener
    StationTracker.untrack_listener(station)
    broadcast_counter_update
  end

  private

  def station
    @station ||= LiveStation.find(params[:station_id])
  end

  def broadcast_counter_update
    counter = StationTracker.current_listeners(station)

    Turbo::StreamsChannel.broadcast_update_to(
      verified_stream_name_from_params,
      target: dom_id(station, "listeners_counter"),
      content: counter
    )
  end
end
