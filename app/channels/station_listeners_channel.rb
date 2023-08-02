class StationListenersChannel < Turbo::StreamsChannel
  include ActionView::RecordIdentifier

  def subscribed
    super
    StationTracker.track_listener(station)
    update_listeners_counter(station)
  end

  def unsubscribed
    StationTracker.untrack_listener(station)
    update_listeners_counter(station)
  end

  private

  def station
    @station ||= LiveStation.find(params[:station_id])
  end

  def update_listeners_counter(station)
    counter = StationTracker.current_listeners(station)

    Turbo::StreamsChannel.broadcast_update_to(
      verified_stream_name_from_params,
      target: dom_id(station, "listeners_counter"),
      content: counter
    )
  end
end
