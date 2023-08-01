class PlayerCommand < ApplicationCommand
  prevent_controller_action

  def play
    if station
      station.play_now(track)

      Turbo::StreamsChannel.broadcast_update_to(
        station, target: :player, partial: "player/player", locals: {station:, track:, is_playing: true}
      )

      turbo_stream.update("player", partial: "player/player", locals: {station:, track:, live: true, is_playing: true})
      turbo_stream.update(dom_id(station, :queue), partial: "live_stations/queue", locals: {station:})
    else
      turbo_stream.update("player", partial: "player/player", locals: {track:, is_playing: true})
    end
  end

  def pause
    toggle_playing(false)
  end

  def resume
    toggle_playing(true)
  end

  private

  def toggle_playing(is_playing)
    if station
      Turbo::StreamsChannel.broadcast_invoke_later_to(
        station,
        "setAttribute",
        args: ["data-player-is-playing-value", is_playing.to_s],
        selector: "[data-controller='player']"
      )
    end
    turbo_stream.invoke(
      "setAttribute",
      args: ["data-player-is-playing-value", is_playing.to_s],
      selector: "[data-controller='player']"
    )
  end

  def track
    @track ||= begin
      track_id = element.data.track
      Track.find(track_id)
    end
  end

  def station
    @station ||= current_user&.live_station&.live? ? current_user.live_station : nil
  end
end
